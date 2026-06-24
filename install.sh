#!/bin/bash

echo -e "\e[1;32m==================================================\e[0m"
echo -e "\e[1;36m       LOGTOOLS SUITE v1.0 HYBRID INSTALLER       \e[0m"
echo -e "\e[1;33m       Author: Sawang (https://sawang.my.id)      \e[0m"
echo -e "\e[1;32m==================================================\e[0m"

DIR_TARGET="$HOME/logtools"
mkdir -p "$DIR_TARGET/backup_config"

# 1. Backup .bashrc lama jika ada
if [ -f "$HOME/.bashrc" ]; then
    cp "$HOME/.bashrc" "$DIR_TARGET/backup_config/.bashrc.bak.$(date +%Y%m%d_%H%M%S)"
    echo "[+] Backup .bashrc berhasil diamankan."
fi

# 2. Deteksi Skenario Instalasi (Apakah folder lokal 'logtools' tersedia?)
if [ -d "logtools" ] && [ -f "logtools/cekspek" ] && [ -f "logtools/cekport" ] && [ -f "logtools/cekidpel" ]; then
    echo "[*] Mendeteksi folder lokal. Menyalin komponen direktori..."
    cp logtools/cekspek "$DIR_TARGET/"
    cp logtools/cekport "$DIR_TARGET/"
    cp logtools/cekidpel "$DIR_TARGET/"
else
    echo "[*] Folder lokal tidak ditemukan. Mengekstrak komponen langsung dari skrip..."
    
    # --- INJEKSI CEKSPEK ---
    cat << 'EOF' > "$DIR_TARGET/cekspek"
#!/bin/bash
arg=$1
if [ "$arg" = "-v" ] || [ "$arg" = "version" ] || [ "$arg" = "-version" ]; then
    echo -e "\e[1;32mLogTools - System Specification Informer\e[0m"
    echo -e "Version : \e[1;33mv1.0 (Official Release)\e[0m"
    echo -e "Build   : 2026.06.25"
    echo -e "Author  : Sawang (\e[1;36mhttps://sawang.my.id\e[0m)"
    exit 0
fi

echo "=== Spesifikasi Server ==="
echo "OS      : $(uname -o) $(uname -r)"
echo "CPU     : $(lscpu | grep 'Model name' | cut -d':' -f2 | sed 's/^[ \t]*//' 2>/dev/null || echo 'ARM/Embedded Processor')"
echo "RAM     : $(free -h 2>/dev/null | grep Mem | awk '{print $2}' || echo 'N/A')"
echo "Storage : $(df -h / | awk 'NR==2 {print $2}')"
EOF

    # --- INJEKSI CEKPORT ---
    cat << 'EOF' > "$DIR_TARGET/cekport"
#!/bin/bash
port_input=$1
if [ "$port_input" = "-v" ] || [ "$port_input" = "version" ] || [ "$port_input" = "-version" ]; then
    echo -e "\e[1;32mLogTools - Network Port Scanner & Monitor\e[0m"
    echo -e "Version : \e[1;33mv1.0 (Official Release)\e[0m"
    echo -e "Build   : 2026.06.25"
    echo -e "Author  : Sawang (\e[1;36mhttps://sawang.my.id\e[0m)"
    exit 0
fi

if [ -z "$port_input" ]; then
    echo -e "\e[1;33m[!] Format salah! Gunakan: cekport [nomor_port]\e[0m"
    exit 1
fi

echo "=== Memeriksa Port: $port_input ==="
sudo netstat -tulnp | grep ":$port_input " || sudo ss -tulnp | grep ":$port_input " || echo "Port $port_input sedang tidak aktif/terbuka."
EOF

    # --- INJEKSI CEKIDPEL ---
    cat << 'EOF' > "$DIR_TARGET/cekidpel"
#!/bin/bash
idpel=$1
tanggal=$2
user_path=$3

if [ "$idpel" = "-v" ] || [ "$idpel" = "version" ] || [ "$idpel" = "-version" ]; then
    echo -e "\e[1;32mLogTools - Transaction Log Locator\e[0m"
    echo -e "Version : \e[1;33mv1.0 (Official Release)\e[0m"
    echo -e "Build   : 2026.06.25"
    echo -e "Author  : Sawang (\e[1;36mhttps://sawang.my.id\e[0m)"
    exit 0
fi

if [ -z "$idpel" ]; then
    echo -e "\e[1;33m[!] Format salah!\e[0m"
    echo -e "Format Standar : cekidpel [id_pelanggan] [tanggal/-] [prefix_path]"
    echo -e "Format Locator : cekidpel [id_pelanggan] path [prefix_path]"
    exit 1
fi

if [ "$tanggal" = "-" ]; then tanggal=""; fi

if [ -n "$user_path" ]; then
    TARGET_PATHS=$(ls -d ${user_path}*/logs/*/*.log* ${user_path}*/tarlogs/*/*.log* 2>/dev/null)
else
    TARGET_PATHS=$(ls -d /opt/*/logs/*/*.log* /opt/*/tarlogs/*/*.log* 2>/dev/null)
fi

if [ -z "$TARGET_PATHS" ]; then
    echo "[!] Tidak terdeteksi ada berkas log di susunan folder target."
    exit 1
fi

if [ "$tanggal" = "path" ]; then
    echo "=== MODE LOCATOR: HANYA MENAMPILKAN PATH FILE LOG ==="
    echo "• Kata Kunci  : '$idpel'"
    echo "• Target Area : ${user_path}*"
    echo "=================================================================="
    ( echo "--- File Log yang Mengandung Data ID $idpel ---"
      echo "$TARGET_PATHS" | xargs -I {} sudo zgrep -l "$idpel" "{}" 2>/dev/null || echo "Tidak ditemukan di file log." ) | less -X -F
elif [ -n "$tanggal" ]; then
    echo "=== TANGGUNG JAWAB FILTER AKTIF (TAMPILKAN BARIS LOG) ==="
    echo "• Kata Kunci  : '$idpel'"
    echo "• Tanggal     : $tanggal"
    echo "=================================================================="
    ( echo "--- Hasil Pencarian Terfilter ($tanggal) ---"
      echo "$TARGET_PATHS" | xargs -I {} sudo zgrep -H "$idpel" "{}" 2>/dev/null | grep "$tanggal" ) | less -X -F
else
    echo "=== TANGGUNG JAWAB FILTER AKTIF (TAMPILKAN BARIS LOG) ==="
    echo "• Kata Kunci  : '$idpel'"
    echo "• Tanggal     : Semua Riwayat"
    echo "=================================================================="
    ( echo "--- Hasil dari Seluruh Berkas Log ---"
      echo "$TARGET_PATHS" | xargs -I {} sudo zgrep -H "$idpel" "{}" 2>/dev/null || echo "Tidak ditemukan data log." ) | less -X -F
fi
EOF

fi

# 3. Memberikan Hak Eksekusi ke Semua File Baru
chmod +x "$DIR_TARGET/cekspek" "$DIR_TARGET/cekport" "$DIR_TARGET/cekidpel"

# 4. Mendaftarkan Jalur Path ke .bashrc Jika Belum Ada
if ! grep -q 'export PATH="$PATH:$HOME/logtools"' "$HOME/.bashrc"; then
    echo 'export PATH="$PATH:$HOME/logtools"' >> "$HOME/.bashrc"
fi

echo -e "\e[1;32m==================================================\e[0m"
echo -e "\e[1;36m INSTALASI SELESAI! SILAKAN JALANKAN PERINTAH:    \e[0m"
echo -e "\e[1;33m             source ~/.bashrc                     \e[0m"
echo -e "\e[1;32m==================================================\e[0m"
