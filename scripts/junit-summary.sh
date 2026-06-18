#!/usr/bin/env bash
set -euo pipefail

REPORT_GLOB="${1:-reports/*.xml}"
TITLE="${2:-Maestro JUnit Summary}"

python3 - "$REPORT_GLOB" "$TITLE" <<'PY'
import glob
import os
import sys
import xml.etree.ElementTree as ET

report_glob = sys.argv[1]
title = sys.argv[2]
files = sorted(glob.glob(report_glob))

if not files:
    print(f"## {title}")
    print()
    print("No report files were found.")
    sys.exit(0)

totals = {"tests": 0, "failures": 0, "errors": 0, "skipped": 0}

for path in files:
    tree = ET.parse(path)
    root = tree.getroot()
    suites = [root] if root.tag == "testsuite" else list(root.findall("testsuite"))
    for suite in suites:
        totals["tests"] += int(suite.attrib.get("tests", 0))
        totals["failures"] += int(suite.attrib.get("failures", 0))
        totals["errors"] += int(suite.attrib.get("errors", 0))
        totals["skipped"] += int(suite.attrib.get("skipped", 0))

passed = totals["tests"] - totals["failures"] - totals["errors"] - totals["skipped"]
pass_rate = 0.0 if totals["tests"] == 0 else (passed / totals["tests"]) * 100.0

print(f"## {title}")
print()
print(f"- Files: {len(files)}")
print(f"- Tests: {totals['tests']}")
print(f"- Passed: {passed}")
print(f"- Failed: {totals['failures']}")
print(f"- Errors: {totals['errors']}")
print(f"- Skipped: {totals['skipped']}")
print(f"- Pass rate: {pass_rate:.2f}%")
print()
print("### Reports")
for path in files:
    print(f"- {os.path.basename(path)}")
PY
