#!/usr/bin/env bash
#
# Works with Ubuntu 16.04
#
if [[ ! -f /usr/lib/debug/boot/vmlinux-$(uname -r) ]]; then
    DDEBS_LIST=/etc/apt/sources.list.d/ddebs.list
    if [[ ! -f ${DDEBS_LIST} ]]; then
        echo "deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse" | sudo tee -a ${DDEBS_LIST}
        echo "deb http://ddebs.ubuntu.com $(lsb_release -cs)-updates main restricted universe multiverse" | sudo tee -a ${DDEBS_LIST}
#        echo "deb http://ddebs.ubuntu.com $(lsb_release -cs)-proposed main restricted universe multiverse" | sudo tee -a ${DDEBS_LIST}
        wget -O - http://ddebs.ubuntu.com/dbgsym-release-key.asc | sudo apt-key add -
    fi
    echo "Downloading kernel symbol could take long time (e.g. 30 mins)."
    read -p "Are you ready to start (y/N)? " ANSWER
    if [[ ( $? -eq 0 ) && ( ( "${ANSWER}" = "y" ) || ( "${ANSWER}" = "Y" ) ) ]]; then
        sudo apt update -y
        sudo apt install -y linux-image-$(uname -r)-dbgsym
        echo "Kernel symbol is successfully installed."
    fi
fi
