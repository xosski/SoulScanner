# 🧠 SoulScanner

A recursive forensic scanner for binary memory dumps, obfuscated payloads, and code artifacts.

> Decodes. Decompresses. Decrypts (sometimes). Judgemental.

## 🔥 Features

- GZIP, ZIP, and Base64 auto-decoding
- Codiness scoring system for source detection
- Recursive analysis of embedded payloads
- Optional AES-128 decryption attempts
- Language fingerprinting
- MIME type recognition
- Logging to desktop

## 🖥 Requirements

- Git Bash or WSL
- `openssl`, `unzip`, `base64`, `xxd`, `file`

## 🚀 Usage

```bash
bash SoulScanner.sh /path/to/suspect/files