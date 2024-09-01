#!/bin/sh

# URL of the tar.xz file
URL="http://dreambox4u.com/dreamarabia/Transmission/Transmission.tar.xz"

# Directory to install the plugin (root directory in this case, since paths are absolute in the tar file)
INSTALL_DIR="/"

# Required version of Transmission
REQUIRED_VERSION="4.0.6-1"

# Function to compare versions
version_compare() {
  [ "$1" = "$2" ] && return 0
  local IFS=.
  local i ver1=($1) ver2=($2)
  for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
    ver1[i]=0
  done
  for ((i=0; i<${#ver1[@]}; i++)); do
    if [[ -z ${ver2[i]} ]]; then
      ver2[i]=0
    fi
    if ((10#${ver1[i]} > 10#${ver2[i]})); then
      return 1
    fi
    if ((10#${ver1[i]} < 10#${ver2[i]})); then
      return 2
    fi
  done
  return 0
}

# Check if transmission is installed
INSTALLED_VERSION=$(opkg list-installed | grep "^transmission " | awk '{print $3}')

if [ -n "$INSTALLED_VERSION" ]; then
  # Compare installed version with required version
  version_compare "$INSTALLED_VERSION" "$REQUIRED_VERSION"
  case $? in
    0) echo "Required version of Transmission ($REQUIRED_VERSION) is already installed. Proceeding with additional installation."
       ;;
    1) echo "A newer version of Transmission ($INSTALLED_VERSION) is already installed. Proceeding with additional installation."
       ;;
    2) echo "A lower version of Transmission ($INSTALLED_VERSION) is installed. Aborting installation."
       exit 1
       ;;
  esac
else
  echo "Transmission is not installed. Aborting installation."
  exit 1
fi

# Download the tar.xz file to the /tmp directory
echo "Downloading new files."
wget --no-check-certificate -O /tmp/Transmission.tar.xz "$URL"

# Check if the download was successful
if [ $? -ne 0 ]; then
  echo "Failed to download the file."
  exit 1
fi
echo "removing old files."
if [ -f '/tmp/Transmission.tar.xz' ]; then
	rm -rf /usr/lib/enigma2/python/Plugins/Extensions/Transmission > /dev/null 2>&1
fi

sleep 2
# Extract the tar.xz file to the root directory, preserving the directory structure
echo "Extracting files."
tar --overwrite -xJf /tmp/Transmission.tar.xz -C "$INSTALL_DIR"

# Check if the extraction was successful
if [ $? -ne 0 ]; then
  echo "Failed to extract the file."
  exit 1
fi

# Clean up by removing the downloaded tar.xz file
rm /tmp/Transmission.tar.xz

echo "Plugin installed successfully!"
