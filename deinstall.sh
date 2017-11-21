#!/bin/sh
kde5="$(which kded5)"; 
if [ -x "$kde5" ]; then 
  desktop=ClamScan.desktop
  spath="$HOME/.local/share/kservices5/"
else 
  desktop=ClamScan.kde4.desktop
  path="$(kde4-config --path services)"
  spath="$(echo ${path%:*})"
fi

rm "$spath"ServiceMenus/ClamScan/ClamScan.desktop
rm "$spath"ServiceMenus/ClamScan/ClamScan.sh
rm -r "$spath"ServiceMenus/ClamScan/

if [ ! -x "$kde5" ]; then 
  path2="$(kde4-config --localprefix)share/apps/solid/actions"
  rm $path2/ClamScan_action.desktop
fi