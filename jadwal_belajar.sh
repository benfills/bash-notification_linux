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

SUARA_BELAJAR="/home/benfills/Downloads/Start Sound.mp3"
SUARA_ISTIRAHAT="/home/benfills/Downloads/Break Sound.mp3"


log_pesan() {
    logger -t "JadwalBelajar" "$1"
    echo "[$(date +'%H:%M:%S')] $1"
}


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

check_sound_files() {
    [ ! -f "$SUARA_BELAJAR" ] && log_pesan "WARNING: File suara belajar tidak ditemukan"
    [ ! -f "$SUARA_ISTIRAHAT" ] && log_pesan "WARNING: File suara istirahat tidak ditemukan"
}


putar_suara() {
    local sound_file="$1"
    
    [ ! -f "$sound_file" ] && return
    
    pkill -f "mpv.*$(basename "$sound_file")"
    
    log_pesan "Memutar suara: $(basename "$sound_file")"
    mpv --volume=70 --no-terminal "$sound_file" >/dev/null 2>&1 &
}

tampilkan_notifikasi() {
    local aktivitas="$1"
    
    notify-send -u critical -a "Jadwal Belajar" "Waktu Belajar" "Sekarang: $aktivitas"
    log_pesan "Notifikasi: $aktivitas"
    
    if [[ "$aktivitas" == *"Istirahat"* ]]; then
        putar_suara "$SUARA_ISTIRAHAT"
    else
        putar_suara "$SUARA_BELAJAR"
    fi
}


main_loop() {
    log_pesan "=== Skrip diaktifkan ==="
    log_pesan "Mode suara: SATU KALI per notifikasi"
    
    while true; do
        current_time=$(date +"%H:%M")
        
        if [ -n "${JADWAL[$current_time]}" ]; then
            aktivitas="${JADWAL[$current_time]}"
            tampilkan_notifikasi "$aktivitas"
            
            sleep 60
        else
            sleep 30
        fi
    done
}


check_dependencies
check_sound_files

sleep 30

main_loop &
