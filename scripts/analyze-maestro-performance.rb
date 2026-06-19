# frozen_string_literal: true

threshold_ms = Integer(ARGV[1] || 1000)
log_path = ARGV[0]

unless log_path
  candidates = Dir.glob(File.expand_path("~/.maestro/tests/*/maestro.log"))
  log_path = candidates.max_by { |file| File.mtime(file) }
end

unless log_path && File.file?(log_path)
  warn "No se encontro un maestro.log para analizar."
  exit 1
end

starts = Hash.new { |hash, key| hash[key] = [] }
skipped = []

File.foreach(log_path) do |line|
  match = line.match(/^(\d\d):(\d\d):(\d\d)\.(\d{3}).*?: (.+) (RUNNING|SKIPPED|COMPLETED)$/)
  next unless match

  hours, minutes, seconds, milliseconds, label, status = match.captures
  timestamp = ((hours.to_i * 60 + minutes.to_i) * 60 + seconds.to_i) * 1000 + milliseconds.to_i

  if status == "RUNNING"
    starts[label] << timestamp
    next
  end

  started_at = starts[label].pop
  next unless started_at

  duration = timestamp - started_at
  duration += 24 * 60 * 60 * 1000 if duration.negative?
  skipped << [duration, label] if status == "SKIPPED"
end

slow = skipped.select { |duration, _label| duration >= threshold_ms }.sort.reverse
total_ms = skipped.sum { |duration, _label| duration }

puts "Log: #{log_path}"
puts "Condiciones omitidas: #{skipped.length}"
puts format("Tiempo total omitido: %.1fs", total_ms / 1000.0)
puts "Omitidas >= #{threshold_ms}ms: #{slow.length}"

slow.each do |duration, label|
  puts format("%7.2fs  %s", duration / 1000.0, label)
end
