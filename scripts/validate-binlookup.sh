#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATASET="$ROOT_DIR/data/bines.yaml"
LIMIT="${BIN_LIMIT:-}"
EVIDENCE_DIR="${BINLOOKUP_EVIDENCE_DIR:-$ROOT_DIR/reports/binlookup}"

if [[ -f "$ROOT_DIR/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$ROOT_DIR/.env"
  set +a
fi

BINLOOKUP_URL="${BINLOOKUP_URL:-https://ef-storefront-web-qa.enviaflores.com/api/payments/bin-lookup?bin={bin}}"
BINLOOKUP_BANK_JSON_PATH="${BINLOOKUP_BANK_JSON_PATH:-}"
BINLOOKUP_MATCH_MODE="${BINLOOKUP_MATCH_MODE:-exact}"

ruby -ryaml -rjson -rnet/http -ruri -rcsv -rfileutils -e '
  dataset_path = ARGV.fetch(0)
  url_template = ARGV.fetch(1)
  limit = ARGV.fetch(2)
  json_path = ARGV.fetch(3)
  match_mode = ARGV.fetch(4)
  evidence_dir = ARGV.fetch(5)

  def normalize(value)
    text = value.to_s
    text = text.unicode_normalize(:nfkd) if text.respond_to?(:unicode_normalize)
    text
      .encode("ASCII", replace: "", undef: :replace)
      .upcase
      .gsub(/[^A-Z0-9]+/, " ")
      .strip
  end

  def fetch_path(payload, path)
    path.split(".").reduce(payload) do |node, key|
      return nil unless node.is_a?(Hash)
      node[key] || node[key.to_sym]
    end
  end

  def first_present(payload, paths)
    paths.each do |path|
      value = fetch_path(payload, path)
      return value unless value.nil? || value.to_s.strip.empty?
    end
    nil
  end

  def compare_text(label, bin, expected, actual, failures, match_mode)
    if actual.nil? || actual.to_s.strip.empty?
      failures << "#{bin}: #{label} sin valor en binlookup"
      return false
    end

    expected_norm = normalize(expected)
    actual_norm = normalize(actual)
    matched = if match_mode == "contains"
      actual_norm.include?(expected_norm) || expected_norm.include?(actual_norm)
    else
      actual_norm == expected_norm
    end

    failures << "#{bin}: #{label} esperado #{expected.inspect}, recibido #{actual.inspect}" unless matched
    matched
  end

  def binlookup_url(template, bin)
    if template.include?("{bin}")
      template.gsub("{bin}", bin)
    else
      [template.sub(%r{/*\z}, ""), bin].join("/")
    end
  end

  rows = YAML.load_file(dataset_path).fetch("bines")
  rows = rows.first(limit.to_i) unless limit.empty?
  FileUtils.mkdir_p(evidence_dir)

  timestamp = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
  jsonl_path = File.join(evidence_dir, "binlookup-#{timestamp}.jsonl")
  csv_path = File.join(evidence_dir, "binlookup-#{timestamp}.csv")
  latest_jsonl_path = File.join(evidence_dir, "binlookup-latest.jsonl")
  latest_csv_path = File.join(evidence_dir, "binlookup-latest.csv")

  candidate_paths = [
    "institution",
    "bank",
    "bank.name",
    "bankName",
    "issuer",
    "issuer.name",
    "banco",
    "data.institution",
    "data.bank",
    "data.bank.name",
    "data.issuer",
    "data.issuer.name"
  ]

  failures = []
  evidence_rows = []

  rows.each do |row|
    bin = row.fetch("bin")
    expected_institution = row.fetch("institution")
    expected_institution_id = row.fetch("institution_id").to_s
    expected_brand = row.fetch("card_brand")
    expected_msi = row.fetch("msi_allowed")
    uri = URI(binlookup_url(url_template, bin))
    response = Net::HTTP.get_response(uri)
    evidence = {
      "bin" => bin,
      "request_url" => uri.to_s,
      "http_status" => response.code.to_i,
      "expected" => {
        "institution" => expected_institution,
        "institution_id" => expected_institution_id,
        "brand" => expected_brand,
        "show_installment_options" => expected_msi
      },
      "response_body" => response.body
    }

    unless response.is_a?(Net::HTTPSuccess)
      failures << "#{bin} #{expected_institution}: HTTP #{response.code}"
      evidence["status"] = "FAIL"
      evidence["failure_reason"] = "HTTP #{response.code}"
      evidence_rows << evidence
      next
    end

    payload = JSON.parse(response.body)
    evidence["response_json"] = payload
    actual_institution = if json_path.empty?
      first_present(payload, candidate_paths)
    else
      fetch_path(payload, json_path)
    end
    actual_institution_id = first_present(payload, ["institution_id", "data.institution_id"])
    actual_brand = first_present(payload, ["brand", "data.brand"])
    actual_msi = first_present(payload, ["show_installment_options", "data.show_installment_options"])

    evidence["actual"] = {
      "institution" => actual_institution,
      "institution_id" => actual_institution_id,
      "brand" => actual_brand,
      "show_installment_options" => actual_msi
    }

    if actual_institution.nil? || actual_institution.to_s.strip.empty?
      failures << "#{bin} #{expected_institution}: respuesta sin banco/institucion detectable"
      evidence["status"] = "FAIL"
      evidence["failure_reason"] = "respuesta sin banco/institucion detectable"
      evidence_rows << evidence
      next
    end

    checks = []
    checks << compare_text("institution", bin, expected_institution, actual_institution, failures, match_mode)
    checks << compare_text("institution_id", bin, expected_institution_id, actual_institution_id.to_s, failures, "exact")
    checks << compare_text("brand", bin, expected_brand, actual_brand, failures, match_mode)

    actual_msi_bool = actual_msi == true || actual_msi.to_s == "true"
    checks << (actual_msi_bool == expected_msi)
    failures << "#{bin}: show_installment_options esperado #{expected_msi.inspect}, recibido #{actual_msi.inspect}" unless actual_msi_bool == expected_msi

    status = checks.all? ? "OK" : "FAIL"
    evidence["status"] = status
    evidence["failure_reason"] = failures.last if status == "FAIL"
    evidence_rows << evidence
    puts "[#{status}] #{bin} institution=#{actual_institution.inspect} id=#{actual_institution_id.inspect} brand=#{actual_brand.inspect} msi=#{actual_msi.inspect}"
  rescue JSON::ParserError => error
    failures << "#{bin}: JSON invalido (#{error.message})"
    evidence_rows << {
      "bin" => bin,
      "request_url" => uri&.to_s,
      "http_status" => response&.code&.to_i,
      "expected" => {
        "institution" => expected_institution,
        "institution_id" => expected_institution_id,
        "brand" => expected_brand,
        "show_installment_options" => expected_msi
      },
      "response_body" => response&.body,
      "status" => "FAIL",
      "failure_reason" => "JSON invalido (#{error.message})"
    }
  rescue StandardError => error
    failures << "#{bin}: #{error.class} #{error.message}"
    evidence_rows << {
      "bin" => bin,
      "request_url" => uri&.to_s,
      "status" => "FAIL",
      "failure_reason" => "#{error.class} #{error.message}"
    }
  end

  [jsonl_path, latest_jsonl_path].each do |path|
    File.open(path, "w") do |file|
      evidence_rows.each { |evidence| file.puts(JSON.generate(evidence)) }
    end
  end

  csv_headers = [
    "status",
    "bin",
    "request_url",
    "expected_institution",
    "actual_institution",
    "expected_institution_id",
    "actual_institution_id",
    "expected_brand",
    "actual_brand",
    "expected_show_installment_options",
    "actual_show_installment_options",
    "http_status",
    "failure_reason"
  ]

  [csv_path, latest_csv_path].each do |path|
    CSV.open(path, "w", write_headers: true, headers: csv_headers) do |csv|
      evidence_rows.each do |evidence|
        expected = evidence.fetch("expected", {})
        actual = evidence.fetch("actual", {})
        csv << [
          evidence["status"],
          evidence["bin"],
          evidence["request_url"],
          expected["institution"],
          actual["institution"],
          expected["institution_id"],
          actual["institution_id"],
          expected["brand"],
          actual["brand"],
          expected["show_installment_options"],
          actual["show_installment_options"],
          evidence["http_status"],
          evidence["failure_reason"]
        ]
      end
    end
  end

  if failures.any?
    warn
    warn "Fallos binlookup:"
    failures.each { |failure| warn "- #{failure}" }
    exit 1
  end

  puts
  puts "Binlookup validado: #{rows.length} casos"
  puts "Evidencia JSONL: #{jsonl_path}"
  puts "Evidencia CSV: #{csv_path}"
' "$DATASET" "$BINLOOKUP_URL" "$LIMIT" "$BINLOOKUP_BANK_JSON_PATH" "$BINLOOKUP_MATCH_MODE" "$EVIDENCE_DIR"
