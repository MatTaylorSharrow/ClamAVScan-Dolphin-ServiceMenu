#!/bin/bash

# TODO: script echos new-lines, why?

language=$1
if [ "${language}" == "" ]; then language="en"; fi
lang_l="$(echo ${#language}+2 | bc)"
files_old=$*
IFS="," #new separator instead of spaces
files=${files_old//\ \//,\/} #from " /" to ",/"
version="2.5.5"
title="ClamScan $version"

date="$(date +"%Y-%m-%d_%H-%M-%S")"

kde5="$(which kded5)"; 
if [ -x "$kde5" ]; then 
  spath="$HOME/.local/share/kservices5/"
else 
  path="$(kde4-config --path services)"
  spath="$(echo ${path%:*})"
fi

error_sentence="No files selected." #english

if [ $language = "de" ]; then
  wait="ClamAV scannt, bitte warten."
  not_found="ClamAV ist nicht installiert!"
  scan_sentence="Scannen von Dateien: "
elif [ $language = "en" ]; then
  wait="ClamAV is scanning, please wait."
  not_found="ClamAV is not installed!"
  scan_sentence="Scanning files: "
elif [ $language = "fi" ]; then
  wait="ClamAV tarkistaa valittuja tiedostoja, odota hetki."
  not_found="ClamAV:a ei ole asennettu!"
  scan_sentence="Tiedostojen skannauksen: "
elif [ $language = "fr" ]; then
  wait="ClamAV analyse, veuillez patienter."
  not_found="ClamAV n'est pas installé!"
  scan_sentence="Analyse des fichiers: "
elif [ $language = "id" ]; then
  wait="ClamAV sedang mengecek, silakan tunggu."
  not_found="ClamAV tidak terpasang"
  scan_sentence="Scanning file: "
elif [ $language = "it" ]; then
  wait="ClamAV sta scansionando, attendi per favore."
  not_found="ClamAV non è installato!"
  scan_sentence="Scansione dei file: "
elif [ $language = "ru" ]; then
  wait="ClamAV проводит сканирование. Пожалуйста, подождите."
  not_found="ClamAV не установлен!"
  scan_sentence="Сканирование файлов: "
elif [ $language = "sv" ]; then
  wait="ClamAV skannar, vänta."
  not_found="ClamAV verkar inte vara installerat!"
  scan_sentence="Scanning filer: "
elif [ $language = "tr" ]; then
  wait="ClamAV tarıyor, lütfen bekleyin."
  not_found="ClamAV kurulu değil!"
  scan_sentence="Tarama Dosyaları: "
elif [ $language = "uk" ]; then
  wait="ClamAV проводить сканування. Будь ласка, зачекайте."
  not_found="ClamAV не встановлено!"
  scan_sentence="Сканування файлів: "
elif [ $language = "es" ]; then
  wait="ClamAV está escaneando. Por favor espere..."
  not_found="ClamAV no está instalado!"
  scan_sentence="Comprobando archivos: "
else 
  wait="ClamAV is scanning, please wait."
  not_found="ClamAV is not installed!"
  scan_sentence="Scanning files: "
fi

pid="$(pidof clamd)"
if [ -n "$pid" ]; then
  binary="$(which clamdscan)"
  # fdpass allows clamdscan to run as the local user
  # clamdscan does not accept a "-r" switch for recursing directories
  options="--fdpass"
  multiscan="--multiscan"
else
  binary="$(which clamscan)"
  # check directories recursively
  options="-r"
  multiscan=""
fi

if [ ! -x $binary ]; then
  kdialog --title "$title" --msgbox "$not_found"
  exit 1
fi

log_dir="$spath"ServiceMenus/ClamScan/logs/
if [ ! -d $log_dir ]; then 
  mkdir $log_dir
fi

log_result="$log_dir"ClamScan_result_$date.log
log_temp="$log_dir"ClamScan_$date.log

real_files="$(echo "$files" | cut -c $lang_l-)"
complete_amount="$(find -L $files -type f | wc -l)"
complete_amount_dir="$(find -L $files -type d | wc -l)"

if  [ $complete_amount = "0" ]; then 
  if  [ $complete_amount_dir = "0" ]; then
    echo "$error_sentence" >> "$log_result"
    kdialog --title "$title" --textbox "$log_result" 500 400
    sleep 5
    exit 2
  fi
fi

echo "Result ($binary):" > "$log_result"
## echo $binary $options $multiscan --log="$log_result" --stdout $real_files >> "$log_result"
#background the call to the anti virus checker binary
nohup $binary $options $multiscan --log="$log_result" --stdout $real_files > "$log_temp" 2>&1 &

current_lines="0"

#launch a dialog window, capture id in $progress
progress=$(kdialog --title "$title" --progressbar "$wait $scan_sentence $complete_amount ($complete_amount_dir directories)")
#disable cancel button
qdbus $progress org.kde.kdialog.ProgressDialog.showCancelButton false

IFS=" " 

#loop while the backgrounded process is still running.
while kill -0 $! 2> /dev/null; do
    qdbus $progress Set org.kde.kdialog.ProgressDialog value $current_lines
    current_lines=$(echo $current_lines+1 | bc)
    sleep 1
done

qdbus $progress org.kde.kdialog.ProgressDialog.setLabelText "Finished" 
qdbus $progress org.kde.kdialog.ProgressDialog.close 

if [ ! -f "$log_result" ]; then
  exit 1
fi

## success and tidy up 
kdialog --title "$title" --textbox "$log_result" 500 400
rm "$log_temp" "$log_result"
exit 0
