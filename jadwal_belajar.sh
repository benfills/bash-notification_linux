#!/bin/bash

# =======================================================
# SKRIP JADWAL BELAJAR DENGAN SUARA KUSTOM (FIXED)
# =======================================================
# Penulis: DeepSeek-R1
# Tanggal: 2025-06-06
# Versi: 1.5
# Perbaikan:
#   - Memastikan suara hanya dimainkan sekali
#   - Manajemen proses background yang lebih baik
#   - Penanganan file suara dengan spasi
# =======================================================

# -------------------------------
# PENGATURAN UTAMA
# -------------------------------

# Daftar jadwal
declare -A JADWAL=(
    ["08:00"]="Belajar Full Stack Development"
    ["10:00"]="Istirahat"
    ["10:15"]="Belajar Cybersecurity"
    ["12:15"]="Istirahat dan makan siang"
    ["13:15"]="Proyek Praktik (Integrasi Kedua Bidang)"
    ["15:15"]="Istirahat"
    ["15:30"]="Review Materi dan Latihan Soal"
    ["17:30"]="Refleksi dan Perencanaan Hari Berikut"
)

# File suara kustom (dengan penanganan path yang mengandung spasi)
SUARA_BELAJAR="/home/benfills/Downloads/Start Sound.mp3"
SUARA_ISTIRAHAT="/home/benfills/Downloads/Break Sound.mp3"

# -------------------------------
# FUNGSI LOGGING
# -------------------------------

log_pesan() {
    logger -t "JadwalBelajar" "$1"
    echo "[$(date +'%H:%M:%S')] $1"
}

# -------------------------------
# PENGECEKAN & INISIALISASI
# -------------------------------

# Cek dependensi
check_dependencies() {
    local missing=0
    
    if ! command -v notify-send &> /dev/null; then
        log_pesan "ERROR: 'notify-send' tidak ditemukan. Instal: sudo apt install libnotify-bin"
        missing=1
    fi
    
    if ! command -v mpv &> /dev/null; then
        log_pesan "ERROR: 'mpv' tidak ditemukan. Instal: sudo apt install mpv"
        missing=1
    fi
    
    [ $missing -eq 1 ] && exit 1
}

# Cek file suara
check_sound_files() {
    [ ! -f "$SUARA_BELAJAR" ] && log_pesan "WARNING: File suara belajar tidak ditemukan"
    [ ! -f "$SUARA_ISTIRAHAT" ] && log_pesan "WARNING: File suara istirahat tidak ditemukan"
}

# -------------------------------
# FUNGSI UTAMA
# -------------------------------

# Fungsi untuk memutar suara (sekali saja)
putar_suara() {
    local sound_file="$1"
    
    # Pastikan file ada
    [ ! -f "$sound_file" ] && return
    
    # Hentikan pemutaran sebelumnya jika masih berjalan
    pkill -f "mpv.*$(basename "$sound_file")"
    
    # Putar suara baru (dengan penanganan path ber-spasi)
    log_pesan "Memutar suara: $(basename "$sound_file")"
    mpv --volume=70 --no-terminal "$sound_file" >/dev/null 2>&1 &
}

# Fungsi notifikasi
tampilkan_notifikasi() {
    local aktivitas="$1"
    
    # Tampilkan notifikasi
    notify-send -u critical -a "Jadwal Belajar" "Waktu Belajar" "Sekarang: $aktivitas"
    log_pesan "Notifikasi: $aktivitas"
    
    # Tentukan suara berdasarkan aktivitas
    if [[ "$aktivitas" == *"Istirahat"* ]]; then
        putar_suara "$SUARA_ISTIRAHAT"
    else
        putar_suara "$SUARA_BELAJAR"
    fi
}

# -------------------------------
# LOOP UTAMA
# -------------------------------

main_loop() {
    log_pesan "=== Skrip diaktifkan ==="
    log_pesan "Mode suara: SATU KALI per notifikasi"
    
    while true; do
        current_time=$(date +"%H:%M")
        
        if [ -n "${JADWAL[$current_time]}" ]; then
            aktivitas="${JADWAL[$current_time]}"
            tampilkan_notifikasi "$aktivitas"
            
            # Tunggu 60 detik untuk hindari duplikasi
            sleep 60
        else
            # Tunggu lebih singkat jika tidak ada jadwal
            sleep 30
        fi
    done
}

# -------------------------------
# EKSEKUSI PROGRAM
# -------------------------------

# Jalankan pengecekan
check_dependencies
check_sound_files

# Tunggu 30 detik setelah login
sleep 30

# Jalankan loop utama di background
main_loop &
