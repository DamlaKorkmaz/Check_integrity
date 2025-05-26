#!/bin/bash

TARGET_DIR="/opt/scripts"
BASELINE="$HOME/baseline_hashes.txt"
REPORT="$HOME/integrity_report.txt"
TMP_CURRENT="/tmp/current_hashes.txt"

# Eğer baseline dosyası yoksa ilk kez çalıştırılıyor
if [ ! -f "$BASELINE" ]; then
    find "$TARGET_DIR" -type f -exec sha256sum {} \; > "$BASELINE"
    exit 0
fi

# Mevcut hash'leri oku
find "$TARGET_DIR" -type f -exec sha256sum {} \; > "$TMP_CURRENT"

{
    echo "=== Dosya Bütünlüğü Raporu - $(date) ==="

    # İçeriği değişmiş dosyalar
    diff --unchanged-line-format= --old-line-format='[OLD] %L' --new-line-format='[NEW] %L' "$BASELINE" "$TMP_CURRENT"

    # Silinen dosyalar
    comm -23 <(cut -d ' ' -f3- "$BASELINE" | sort) <(cut -d ' ' -f3- "$TMP_CURRENT" | sort) | while read -r missing; do
        echo "[DELETED] $missing"
    done

    # Yeni eklenen dosyalar
    comm -13 <(cut -d ' ' -f3- "$BASELINE" | sort) <(cut -d ' ' -f3- "$TMP_CURRENT" | sort) | while read -r new; do
        echo "[NEW FILE] $new"
    done

    echo ""
} > "$REPORT"

rm -f "$TMP_CURRENT"
