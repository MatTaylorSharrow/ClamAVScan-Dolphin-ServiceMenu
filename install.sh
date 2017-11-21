#!/bin/sh

# PART 1
# make dir /home/$USER/.kde/share/kde4/services/ServiceMenus/ClamScan
# and /home/$USER/.kde/share/kde4/services/ServiceMenus/ClamScan/logs/
#
# copy ClamScan.desktop and ClamScan.sh to /home/$USER/.kde/share/kde4/services/ServiceMenus/ClamScan
kde5="$(which kded5)"; 
if [ -x "$kde5" ]; then 
  desktop=ClamScan.desktop
  spath="$HOME/.local/share/kservices5/"
else 
  desktop=ClamScan.kde4.desktop
  path="$(kde4-config --path services)"
  spath="$(echo ${path%:*})"
fi

mkdir -p "$spath"ServiceMenus/ClamScan
mkdir -p "$spath"ServiceMenus/ClamScan/logs

cp $desktop "$spath"ServiceMenus/ClamScan/
cp ClamScan.sh "$spath"ServiceMenus/ClamScan/

if echo "$spath" | grep '/.kde/share/kde4/services/' > /dev/null; 
  then :
  else sed -i -e "s;~/.kde/share/kde4/services/;$spath;g" "$spath"ServiceMenus/ClamScan/ClamScan.desktop; 
fi

# PART 2
# Copy ClamScan_action.desktop to /home/$USER/.kde/share/apps/solid/actions/
if [ ! -x "$kde5" ]; then 
  path2="$(kde4-config --localprefix)share/apps/solid/actions"
  if [ ! -d $path2 ]; then 
	mkdir -p "$path2"
  fi

  cp ClamScan_action.desktop $path2
fi