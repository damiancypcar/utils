#!/usr/bin/env bash
# Łączenie audio i video dla CDA.pl Auto Downloader PRO
# https://chromewebstore.google.com/detail/cdapl-auto-downloader-pro/hcmgljglighdllkfifcbnilpmlfnhjmj

clear

count=0
files_found=false

echo "==========================================================="
echo "    CDA.pl Auto Downloader PRO - ŁĄCZENIE AUDIO I VIDEO"
echo "==========================================================="
echo

echo "[1/4] Szukam plików audio_ i video_..."
echo

# Szukanie par audio_* + video_*
shopt -s nullglob

for audio_file in audio_*; do
    [[ -f "$audio_file" ]] || continue

    base_name="${audio_file#audio_}"
    video_file="video_$base_name"

    if [[ -f "$video_file" ]]; then
        ((count++))
        files_found=true

        echo "ZNALEZIONO: $count. $base_name"
    fi
done

shopt -u nullglob

if [[ "$files_found" != true ]]; then
    echo
    echo "BŁĄD: Brak par plików audio/video!"
    echo
    echo "INSTRUKCJA:"
    echo "1. Pobierz z CDA oba pliki:"
    echo "   - audio_nazwapliku.mp4"
    echo "   - video_nazwapliku.mp4"
    echo
    echo "2. Umieść je w tym samym folderze co skrypt"
    echo
    echo "3. Uruchom ponownie skrypt"
    echo

    read -rp "Naciśnij Enter, aby zakończyć..."
    exit 1
fi

echo
echo "[2/4] Znaleziono $count par plików do połączenia!"
echo

read -rp "CZY POŁĄCZYĆ WSZYSTKIE FILMY? (T/N): " confirm

if [[ ! "$confirm" =~ ^[Tt]$ ]]; then
    echo
    echo "Anulowano."
    read -rp "Naciśnij Enter, aby zakończyć..."
    exit 0
fi

echo
echo "[3/4] Tworzę folder 'polaczone_filmy'..."

if [[ ! -d "polaczone_filmy" ]]; then
    mkdir -p "polaczone_filmy"
    echo "Folder utworzony!"
else
    echo "Folder już istnieje!"
fi

echo
echo "[4/4] Łączenie wszystkich filmów..."
echo

processed=0
success=0
failed=0

shopt -s nullglob

for audio_file in audio_*; do
    [[ -f "$audio_file" ]] || continue

    base_name="${audio_file#audio_}"
    video_file="video_$base_name"

    # Pomijamy audio bez odpowiadającego pliku video
    [[ -f "$video_file" ]] || continue

    output_file="polaczone_filmy/$base_name"

    ((processed++))

    echo
    echo "================================================================"
    echo "[$processed/$count] Łączenie: $base_name"
    echo "================================================================"
    echo "Audio: $audio_file"
    echo "Video: $video_file"
    echo

    if ffmpeg \
        -i "$audio_file" \
        -i "$video_file" \
        -c copy \
        "$output_file" \
        -loglevel error \
        -stats
    then
        ((success++))

        echo
        echo "[OK] Połączono pomyślnie!"
    else
        ((failed++))

        echo
        echo "[BŁĄD] Nie udało się połączyć!"
    fi
done

shopt -u nullglob

echo
echo "================================================================"
echo "                       PODSUMOWANIE"
echo "================================================================"
echo "Przetworzono:      $processed filmów"
echo "Sukces:            $success filmów"
echo "Błędy:             $failed filmów"
echo
echo "Połączone filmy są w folderze: polaczone_filmy/"
echo

if (( failed > 0 )); then
    echo "UWAGA: Niektóre pliki nie zostały połączone!"
    echo "Sprawdź czy FFmpeg jest poprawnie zainstalowany."
    echo
fi

echo "Dziękuję za użycie CDA.pl Auto Downloader PRO."
echo
echo "Zachęcam do wsparcia rozwoju tego rozszerzenia."
echo "To dzięki Waszemu wsparciu rozszerzenie jest i będzie wolne od reklam."
echo

read -rp "Naciśnij Enter, aby zakończyć..."
