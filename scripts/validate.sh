#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

STATUS=0

pass() {
  echo "[OK] $1"
}

fail() {
  echo "[FAIL] $1"
  STATUS=1
}

warn() {
  echo "[WARN] $1"
}

scan_content() {
  local pattern="$1"
  shift
  if command -v rg >/dev/null 2>&1; then
    rg -n "$pattern" "$@"
  else
    grep -R -n -E "$pattern" "$@"
  fi
}

extract_env_refs() {
  if command -v rg >/dev/null 2>&1; then
    rg --no-filename -o '\$\{[A-Z0-9_]+\}' flows config.yaml .github
  else
    grep -R -h -o -E '\$\{[A-Z0-9_]+\}' flows config.yaml .github
  fi
}

check_command() {
  local command_name="$1"
  if command -v "$command_name" >/dev/null 2>&1; then
    pass "${command_name} disponible"
  else
    fail "${command_name} no disponible"
  fi
}

echo "QA Mobile EnviaFlores - validate"
echo

check_command ruby
check_command node

echo
echo "Validando JSON"
if node -e 'JSON.parse(require("fs").readFileSync("package.json", "utf8"));' >/dev/null 2>&1; then
  pass "package.json valido"
else
  fail "package.json invalido"
fi

echo
echo "Validando YAML"
yaml_files=()
while IFS= read -r file; do
  yaml_files+=("$file")
done < <(find config.yaml flows data .github -name "*.yaml" -o -name "*.yml" | sort)

if ruby -e 'require "yaml"; ARGV.each { |f| YAML.load_stream(File.read(f)) }' "${yaml_files[@]}"; then
  pass "YAML valido (${#yaml_files[@]} archivos)"
else
  fail "YAML invalido"
fi

echo
echo "Validando grafo de subflows"
if ruby scripts/validate-flow-graph.rb; then
  pass "Grafo de subflows valido"
else
  fail "Grafo de subflows invalido"
fi

echo
echo "Validando politica de esperas"
wait_policy_report="$(
  ruby -e '
    Dir.glob("flows/**/*.yaml").sort.each do |file|
      lines = File.readlines(file)
      lines.each_with_index do |line, index|
        if line.match?(/^\s*- waitForAnimationToEnd:/)
          justification = index.positive? ? lines[index - 1] : ""
          unless justification.match?(/^\s*# wait-justification:\s+\S/)
            puts "#{file}:#{index + 1}: waitForAnimationToEnd requiere un comentario # wait-justification"
          end
        end

        next unless line.match?(/^\s*- extendedWaitUntil:/)

        timeout_line = Array(lines[index + 1, 6]).find { |candidate| candidate.match?(/^\s+timeout:\s*\d+/) }
        next unless timeout_line

        timeout = timeout_line[/\d+/].to_i
        if timeout <= 7000
          puts "#{file}:#{index + 1}: usar assertVisible/assertNotVisible para esperas de hasta 7000 ms"
        end
      end
    end
  '
)"

if [[ -n "$wait_policy_report" ]]; then
  printf '%s\n' "$wait_policy_report"
  fail "Se encontraron esperas sin justificacion"
else
  pass "Esperas explicitas justificadas"
fi

echo
echo "Validando comentarios iniciales"
for file in "${yaml_files[@]}"; do
  first_line="$(sed -n '1p' "$file")"
  if [[ "$first_line" == \#* ]]; then
    pass "Comentario inicial: $file"
  else
    fail "Falta comentario inicial en $file"
  fi
done

echo
echo "Validando placeholders"
if scan_content "PLACEHOLDER|replace-with-ios|com\\.example" flows data config.yaml .env.example README.md .github docs >/tmp/qa-mobile-placeholder-scan.txt; then
  cat /tmp/qa-mobile-placeholder-scan.txt
  fail "Se encontraron placeholders o valores genericos"
else
  pass "Sin placeholders conocidos"
fi

echo
echo "Validando variables de ambiente usadas en flows/config"
env_example_vars=()
while IFS= read -r var_name; do
  env_example_vars+=("$var_name")
done < <(sed -n 's/^\([A-Z0-9_][A-Z0-9_]*\)=.*/\1/p' .env.example | sort -u)

referenced_vars=()
while IFS= read -r var_name; do
  if [[ -n "$var_name" ]]; then
    referenced_vars+=("$var_name")
  fi
done < <(extract_env_refs | sed 's/[${}]//g' | sort -u)

for var_name in "${referenced_vars[@]:-}"; do
  if printf '%s\n' "${env_example_vars[@]}" | grep -qx "$var_name"; then
    pass "Variable declarada: $var_name"
  else
    fail "Variable usada pero no declarada en .env.example: $var_name"
  fi
done

echo
echo "Validando seguridad de pagos"
if scan_content "Pagar y completar compra|payment_action_pay|confirmar pago|confirm payment|place order|PLACE_ORDER" flows >/tmp/qa-mobile-payment-scan.txt; then
  cat /tmp/qa-mobile-payment-scan.txt
  warn "Hay referencias a pantallas/acciones de pago. Confirmar que solo sean asserts y no taps."
fi

if command -v rg >/dev/null 2>&1; then
  rg -n "tapOn:\s*$\n\s+text:\s+\"?(Pagar y completar compra|Pagar|Confirmar compra|Place order)" -U flows >/tmp/qa-mobile-dangerous-payment-scan.txt || true
else
  warn "rg no disponible; omitiendo escaneo multilinea de taps peligrosos."
  : > /tmp/qa-mobile-dangerous-payment-scan.txt
fi

if [[ -s /tmp/qa-mobile-dangerous-payment-scan.txt ]]; then
  cat /tmp/qa-mobile-dangerous-payment-scan.txt
  fail "Se encontraron taps potencialmente peligrosos de pago"
else
  pass "Sin taps peligrosos de pago detectados"
fi

echo
echo "Validando credenciales embebidas"
if scan_content '\|\| "(Prueba1234|PasswordIncorrecto|enviafloresQA)' flows >/tmp/qa-mobile-cred-scan.txt; then
  cat /tmp/qa-mobile-cred-scan.txt
  fail "Hay credenciales embebidas como fallback en flows. Usa solo \${VAR} y define el valor en .env/Secrets."
else
  pass "Sin credenciales embebidas en flows"
fi

echo
echo "Validando scripts shell"
if bash -n scripts/*.sh; then
  pass "Scripts shell validos"
else
  fail "Scripts shell con errores de sintaxis"
fi

echo
if [[ "$STATUS" -eq 0 ]]; then
  pass "Validacion estatica lista"
else
  fail "Validacion estatica con pendientes"
fi

exit "$STATUS"
