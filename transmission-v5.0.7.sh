#!/bin/sh

# Configuration
#########################################
plugin="transmission"
git_url="https://gitlab.com/eliesat/extensions/-/raw/main/transmission"
version=$(wget $git_url/version -qO- | awk 'NR==1')
plugin_path="/usr/lib/enigma2/python/Plugins/Extensions/Transmission"
package="enigma2-plugin-extensions-$plugin"
targz_file="$plugin.tar.gz"
url="$git_url/$targz_file"
temp_dir="/tmp"

# Determine package manager
#########################################
if command -v dpkg &> /dev/null; then
package_manager="apt"
status_file="/var/lib/dpkg/status"
uninstall_command="apt-get purge --auto-remove -y"
else
package_manager="opkg"
status_file="/var/lib/opkg/status"
uninstall_command="opkg remove --force-depends"
fi

#check and_remove package old version
#########################################
check_and_remove_package() {
if [ -d $plugin_path ]; then
echo "> removing package old version please wait..."
sleep 3 
rm -rf $plugin_path > /dev/null 2>&1
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/TMDB > /dev/null 2>&1

if grep -q "$package" "$status_file"; then
echo "> Removing existing $package package, please wait..."
$uninstall_command $package > /dev/null 2>&1
fi
echo "*******************************************"
echo "*             Removed Finished            *"
echo "*            Uploaded By Eliesat          *"
echo "*******************************************"
sleep 3
exit 1
else
echo " " 
fi  }
check_and_remove_package

#check & install dependencies
#########################################
#check python version
python=$(python -c "import platform; print(platform.python_version())")
sleep 1;
case $python in 
3.12.4|3.12.5|3.12.6)
install_command="opkg install"
$install_command transmission transmission-client python3-transmission-rpc xz python3-core python3-html python3-lxml python3-misc python3-shell python3-treq python3-unixadmin python3-xml > /dev/null 2>&1
;;
*)
echo "> your image python version: $python is not supported"
sleep 3
exit 1
;;
esac

#download & install package
#########################################
download_and_install_package() {
echo "> Downloading $plugin-$version package  please wait ..."
sleep 3
wget --show-progress -qO $temp_dir/$targz_file --no-check-certificate $url
tar -xzf $temp_dir/$targz_file -C / > /dev/null 2>&1
extract=$?
rm -rf $temp_dir/$targz_file >/dev/null 2>&1

if [ $extract -eq 0 ]; then
  echo "> $plugin-$version package installed successfully"
  sleep 3
  echo ""
else
  echo "> $plugin-$version package download failed"
  sleep 3
fi  }
download_and_install_package

# Remove unnecessary files and folders
#########################################
print_message() {
echo "> [$(date +'%Y-%m-%d')] $1"
}
cleanup() {
[ -d "/CONTROL" ] && rm -rf /CONTROL >/dev/null 2>&1
rm -rf /control /postinst /preinst /prerm /postrm /tmp/*.ipk /tmp/*.tar.gz >/dev/null 2>&1
print_message "> Uploaded By ElieSat"
}
cleanup
    
sleep 3
echo "> Setup The Plugin..."
# Configure ajpanel_settings
touch "/tmp/transmission"
cat <<EOF > "/tmp/transmission"
config.plugins.torreplayer.buffer=3
config.plugins.torreplayer.items=12
config.plugins.torreplayer.lastPosition=['link=59d2ae85e627d549e393de83fef9f2ee233f560b&index=1*34361657892*99']
config.plugins.torreplayer.onMovieEof=quit
config.plugins.torreplayer.onMovieStop=quit
config.plugins.torreplayer.poster_path=/media/hdd
config.plugins.torreplayer.rememberlastsearch=True
config.plugins.torreplayer.rememberlastsearchyts=True
config.plugins.torreplayer.rememberlastsearchyts_tv=True
EOF

# Update Enigma2 settings
sed -i '/config.plugins.torreplayer./d' /etc/enigma2/settings
grep "config.plugins.torreplayer.*" "/tmp/transmission" >> /etc/enigma2/settings
rm -rf "/tmp/transmission" >/dev/null 2>&1

sleep 2
echo "> Setup Done..., Please Wait enigma2 restarting..."

# Restart Enigma2 service or kill enigma2 based on the system
if [ "$it" == DreamOS ]; then
    sleep 2
    systemctl restart enigma2
else
    sleep 2
    killall -9 enigma2
fi