
#!/bin/bash

# AnpanAdditionalSoftware.sh
# Copyright (C) 2018 by Pintaudi Giorgio <giorgio-pintaudi-kx@ynu.jp>
# Released under the GPLv3 license
#
#     Pintaudi Giorgio (PhD Student)
#     Yokohama National University
#     giorgio-pintaudi-kx@ynu.jp
#

set -e

UBUNTU="n"
CENTOS="n"

function isinstalled {
    if [ $CENTOS == "y" ];
    then
		if yum list installed "$@" >/dev/null 2>&1; then
			true
		else
			false
		fi
    elif [ $UBUNTU == "y" ];
    then
		dpkg -s $1 &> /dev/null
		if [ $? -eq 0 ]; then
			true
		else
			false
		fi
    fi
}

# Check the Ubuntu and CentOS releases

if [ ! -f "/usr/bin/lsb_release" ] && [ ! -f "/etc/redhat-release" ];
then
    echo ""
    echo "This installer is for Ubuntu 18.04 and CentOS 7 only!"
    echo "You can get this script to run also on other versions of Ubuntu"
    echo "by simply replacing the 18.04 string on line 70 with your Ubuntu"
    echo "version but be warned that other modifications may be needed."
    echo ""
    exit 1
fi

if [ -f "/usr/bin/lsb_release" ] && [ "`lsb_release -rs`" == "18.04" ];
then
    UBUNTU="y"
    CMAKE=cmake
elif [ -f "/etc/redhat-release" ];
then
    CENTOS="y"
    CMAKE=cmake3
    CENTOS_ROOT_FLAGS="-DENVOY_IGNORE_GLIBCXX_USE_CXX11_ABI_ERROR=1 -Wno-dev"
else
    echo "There is something wrong about OS detection."
    echo "UBUNTU = $UBUNTU"
    echo "CENTOS = $CENTOS"
    echo ""
    exit 1
fi

#check if sudo has been used

if [ "`whoami`" == "root" ];
then
    echo ""
    echo "This installer is not intended be run as root or with sudo"
    echo "You will need to insert the user password AFTER the script has started."
    echo ""
    exit 1
fi

if [ $CENTOS == "y" ];
then
	sudo yum install epel-release
	sudo yum install python2-pip python36-pip
	sudo -H pip install --upgrade pip

	# xpra
	if ! isinstalled xpra;
	then
		sudo yum install opencv-python numpy python2-numpy python36-numpy \
			 python-websockify
		sudo -H pip install --upgrade pillow pypng
		wget https://xpra.org/repos/CentOS/xpra.repo
		sudo cp -f xpra.repo /etc/yum.repos.d/
		rm -f xpra.repo
		sudo yum install xpra
	fi

	# wireshark
	if ! isinstalled wireshark-gnome;
	then
		sudo yum install wireshark-gnome
		sudo usermod -a -G wireshark $USER
	fi

	# nmap
	sudo yum install nmap

	# borg
	sudo yum install openssl-devel libacl-devel
	sudo yum install python36 python36-setuptools python36-pip python36-devel
	sudo ln -s /usr/local/bin/pip3 /usr/bin/pip3
	sudo pip3 install --upgrade pip
	sudo pip3 install --upgrade borgbackup

elif [ $UBUNTU == "y" ];
then
	echo ""
	echo "Still nothing to do"
	echo""
fi

# phpseclib
sudo apt-get install php-pgsql php-pear
sudo pear channel-discover phpseclib.sourceforge.net
sudo pear remote-list -c phpseclib
sudo pear install phpseclib/Net_SSH2

exit 0
