📖 Usage
bash
Copy
Edit
bash SoulScanner.sh [optional/path/to/scan]
If no path is given, the script defaults to the current directory.
Results are saved to ~/Desktop/codiness_report.log.

🧰 Example Scans
bash
Copy
Edit
# Scan a local dump directory
bash SoulScanner.sh ~/Downloads/memory_dump

# Scan a Chrome cache folder
bash SoulScanner.sh "C:/Users/yourname/AppData/Local/Google/Chrome/User Data/Default/Cache"

# Scan your own sins (cwd)
bash SoulScanner.sh
🧟 What It Does
For each file it encounters, the scanner will:

Identify file type and MIME

Check for code-like structure and assign a Codiness score (0–15)

Detect and recursively unpack:

GZIP-compressed files

ZIP archives

Base64 blocks

Attempt naive AES-128 decryption (placeholder for now)

Detect high-entropy blobs (potential encryption/malware)

Log English language content

Record everything in a structured log file

🧾 Output Sample
yaml
Copy
Edit
🧾 [L0] File: strange_payload.gz
Signature: 1f8b080000000000...
📄 MIME type: application/gzip
Found: 🗜 GZIP-compressed file. Decompressing...
🧾 [L1] File: decoded_L0_strange_payload.gz
Codiness: 12/15 🧾 (likely code)
Contains: 🚨 Code-Like Structures
💀 Exit Prompt
After scanning, the script waits for you to press ENTER before closing the terminal.
So you can actually read your sins before the shell eats them.

