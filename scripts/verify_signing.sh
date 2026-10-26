#!/usr/bin/env bash
set -e

KEYSTORE="android/upload-keystore.jks"
KEYSTORE_APP="android/app/upload-keystore.jks"
PROPERTIES="android/key.properties"

echo "=== 1. Checking files ==="
[ -f "$KEYSTORE" ] && echo "[OK] Keystore found: $KEYSTORE" || (echo "[FAIL] Missing $KEYSTORE" && exit 1)
[ -f "$KEYSTORE_APP" ] && echo "[OK] Keystore found: $KEYSTORE_APP" || (echo "[FAIL] Missing $KEYSTORE_APP" && exit 1)
[ -f "$PROPERTIES" ] && echo "[OK] Properties found: $PROPERTIES" || (echo "[FAIL] Missing $PROPERTIES" && exit 1)

echo "=== 2. Verifying Keystore Integrity ==="
keytool -list -v -keystore "$KEYSTORE" -storepass "AlgorixSecurePass2026!" | grep -E "Alias name|Valid from|Owner|SHA256"

echo "=== ALL CHECKS PASSED ==="
