#!/bin/bash

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

SUARA_UMUM="/home/benfills/Downloads/Start Sound.mp3"
SUARA_ISTIRAHAT="/home/benfills/Downloads/Break Sound.mp3"

log_pesan() {
    logger -t "JadwalBelajar" "$1"
    echo "$1"
}

if ! command -v notify-send &> /dev/null; then
    log_pesan "ERROR: 'notify-send' tidak ditemukan. Instal paket libnotify-bin."
    exit 1
fi

if ! command -v mpv &> /dev/null; then
    log_pesan "ERROR: 'mpv' tidak ditemukan. Instal paket mpv."
    echo "SOLUSI: sudo apt install mpv"
    exit 1
fi

if [ ! -f "$SUARA_UMUM" ]; then
    log_pesan "WARNING: File suara umum tidak ditemukan: $SUARA_UMUM"
fi
if [ ! -f "$SUARA_ISTIRAHAT" ]; then
    log_pesan "WARNING: File suara istirahat tidak ditemukan: $SUARA_ISTIRAHAT"
fi

putar_suara() {
    local file_suara="$1"
    
    if [ -f "$file_suara" ]; then
        for ((i=0; i<3; i++)); do
            
            mpv --volume=70 --no-terminal "$file_suara" >/dev/null 2>&1 &
            sleep 0.5  
        done
    else
        log_pesan "ERROR: File suara tidak ditemukan: $file_suara"
    fi
}

tampilkan_notifikasi() {
    local aktivitas="$1"
    
    
    notify-send -u critical -a "Jadwal Belajar" "Waktu Belajar" "Sekarang: $aktivitas"
    
    
    if [[ "$aktivitas" == *"Istirahat"* ]]; then
        putar_suara "$SUARA_ISTIRAHAT"
    else
        putar_suara "$SUARA_UMUM"
    fi
}

(
    
    sleep 30

    log_pesan "Skrip Jadwal Belajar diaktifkan"
    log_pesan "Menggunakan suara kustom:"
    log_pesan "- Umum: $SUARA_UMUM"
    log_pesan "- Istirahat: $SUARA_ISTIRAHAT"

    while true; do
        WAKTU_SEKARANG=$(date +"%H:%M")
        
        
        if [ -n "${JADWAL[$WAKTU_SEKARANG]}" ]; then
            AKTIVITAS="${JADWAL[$WAKTU_SEKARANG]}"
            
            
            tampilkan_notifikasi "$AKTIVITAS"
            log_pesan "Notifikasi: $AKTIVITAS"
            
            
            sleep 60
        fi
        
        
        sleep 30
    done
) &