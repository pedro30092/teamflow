# Temporary Files Convention

## Rule

**ALL temporary files, dumps, and reports go in `/tmp` at project root.**

```
teamflow/tmp/
```

This directory is in `.gitignore` - nothing here gets committed.

---

## Usage in Scripts

```bash
# Get project root from any script location
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="${PROJECT_ROOT}/tmp"
mkdir -p "${TMP_DIR}"

# Save files with timestamps
OUTPUT_FILE="${TMP_DIR}/report-$(date +%Y%m%d-%H%M%S).txt"
```

---

## What Goes Here

✅ Use `/tmp` for:
- AWS CLI outputs and billing reports
- Debug logs and diagnostics
- Any data that might contain credentials
- Script-generated reports

❌ Don't use `/tmp` for:
- Source code
- Documentation to commit
- Configuration files

---

## Examples

```bash
# AWS data dump
aws lambda list-functions > tmp/lambda-list-$(date +%Y%m%d).json

# Billing report
./scripts/aws-billing-audit.sh
# → outputs to tmp/aws-billing-report-YYYYMMDD-HHMMSS.txt

# Organize by category
mkdir -p tmp/aws-dumps tmp/reports tmp/debug-logs
```

---

## Cleanup

```bash
# Remove all
rm -rf tmp/*

# Remove old files (7+ days)
find tmp/ -type f -mtime +7 -delete
```

---

**That's it.** Keep it simple.
