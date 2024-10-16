#!/bin/sh
#
cd /tmp
set -e 
 wget "https://raw.githubusercontent.com/Ham-ahmed/Iptv-plugin/refs/heads/main/xcplugin-forever.tar.gz"
wait
tar -xzf xcplugin-forever.tar.gz  -C /
wait
cd ..
set +e
rm -f /tmp/xcplugin-forever.tar.gz
sleep 2;
echo "" 
echo "" 
echo "**********************************************************
echo "#                   INSTALLED SUCCESSFULLY              #"
echo "*                       ON - Panel                      *"
echo "*                Enigma2 restart is required            *"
echo "**********************************************************
echo "               UPLOADED BY  >>>>   HAMDY_AHMED           "
sleep 4;
	echo '====================================================="
###############################################################"                                                                                                                  
echo ". >>>>                   RESTARING                   <<<<"
echo "*********************************************************"
wait
killall -9 enigma2
exit 0