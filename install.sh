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

# 2. Deteksi Skenario Instalasi (Apakah folder lokal 'logtools' tersedia di luar target dir?)
if [ -d "logtools" ] && [ "$(realpath logtools 2>/dev/null)" != "$DIR_TARGET" ] && [ -f "logtools/cekspek" ] && [ -f "logtools/cekport" ] && [ -f "logtools/cekidpel" ]; then
    echo "[*] Mendeteksi folder lokal eksternal. Menyalin komponen direktori..."
    cp logtools/cekspek "$DIR_TARGET/"
    cp logtools/cekport "$DIR_TARGET/"
    cp logtools/cekidpel "$DIR_TARGET/"
else
    echo "[*] Melakukan deployment/update komponen langsung dari skrip..."
    
    # --- INJEKSI CEKSPEK (VERSION FIX SEJAJAR + MULTI IP + STORAGE MONITOR + SSH PORT DETECTOR) ---
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

# Loop untuk mencetak semua IP Private agar sejajar
first_ip=true
for ip in $(hostname -I 2>/dev/null); do
    if [ "$first_ip" = "true" ]; then
        echo "IP Priv : $ip"
        first_ip=false
    else
        echo "          $ip"
    fi
done

echo "IP Pub  : $(curl -s --connect-timeout 2 ifconfig.me || echo 'Offline/No Public IP')"

# Deteksi Port SSH yang sedang aktif LISTEN
ssh_ports=$(sudo netstat -tulnp 2>/dev/null | grep -E 'sshd|ssh' | awk '{print $4}' | cut -d':' -f2 | sort -nu | xargs || \
             sudo ss -tulnp 2>/dev/null | grep -E 'sshd|ssh' | awk '{print $4}' | cut -d':' -f2 | sort -nu | xargs)

if [ -z "$ssh_ports" ]; then
    echo -e "SSH Port: \e[1;31m[!!! SSH NOT ACTIVE !!!]\e[0m"
else
    echo "SSH Port: $ssh_ports (Active)"
fi

echo "CPU     : $(lscpu | grep 'Model name' | cut -d':' -f2 | sed 's/^[ \t]*//' 2>/dev/null || echo 'ARM/Embedded Processor')"
echo "CPU Load: $(uptime | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//')"
echo "RAM     : $(free -h 2>/dev/null | grep Mem | awk '{print $2}' || echo 'N/A')"

# Cetak baris pertama Storage dan looping sejajar
first_line=true
df -h | awk 'NR>1 {print $2, $4, $5, $6}' | while read total avail use mount; do
    if [[ "$mount" == "/" || "$mount" =~ "NAS" || "$mount" =~ "BACKUPDIR" || "$mount" =~ "sd" ]]; then
        avail_num=$(echo $avail | sed 's/[GgMmKk]//g' | cut -d',' -f1 | cut -d'.' -f1)
        
        warning=""
        if [[ "$avail" =~ [Gg] && $avail_num -lt 5 ]] || [[ "$avail" =~ [MmKk] ]]; then
            warning=" \e[1;31m[!!! LOW SPACE - CRITICAL !!!]\e[0m"
        fi
        
        if [ "$first_line" = "true" ]; then
            echo -e "Storage : $mount (Total $total | Avail $avail | Used $use)$warning"
            first_line=false
        else
            echo -e "          $mount (Total $total | Avail $avail | Used $use)$warning"
        fi
    fi
done
EOF

    # --- INJEKSI CEKPORT (VERSI 100% AUTOMATIC & UNIVERSAL) ---
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

# 1. Ambil baris network status (Netstat / SS)
raw_output=$(sudo netstat -tulnp 2>/dev/null | grep -E ":$port_input\s" || sudo ss -tulnp 2>/dev/null | grep -E ":$port_input\s")

if [ -z "$raw_output" ]; then
    echo "Port $port_input sedang tidak aktif/terbuka."
else
    echo "$raw_output"
    
    # 2. Ekstrak PID secara otomatis
    pid=$(echo "$raw_output" | grep -oE '[0-9]+/[-a-zA-Z0-9_.]+' | head -n1 | cut -d'/' -f1)
    if [ -z "$pid" ]; then
        pid=$(echo "$raw_output" | grep -oE 'pid=[0-9]+' | head -n1 | cut -d'=' -f2)
    fi
    
    if [ -n "$pid" ]; then
        # Lacak Path Binary Utama
        exe_path=$(sudo readlink -f /proc/$pid/exe 2>/dev/null)
        echo "Service Path: $exe_path (PID: $pid)"
        
        # Lacak Command Line penuh (Universal untuk Java, Node, Python, PHP, dll)
        full_cmd=$(sudo cat /proc/$pid/cmdline 2>/dev/null | tr '\0' ' ' | sed 's/[ \t]*$//')
        echo "Cmd Line    : $full_cmd"
        
        # 3. DETEKSI OTOMATIS CONFIG (.conf, .cfg, .ini, .yaml, .xml) YANG SEDANG DIBUKA
        detected_configs=$(echo "$full_cmd" | grep -oE '[^ ]+\.(conf|cfg|ini|yaml|yml|xml|properties)' | sort -u | xargs 2>/dev/null)
        if [ -z "$detected_configs" ]; then
            detected_configs=$(sudo ls -l /proc/$pid/fd 2>/dev/null | grep -oE '/.*\.(conf|cfg|ini|yaml|yml|xml|properties)' | sort -u | xargs)
        fi
        if [ -n "$detected_configs" ]; then
            echo "Config File : $detected_configs"
        fi
        
        # 4. DETEKSI OTOMATIS DOCUMENT ROOT / APP DIR
        detected_root=$(echo "$full_cmd" | grep -oE '(/opt/[a-zA-Z0-9_-]+|/var/www/[a-zA-Z0-9_-]+|/home/[a-zA-Z0-9_-]+/web)' | sort -u | head -n1)
        if [ -z "$detected_root" ]; then
            detected_root=$(sudo readlink -f /proc/$pid/cwd 2>/dev/null)
        fi
        echo "Doc/App Root: $detected_root"
        
    else
        echo "[!] Gagal melacak detail proses (PID tidak terdeteksi)."
    fi
fi
EOF

    # --- INJEKSI CEKIDPEL (VERSI ASLI SESUAI PERSETUJUAN AWAL) ---
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
echo -e "\e[1;36m INSTALASI SUKSES! MEMUAT ULANG KONFIGURASI...    \e[0m"
echo -e "\e[1;32m==================================================\e[0m"

# Trik Sakti: Deteksi sesi terminal interaktif untuk auto-refresh shell
if [ -t 0 ]; then
    exec bash
else
    source "$HOME/.bashrc" 2>/dev/null
fi
