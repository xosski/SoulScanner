#!/bin/bash

DUMP_DIR="${1:-$(pwd)}"
BYTES=32
LOGFILE="codiness_report.log"
TEMP_DIR="/tmp/soulscanner_$$"
mkdir -p "$TEMP_DIR"

: > "$LOGFILE"

log() {
    echo "$@" | tee -a "$LOGFILE"
}

is_gzip() { file "$1" | grep -q 'gzip compressed'; }
is_zip()  { file "$1" | grep -qi 'zip archive'; }
is_base64_like() { grep -E -o '[A-Za-z0-9+/]{80,}={0,2}' "$1" | grep -q .; }
extract_base64() { grep -E -o '[A-Za-z0-9+/]{80,}={0,2}' "$1" > "$2"; }

detect_code() {
    local file="$1"
    if file "$file" | grep -q -E 'ASCII|UTF-8|text'; then
        if grep -q -E 'int main|#include|def |class |function |var |let |const|=>|end|public|private|<html>|</|[{;}]' "$file"; then
            log "Contains: 🚨 Code-Like Structures"
        fi
    fi
}

detect_codiness() {
    local file="$1"
    local score=0
    if ! file "$file" | grep -q -i "text"; then
        log "Codiness: 0/15 🧱 (not text)"
        return
    fi

    total_chars=$(wc -c < "$file")
    printable_chars=$(tr -cd '\11\12\15\40-\176' < "$file" | wc -c)
    ratio=$(( 100 * printable_chars / (total_chars + 1) ))
    lines=$(wc -l < "$file")

    (( ratio > 85 )) && ((score+=3))
    (( lines >= 10 )) && ((score+=2))
    grep -qE 'int |main|class |def |function |#include|const|let|=>|;|{' "$file" && ((score+=5))
    grep -qE '^[[:space:]]{2,}' "$file" && ((score+=1))
    grep -qE '[{}();<>]' "$file" && ((score+=2))
    grep -qE '\[[^]]*\]|\{[^}]*\}|\([^)]*\)' "$file" && ((score+=1))

    log -n "Codiness: $score/15 "
    if (( score >= 13 )); then log "🧙 (definitely source code)"
    elif (( score >= 8 )); then log "🧾 (likely code)"
    elif (( score >= 4 )); then log "🤔 (maybe code, maybe diary)"
    else log "🧱 (nope)"
    fi
}

decrypt_brainrot() {
    log "Attempted decryption: ❌ not implemented"
}

try_decrypt_aes() {
    local file="$1"
    local key="deadbeefdeadbeefdeadbeefdeadbeef"
    local iv="00000000000000000000000000000000"

    openssl enc -aes-128-cbc -d -in "$file" -K "$key" -iv "$iv" -out "$TEMP_DIR/decrypted_guess.bin" 2>/dev/null

    if file "$TEMP_DIR/decrypted_guess.bin" | grep -q "text"; then
        log "🔓 AES Decryption yielded plaintext!"
        process_file_recursive "$TEMP_DIR/decrypted_guess.bin" 99
    fi
}

process_file_recursive() {
    local input="$1"
    local level="$2"
    local base=$(basename "$input")
    log "🧾 [L$level] File: $base"

    local signature=$(xxd -l $BYTES -p "$input" | tr '[:upper:]' '[:lower:]')
    log "Signature: ${signature:0:16}..."

    mime=$(file --mime-type -b "$input")
    log "📄 MIME type: $mime"

    if grep -q -E "\b(the|and|you|for|that|with)\b" "$input"; then
        log "🗣 Likely contains English text."
    fi

    detect_code "$input"
    detect_codiness "$input"

    if is_gzip "$input"; then
        log "Found: 🗜 GZIP-compressed file. Decompressing..."
        gunzip -c "$input" > "$TEMP_DIR/decoded_L${level}_$base"
        process_file_recursive "$TEMP_DIR/decoded_L${level}_$base" $((level+1))
    elif is_zip "$input"; then
        log "Found: 📦 ZIP archive. Extracting..."
        unzip -o "$input" -d "$TEMP_DIR/unzipped_$base" >/dev/null 2>&1
        for nested in "$TEMP_DIR/unzipped_$base"/*; do
            [[ -f "$nested" ]] && process_file_recursive "$nested" $((level+1))
        done
    elif is_base64_like "$input"; then
        log "Found: 🧬 Base64 block. Decoding..."
        extract_base64 "$input" "$TEMP_DIR/b64_L${level}_$base"
        base64 -d "$TEMP_DIR/b64_L${level}_$base" > "$TEMP_DIR/decoded_b64_L${level}_$base" 2>/dev/null
        if [[ -s "$TEMP_DIR/decoded_b64_L${level}_$base" ]]; then
            process_file_recursive "$TEMP_DIR/decoded_b64_L${level}_$base" $((level+1))
        else
            log "⚠️ Decoded base64 block was invalid"
        fi
    else
        entropy=$(xxd "$input" | tr -dc '[:print:]' | wc -c)
        if (( entropy < 10 )); then
            log "⚠️ High entropy — potential encryption"
            try_decrypt_aes "$input"
        fi
    fi
}

log "🔎 Codiness scan started at $(date)"
log "Scanning directory: $DUMP_DIR"
log "==================================="

for file in "$DUMP_DIR"/*; do
    if [[ -f "$file" ]]; then
        process_file_recursive "$file" 0
        log "-----------------------------------"
    fi
done

log "✅ Scan complete at $(date)"
rm -rf "$TEMP_DIR"
read -p "Press ENTER to close this window..."