#!/bin/bash

# CalicoesInstaller.sh
# Copyright (C) 2018 by Pintaudi Giorgio <giorgio-pintaudi-kx@ynu.jp>
# Released under the GPLv3 license
#
#     Pintaudi Giorgio (PhD Student)
#     Yokohama National University
#     giorgio-pintaudi-kx@ynu.jp
#
# This is a bash script that installs the calicoes software
# http://llr.in2p3.fr/sites/pyrame/calicoes/index.html
# along with all its dependencies for the Ubuntu OS. It is an updated
# and corrected version based on the original installation script for CentOS 7.
# The original script can be found and downloaded here:
# http://llr.in2p3.fr/sites/pyrame/calicoes/disclaimer.html
# Credits for the calicoes software and the original version of this script go to
# Frédéric Magniette and Miguel Rubio-Roy.
#
# Anyway, the license of the original script is dubious, being it not
# bundled with the software. Moreover, the license of the software itself is not
# clearly specified anywhere. The README file only contains the line
# "Copyright 2012-2017 Frédéric Magniette, Miguel Rubio-Roy" without
# further specification. This is why I took the liberty to publish it
# using my name.

set -e

ROOTREP="n"
COUCHREP="n"
DIMREP="n"
LEVBDIMREP="n"
LCIOREP="n"
CONTINUE="n"

# Check the Ubuntu release

if [ "`lsb_release -rs`" != "18.04" ];
then
    echo "This installer is for Ubuntu 18.04 only!"
    echo "You can make this script to run also on other versions of Ubuntu"
    echo "by simply replacing the 18.04 string on line 7 with your Ubuntu"
    echo "version but be warned that other modifications may be needed."
    exit 1
fi  

#check if sudo has been used

if [ "`whoami`" == "root" ];
then
    echo "This installer is not intended be run as root or with sudo"
    echo "This doesn't mean that there are no sudo-ed commands INSIDE the script."
    exit 1
fi

# check for selinux
#
#if [ "`grep -c "SELINUX=disabled" /etc/selinux/config`" != "1" ];
#then
#    echo "Selinux is active. This prevents Calicoes from working properly."
#    echo "This operation will need a reboot. Please relaunch the installer"
#    echo "as soon as reboot is completed."
#    echo -n "Do you want this installer to fix the problem? (y|n) : "
#    read REP
#    if [ "${REP}" == "y" ];
#    then
#	echo "SELINUX=disabled" > /etc/selinux/config
#	echo "SELINUXTYPE=targeted" >> /etc/selinux/config
#	#reboot
#	exit 1
#    else
#	echo "Please deactivate Selinux and try this installer again"
#	exit 1
#    fi
#fi

# Check for ROOT
if [ "$ROOTSYS" == "" ];
then
    echo "Root6 is an optional dependency of calicoes."
    echo "It seems that it is not installed (looking for a non null ROOTSYS variable)"
    echo "Maybe you have just forgot to set the root enviroment"
    echo "with the script thisroot.sh. In that case please run that script"
    echo "and then restart this installation process."
    echo "Or maybe ROOT is not installed in your system. In that case this script can"
    echo "take care of the ROOT compiling and installation."
    echo "The total compilation of the sources could take up to an hour."
    echo -n "Do you want this installer to install it? (y|n) : "
    read ROOTREP
    if [ "${ROOTREP}" == "n" ];
    then
	echo -n "Do you want this installer to continue anyway? (y|n) : "
	read CONTINUE
	if [ "${CONTINUE}" == "n" ];
	then
	    exit 1
	else
	    CONTINUE = "" 
	fi
    elif [ "${ROOTREP}" == "y" ];
    then
	echo -n "Set to install it (ROOTREP=\"y\")"
    else
	echo "I didn't understand your answer. Sorry, try again."
	exit 1
    fi
fi

# Check for DIM
if [ ! -d "/usr/local/lib/dim" ];
then
    echo ""
    echo ""
    echo "Dim is an optional dependency of calicoes (only for SDHcal compat)."
    echo "It seems that it is not installed (looking for /usr/local/lib/dim)"
    echo "The total compilation of the sources should take very little time"
    echo -n "Do you want this installer to install it? (y|n) : "
    read DIMREP
    if [ "${DIMREP}" == "n" ];
    then
	echo -n "Do you want this installer to continue anyway? (y|n) : "
	read CONTINUE
	if [ "${CONTINUE}" == "n" ];
	then
	    exit 1
	else
	    CONTINUE = "" 
	fi
    elif [ "${DIMREP}" == "y" ];
    then
	echo -n "Set to install it (DIMREP=\"y\")"
    else
	echo "I didn't understand your answer. Sorry, try again."
	exit 1
    fi
fi

# Check for Liblevbdim
if [ ! -f "/usr/local/lib/dim/liblevbdim.so" ];
then
    echo ""
    echo ""
    echo "Levbdim is an optional dependency of calicoes (only for SDHcal compat)."
    echo "It seems that it is not installed (looking for /usr/local/lib/dim/liblevbdim.so)"
    echo "Be aware that dim is a dependency for levbdim."
    echo "The total compilation of the sources should take very little time"
    echo -n "Do you want this installer to install it? (y|n) : "
    read LEVBDIMREP
    if [ "${LEVBDIMREP}" == "n" ];
    then
	echo -n "Do you want this installer to continue anyway? (y|n) : "
	read CONTINUE
	if [ "${CONTINUE}" == "n" ];
	then
	    exit 1
	else
	    CONTINUE = "" 
	fi
    elif [ "${LEVBDIMREP}" == "y" ];
    then
	echo -n "Set to install it (DIMREP=\"y\")"
    else
	echo "I didn't understand your answer. Sorry, try again."
	exit 1
    fi
fi

# Check for LCIO
if [ ! -d "/opt/lcio" ];
then
    echo ""
    echo ""
    echo "LCIO is an optional dependency of calicoes."
    echo "It seems that it is not installed (looking for /opt/lcio)"
    echo "The total compilation of the sources should some minutes"
    echo -n "Do you want this installer to install it? (y|n) : "
    read LCIOREP
    if [ "${LCIOREP}" == "n" ];
    then
	echo -n "Do you want this installer to continue anyway? (y|n) : "
	read CONTINUE
	if [ "${CONTINUE}" == "n" ];
	then
	    exit 1
	else
	    CONTINUE = "" 
	fi
    elif [ "${LCIOREP}" == "y" ];
    then
	echo -n "Set to install it (DIMREP=\"y\")"
    else
	echo "I didn't understand your answer. Sorry, try again."
	exit 1
    fi
fi

echo ""
echo "Moving to the HOME directory."
cd

#install mandatory dependencies for pyrame and calicoes
if [ ! -f /etc/apt/sources.list.d/apache_couchdb_bionic.list ];
then
    sudo apt-get install curl
    echo "deb https://apache.bintray.com/couchdb-deb bionic main" \
        | sudo tee -a /etc/apt/sources.list.d/apache_couchdb_bionic.list
    curl -L https://couchdb.apache.org/repo/bintray-pubkey.asc \
        | sudo apt-key add -
fi
sudo apt update
sudo apt-get install build-essential python python-dev python-pip psmisc \
     git libsdl1.2-dev libsdl-ttf2.0-dev elog python-sphinx \
     libafterimage-dev flex libexpat1-dev liblua5.2-dev \
     libcurl4 python-progressbar apache2 couchdb r-base \
     couch-libmozjs185-1.0 python-requests libmotif-dev tcsh \
     libxt-dev curl libboost-dev libboost-system-dev \
     libboost-filesystem-dev libboost-thread-dev libjsoncpp-dev \
     libcurl4-gnutls-dev git scons libmongoclient-dev libboost-regex-dev
pip install --upgrade pyserial notify2 argparse couchdb
# If you want to generate the documentation, install also:
pip install --upgrade docutils Pygments 

#install root if necessary
if [ "${ROOTREP}" == "y" ];
then
    echo ""
    echo "-------------------"
    echo "ROOT INSTALLATION"
    echo "-------------------"
    echo "Insert the directory where you want ROOT to be installed."
    echo "Don't insert the trailing slash. For example \"$HOME/Code/ROOT\"."
    echo "This script is not intended to be run as root."
    echo "So please insert a directory that is writable by the current user."
    echo "If you wish to install ROOT in a system directory, please do it manually"
    echo "or just place \"sudo\" in front of every relevant line in this script"
    echo "from line 263 to line 270 (more or less)."
    read ROOTSYS
    if [ -z "$ROOTSYS" ]; then
        mkdir -p ${HOME}/ROOT
        ROOTSYS=${HOME}/ROOT
    fi
    sudo apt-get install build-essential git dpkg-dev cmake xutils-dev \
	 binutils libx11-dev libxpm-dev libxft-dev libxext-dev \
	 libssl-dev libpcre3-dev libglu1-mesa-dev libglew-dev \
	 libmysqlclient-dev libfftw3-dev libcfitsio-dev libgraphviz-dev \
	 libavahi-compat-libdnssd-dev libldap2-dev python-dev libxml2-dev \
	 libkrb5-dev libgsl-dev libqt4-dev libmotif-dev libmotif-common \
	 libblas-dev liblapack-dev xfstt xfsprogs t1-xfree86-nonfree \
	 ttf-xfree86-nonfree ttf-xfree86-nonfree-syriac xfonts-75dpi \
	 xfonts-100dpi libgif-dev libtiff-dev libjpeg-dev liblz4-dev \
	 liblzma-dev libgl2ps-dev libpostgresql-ocaml-dev libsqlite3-dev \
	 libpythia8-dev davix-dev srm-ifce-dev libtbb-dev python-numpy
    cd
    mkdir -p $ROOTSYS/{sources,6-14-02,6-14-02-build}
    cd $ROOTSYS
    git clone http://github.com/root-project/root.git sources
    cd sources
    git checkout -b v6-14-02 v6-14-02
    cd ../6-14-02-build
    cmake -Dbuiltin_xrootd=ON -DCMAKE_INSTALL_PREFIX=$ROOTSYS/6-14-02 ../sources
    cmake --build . --target install -- -j8
    cd
    source $ROOTSYS/6-14-02/bin/thisroot.sh
fi

#install dim if necessary
if [ "${DIMREP}" == "y" ];
then
    echo ""
    echo "-------------------"
    echo "DIM INSTALLATION"
    echo "-------------------"
    cd
    curl -o compileDIM.csh https://gist.githubusercontent.com/MBoretto/d8156bb86c726bcf5014/raw/2940a4480ec79b7ceebdfda912b0bba27e66395e/compileDIM.csh
    sed -i 's/dim_v20r15/dim_v20r23/g' compileDIM.csh
    chmod +x compileDIM.csh
    sudo tcsh -c "./compileDIM.csh"
    cd
fi

#install levbdim if necessary
if [ "${LEVBDIMREP}" == "y" ];
then
    echo ""
    echo "-------------------"
    echo "LEVBDIM INSTALLATION"
    echo "-------------------"
    cd
    git clone http://github.com/mirabitl/levbdim.git levbdim
    cd /tmp
    tar zxf ${HOME}/levbdim/web/mongoose.tgz
    cd mongoose-cpp/
    mkdir -p build/
    cd build/
    rm -rf *
    cp ${HOME}/levbdim/web/CMakeLists.txt ../
    cmake -DEXAMPLES=ON -DWEBSOCKET=OFF -DHAS_JSONCPP=ON ..
    make -j4
    sudo make install
    cd ${HOME}/levbdim
    export DIMDIR="/usr/local/lib/dim"
    sudo ln -s /usr/local/include/dim $DIMDIR/dim
    sudo ln -s $DIMDIR $DIMDIR/linux
    scons
    sudo cp lib/* $DIMDIR/
    cd
fi

#install lcio if necessary
if [ "${LCIOREP}" == "y" ];
then
    echo ""
    echo "-------------------"
    echo "LCIO INSTALLATION"
    echo "-------------------"
    cd
    git clone https://github.com/iLCSoft/LCIO.git lcio
    cd lcio
    git checkout v02-12-01
    mkdir -p build
    cd build
    cmake -DCMAKE_INSTALL_PREFIX=/opt/lcio ..
    # to speed up the building process you can do
    # "cmake --build . -- -jN" where N is the number of available cores
    cmake --build .
    sudo make install
    cd ../..
    rm -rf lcio
fi

# ------------------------ PYRAME --------------------------

# More info on the pyrame installation can be found on this webpage:
# http://llr.in2p3.fr/sites/pyrame/documentation/howto_install.html
echo "-------------------"
echo "PYRAME INSTALLATION"
echo "-------------------"
echo "More info on the pyrame installation can be found on this webpage:"
echo "http://llr.in2p3.fr/sites/pyrame/documentation/howto_install.html"

# download the sources archivefrom the WAGASCI website
echo "Insert the directory where you would like the pyrame tgz archive"
echo "to be downloaded."
echo "Don't insert the trailing slash. For example \"${HOME}/Downloads\"."
echo "Just press OK if you want to download the archive in the $HOME folder."
read PYRAME_DOWNLOAD_DIR
if [ -z "$PYRAME_DOWNLOAD_DIR" ]; then
    PYRAME_DOWNLOAD_DIR=${HOME}
fi

cd "$PYRAME_DOWNLOAD_DIR"
rm -f pyrame*.tgz
curl -o pyrame_1.tgz -k -u b2water:MPPC https://www-he.scphys.kyoto-u.ac.jp/research/Neutrino/WAGASCI/wiki/dokuwiki/lib/exe/fetch.php?media=chikuma:pyrame_1.tgz
curl -o pyrame_2.tgz -k -u b2water:MPPC https://www-he.scphys.kyoto-u.ac.jp/research/Neutrino/WAGASCI/wiki/dokuwiki/lib/exe/fetch.php?media=chikuma:pyrame_2.tgz
curl -o pyrame_3.tgz -k -u b2water:MPPC https://www-he.scphys.kyoto-u.ac.jp/research/Neutrino/WAGASCI/wiki/dokuwiki/lib/exe/fetch.php?media=chikuma:pyrame_3.tgz
cat pyrame_*.tgz > pyrame.tgz
rm -f pyrame_*.tgz
cd

echo "Insert the directory where you would like the pyrame tgz archive"
echo "to be extracted and compiled."
echo "Don't insert the trailing slash. For example \"${HOME}/Code\"."
echo "Just press OK if you want to extract the archive in the ${HOME} folder."
read PYRAME_DIR
if [ -z "$PYRAME_DIR" ]; then
    PYRAME_DIR=${HOME}
fi
PYRAME_TGZ=$PYRAME_DOWNLOAD_DIR/pyrame.tgz

# check for previous installs
if [ -f "${PYRAME_TGZ}" ];
then
    if [ -d "$PYRAME_DIR/pyrame" ];
    then
	cd "$PYRAME_DIR/pyrame"
	sudo -E make uninstall
	cd ..
	sudo rm -rf pyrame
    fi

    # In Debian systems you might need to create links for lua.h and liblua.so
    sudo ln -sf /usr/lib/x86_64-linux-gnu/liblua5.2.so /usr/lib/liblua.so
    sudo ln -sf /usr/include/lua5.2/lua.h /usr/include/lua.h
    sudo ln -sf /usr/include/lua5.2/luaconf.h /usr/include/luaconf.h
    sudo ln -sf /usr/include/lua5.2/lualib.h /usr/include/lualib.h
    sudo ln -sf /usr/include/lua5.2/lauxlib.h /usr/include/lauxlib.h
    
    # estract the pyrame archive in the pyrame compiling folder
    cd "$PYRAME_DIR"
    tar xfz $PYRAME_TGZ
    sudo chown -R $USER:$USER pyrame
    cd pyrame
    
    # we need to fix the permissions of all the pyrame folder
    find ./ -type d -exec chmod 755 "{}" \;
    find ./ -type f -exec chmod 644 "{}" \;
    find ./ -name "*.sh" -exec chmod 755 "{}" \;
    find ./ -name "*.py" -exec chmod 755 "{}" \;

    # download Jojo's patch
    wget https://www.dropbox.com/s/zqnvea0y7q2xfjk/jojo_pyrame_v1.patch
    patch -p1 < jojo_pyrame_v1.patch
    
    # configure and install
    chmod +x ./configure
    ./configure
    make
    sudo -E make install
    
    # make documentation
    cd docs
    sudo -E make install
    
    # install and enable apache2 
    sudo ${PYRAME_DIR}/pyrame/xhr/install_xhr_debian8_apache2.sh
    sudo systemctl restart apache2
    sudo systemctl enable apache2
    
    # The following command is equivalent to
    # echo 1 > sudo tee /proc/sys/net/ipv4/tcp_tw_recycle
    # echo 1 > sudo tee /proc/sys/net/ipv4/tcp_fin_timeout
    sudo cp -f ${PYRAME_DIR}/pyrame/launcher/99-pyrame.conf /etc/sysctl.d/
else
    echo "pyrame.tgz not found (PYRAME_TGZ=${PYRAME_TGZ})"
    exit 1
fi

# --------------------- CALICOES ---------------------

# More info on the calicoes installation can be found on this webpage:
# http://llr.in2p3.fr/sites/pyrame/calicoes/documentation/install.html

echo "-------------------"
echo "CALICOES INSTALLATION"
echo "-------------------"
echo "More info on the calicoes installation can be found on this webpage:"
echo "http://llr.in2p3.fr/sites/pyrame/calicoes/documentation/install.html"

# download the sources archivefrom the WAGASCI website
echo "Insert the directory where you would like the calicoes tgz archive"
echo "to be downloaded."
echo "Don't insert the trailing slash. For example \"${HOME}/Downloads\"."
echo "Just press OK if you want to download the archive in the $HOME folder."
read CALICOES_DOWNLOAD_DIR
if [ -z "$CALICOES_DOWNLOAD_DIR" ]; then
    CALICOES_DOWNLOAD_DIR=${HOME}
fi

cd "$CALICOES_DOWNLOAD_DIR"
rm -f calicoes*.tgz
curl -o calicoes_1.tgz -k -u b2water:MPPC https://www-he.scphys.kyoto-u.ac.jp/research/Neutrino/WAGASCI/wiki/dokuwiki/lib/exe/fetch.php?media=chikuma:calicoes_1.tgz
curl -o calicoes_2.tgz -k -u b2water:MPPC https://www-he.scphys.kyoto-u.ac.jp/research/Neutrino/WAGASCI/wiki/dokuwiki/lib/exe/fetch.php?media=chikuma:calicoes_2.tgz
curl -o wagasci_config.tgz -k -u b2water:MPPC https://www-he.scphys.kyoto-u.ac.jp/research/Neutrino/WAGASCI/wiki/dokuwiki/lib/exe/fetch.php?media=chikuma:wagasci_config.tgz
cat calicoes_*.tgz > calicoes.tgz
rm -f calicoes_*.tgz
cd

echo "Insert the directory where you would like the calicoes tgz archive"
echo "to be extracted and compiled."
echo "Don't insert the trailing slash. For example \"${HOME}/Code\"."
echo "Just press OK if you want to extract the archive in the ${HOME} folder."
read CALICOES_DIR
if [ -z "$CALICOES_DIR" ]; then
    CALICOES_DIR=${HOME}
fi
CALICOES_TGZ=${CALICOES_DOWNLOAD_DIR}/calicoes.tgz

# check for previous installs
if [ -f "${CALICOES_TGZ}" ];
then
    if [ -d "${CALICOES_DIR}/calicoes" ];
    then
	cd "${CALICOES_DIR}/calicoes"
	sudo make uninstall
	cd ..
	sudo rm -rf calicoes
    fi
    
    # extract the archive
    cd "${CALICOES_DIR}"
    tar xfz "${CALICOES_TGZ}"
    sudo chown -R $USER:$USER calicoes
    cd calicoes
    
    # we need to fix the permissions of all the calicoes folder
    find ./ -type d -exec chmod 755 "{}" \;
    find ./ -type f -exec chmod 644 "{}" \;
    find ./ -name "*.sh" -exec chmod 755 "{}" \;
    
    # patch calicoes
    wget https://www.dropbox.com/s/wht71ataou7jdey/jojo_calicoes_v1.patch
    patch -p1 < jojo_calicoes_v1.patch

    # compile and install
    sudo ./install.sh
    make
    sudo make install
    
    # install documentation   
    cd docs/documentation
    make
    sudo mkdir -p /opt/calicoes/doc
    sudo make install
    rm -rf /tmp/calicoes.tgz
    cd
else
    echo "No calicoes.tgz file referred to. ${CALICOES_TGZ}"
    exit 1
fi


echo "Post-configuration..."
cd
sudo cp /opt/couchdb/etc/local.ini /opt/couchdb/etc/local.ini.backup
sudo chown couchdb:couchdb /opt/couchdb/etc/local.ini.backup
sudo sed -i '/\[httpd\]/a socket_options = [{nodelay, true}]' /opt/couchdb/etc/local.ini
# wget https://www.dropbox.com/s/tpmb3cgoqf8w7zg/couchdb-default.ini
# sudo mv /opt/couchdb/etc/default.ini /opt/couchdb/etc/default.ini.backup
# sudo cp couchdb-default.ini /opt/couchdb/etc/default.ini
# sudo chown couchdb:couchdb /opt/couchdb/etc/default.ini
# sudo chmod 640 /opt/couchdb/etc/default.ini
# rm couchdb-default.ini
if [ ! -L "/var/www/html/phygui_rc" ];
then
    sudo ln -s /opt/calicoes/phygui_rc /var/www/html/phygui_rc
fi

sudo systemctl enable couchdb
sudo systemctl restart couchdb
sudo systemctl enable pyrame
sudo systemctl restart pyrame

sleep 2s
sensible-browser http://localhost/phygui_rc &

echo "Installation successfully completed! Thanks for using Calicoes"
echo "For any questions about this script please contact:"
echo "Pintaudi Giorgio (PhD Student)"
echo "Yokohama National University"
echo "giorgio-pintaudi-kx@ynu.jp"

exit 0

# CalicoesInstaller.sh
#
# Copyright (C) 2018 by Pintaudi Giorgio <giorgio-pintaudi-kx@ynu.jp>
# Released under the GPLv3 license
#
#     Pintaudi Giorgio (PhD Student)
#     Yokohama National University
#     giorgio-pintaudi-kx@ynu.jp
