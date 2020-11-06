
#!/bin/bash

# AnpanInstaller.sh
# Copyright (C) 2018 by Pintaudi Giorgio <giorgio-pintaudi-kx@ynu.jp>
# Released under the GPLv3 license
#
#     Pintaudi Giorgio (PhD Student)
#     Yokohama National University
#     giorgio-pintaudi-kx@ynu.jp
#
# This is a bash script that installs the ANPAN software framework
# along with all its dependencies for the Ubuntu OS.  Credits for the
# calicoes and pyrame software and the original version of this script
# go to Frédéric Magniette and Miguel Rubio-Roy.

set -e

ROOTREP="n"
PYRAMEREP=""
ANPANREP=""
MIDASREP=""
CONTINUE="n"
UBUNTU="n"
DEBIAN="n"
CENTOS="n"
ROOTVERS="6-22-00"
EXPERIMENT_NAME="WAGASCI"

# Define a function that checks if a package is installed

isinstalled () {
    if [ $CENTOS = "y" ];
    then
        if yum list installed "$@" >/dev/null 2>&1; then
            true
        else
            false
        fi
    elif [ $UBUNTU = "y" ];
    then
        if ! dpkg -s "$1" > /dev/null 2>&1
        then
            true
        else
            false
        fi
    fi
}

# ---------------------------------------------------------------------------------- #
#                                                                                    #
#                               SCRIPT START                                         #
#                                                                                    #
# ---------------------------------------------------------------------------------- #

# Check the Ubuntu and CentOS releases
if [ ! -f "/usr/bin/lsb_release" ] && [ ! -f "/etc/redhat-release" ];
then
    echo ""
    echo "This installer is for Ubuntu 18.04/20.04, Debian 9 and CentOS 7 only!"
    echo "You can get this script to run also on other distos by modifying it a"
    echo "little but in that cas you are on your own"
    echo ""
    exit 1
fi

if [ -f "/usr/bin/lsb_release" ] && [ "$(lsb_release -rs)" = "9.12" ];
then
    UBUNTU="y"
    DEBIAN="y"
    CMAKE=cmake
elif [ -f "/usr/bin/lsb_release" ] && { [ "$(lsb_release -rs)" = "18.04" ] ||
                                            [ "$(lsb_release -rs)" = "20.04" ]; };
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
    echo "DEBIAN = $DEBIAN"
    echo "CENTOS = $CENTOS"
    echo ""
    exit 1
fi

#check if sudo has been used

if [ "$(whoami)" = "root" ];
then
    echo ""
    echo "This installer is not intended be run as root or with sudo"
    echo "You will need to insert the user password AFTER the script has started."
    echo ""
    exit 1
fi

if [ $CENTOS = "y" ];
then
    # check for selinux

    if [ "$(grep -c "SELINUX=disabled" /etc/selinux/config)" != "1" ];
    then
        echo ""
        echo "SElinux is active. This prevents Anpan from working properly."
        echo "This operation will need a reboot. Please relaunch the installer"
        echo "as soon as reboot is completed."
        echo "Do you want this installer to fix the problem? (y|n) : "
        read -r REP
        if [ "${REP}" = "y" ];
        then
            sudo cp /etc/selinux/config /etc/selinux/config.backup
            sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
            sudo sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config
            echo ""
            echo "Please reboot and restart the script."
            echo ""
            exit 1
        else
            echo ""
            echo "Please deactivate Selinux and try this installer again"
            exit 1
        fi
    fi
fi

# Check for ROOT
if [ -z "${ROOTSYS}" ] && [ ! -f "/usr/bin/root" ];
then
    echo ""
    echo "ROOT is a dependency of ANPAN but it seems that it is not installed"
    echo "(looking for a non null ROOTSYS variable or the /usr/bin/root file)."
    echo "Maybe you have just forgotten to set up the root enviroment with the"
    echo "script thisroot.sh."
    echo "In that case please run that script and then restart the installation."
    echo ""
    echo "If ROOT is not installed in your system, this script can take care of"
    echo "the ROOT installation. In CentOS ROOT can be either installed from"
    echo "repositories or compiled from source. Compiling it could take up to"
    echo "an hour. You will be asked which way you prefer to install ROOT later."
    echo ""
    echo "Do you want this installer to install ROOT? (y|n) : "
    read -r ROOTREP
    if [ "${ROOTREP}" = "n" ];
    then
        echo "Do you want this installer to continue anyway? (y|n) : "
        read -r CONTINUE
        if [ "${CONTINUE}" = "n" ];
        then
            exit 1
        else
            CONTINUE="" 
        fi
    elif [ "${ROOTREP}" = "y" ];
    then
        echo "Set to install it (ROOTREP=\"y\")"
    else
        echo "I didn't understand your answer. Sorry, try again."
        exit 1
    fi
fi

# Check for MIDASREP
if [ -z "${MIDASREP}" ];
then
    if [ ! -d "/opt/midas" ] && [ -z "${MIDASSYS}" ];
    then
        echo ""
        echo ""
        echo "MIDAS is a dependency of ANPAN. It seems that it is not installed"
        echo "in the default location (looking for the folder /opt/midas) or the"
        echo "MIDASSYS variable is not set. Perhaps it is installed somewhere else."
        echo "Do you want this installer to install it? (y|n) : "
        read -r MIDASREP
        if [ "${MIDASREP}" = "n" ];
        then
            echo "Do you want this installer to continue anyway? (y|n) : "
            read -r CONTINUE
            if [ "${CONTINUE}" = "n" ];
            then
                exit 1
            else
                CONTINUE=""
            fi
        elif [ "${MIDASREP}" = "y" ];
        then
            echo "Set to install it (MIDASREP=\"y\")"
        else
            echo "I didn't understand your answer. Sorry, try again."
            exit 1
        fi
    fi
fi

# Check for PYRAMEREP
if [ -z "${PYRAMEREP}" ];
then
    if [ ! -d "/opt/pyrame" ];
    then
        echo ""
        echo ""
        echo "Pyrame is a dependency of ANPAN. It seems that it is not installed"
        echo "in the default location (looking for the folder /opt/pyrame)."
        echo "But perhaps it is installed somewhere else."
        echo "Do you want this installer to install it? (y|n) : "
        read -r PYRAMEREP
        if [ "${PYRAMEREP}" = "n" ];
        then
            echo "Do you want this installer to continue anyway? (y|n) : "
            read -r CONTINUE
            if [ "${CONTINUE}" = "n" ];
            then
                exit 1
            else
                CONTINUE=""
            fi
        elif [ "${PYRAMEREP}" = "y" ];
        then
            echo "Set to install it (PYRAMEREP=\"y\")"
        else
            echo "I didn't understand your answer. Sorry, try again."
            exit 1
        fi
    fi
fi

# Check for ANPANREP
if [ -z "${ANPANREP}" ];
then
    if [ ! -d "/opt/anpan" ];
    then
        echo ""
        echo ""
        echo "It seems that the ANPAN core is not installed in the default "
	echo "location (looking for the folder /opt/anpan)."
        echo "But perhaps it is installed somewhere else."
        echo "Do you want this installer to install it? (y|n) : "
        read -r ANPANREP
        if [ "${ANPANREP}" = "n" ];
        then
            echo "Do you want this installer to continue anyway? (y|n) : "
            read -r CONTINUE
            if [ "${CONTINUE}" = "n" ];
            then
                exit 1
            else
                CONTINUE=""
            fi
        elif [ "${ANPANREP}" = "y" ];
        then
            echo "Set to install it (ANPANREP=\"y\")"
        else
            echo "I didn't understand your answer. Sorry, try again."
            exit 1
        fi
    fi
fi

echo ""
echo ""
echo "Moving to the HOME directory."
echo "Installing some preliminary packages to meet dependences."
echo ""
cd

#install mandatory dependencies for pyrame and anpan
if [ $DEBIAN = "y" ];
then

    sudo apt-get install -y apt-transport-https ca-certificates libc-bin
    
    if [ ! -f /etc/apt/sources.list.d/picoscope.list ];
    then
        sudo bash -c 'echo "deb https://labs.picotech.com/debian/ picoscope main" >/etc/apt/sources.list.d/picoscope.list'
        wget -O - https://labs.picotech.com/debian/dists/picoscope/Release.gpg.key | sudo apt-key add -
    fi
    sudo apt-get update
    sudo apt-get install -y libpl1000
    sudo ldconfig
    
fi

if [ $UBUNTU = "y" ];
then
    if [ ! -f /etc/apt/sources.list.d/apache_couchdb_bionic.list ];
    then
        sudo apt-get install -y curl
        if [ "$(lsb_release -rs)" = "18.04" ]; then
            echo "deb https://apache.bintray.com/couchdb-deb bionic main" \
                | sudo tee -a /etc/apt/sources.list.d/apache_couchdb_bionic.list
            curl -L https://couchdb.apache.org/repo/bintray-pubkey.asc \
                | sudo apt-key add -
        elif [ "$(lsb_release -rs)" = "20.04" ]; then
            echo "deb https://apache.bintray.com/couchdb-deb focal main" \
                | sudo tee -a /etc/apt/sources.list.d/couchdb.list
            sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys \
                 8756C4F765C9AC3CB6B85D62379CE192D401AB61
        fi
    fi

    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install -y build-essential python python-dev python-pip psmisc \
         git libsdl1.2-dev libsdl-ttf2.0-dev elog python-sphinx libafterimage-dev \
         flex libexpat1-dev liblua5.2-dev python-progressbar apache2 autoconf \
         r-base python-requests libmotif-dev tcsh libxt-dev curl libboost-dev \
         libboost-system-dev libboost-filesystem-dev libboost-thread-dev \
         libjsoncpp-dev libcurl4-gnutls-dev scons libmongoclient-dev \
         libboost-regex-dev xorg-dev libboost-program-options-dev unzip \
         libssl-dev libusb-0.1-4 libusb-dev python-docutils python-pygments \
         python-pyvisa-py python-notify2 python-serial python-distro python-lxml \
         python-future python-couchdb
         

    # The CouchDB installation in Ubuntu is a bit more delicate.
    if isinstalled "couchdb";
    then
        echo ""
        echo "couchdb is already installed";
    else
        echo ""
        echo "If you choose \"couchdb\" as the administrator password you do not"
        echo "need to do anything else. Otherwise substitute admin:couchdb with"
        echo "admin:yourpassword in the launcher/services.txt file."
        read -r "Press Enter to continue ..."
        sudo apt-get install -y couchdb
    fi

    # Install some python2 packages
    sudo -H python2 -m pip install --upgrade pip
    sudo -H python2 -m pip install --upgrade argparse arduinoserial

elif [ $CENTOS = "y" ];
then
    # Install CouchDB repository if it is not present
    if [ ! -f /etc/yum.repos.d/couchdb.repo ];
    then
        sudo tee /etc/yum.repos.d/couchdb.repo << 'EOF'
[bintray--apache-couchdb-rpm]
name=bintray--apache-couchdb-rpm
baseurl=http://apache.bintray.com/couchdb-rpm/el$releasever/$basearch/
gpgcheck=0
repo_gpgcheck=0
enabled=1
EOF
    fi
    
    # The latest picoscope version is not compatible with CentOS 7 anymore
    # The last compatible version is libpl1000-2.0.0-1r570. It must be installed manually
    # if [ ! -f  /etc/yum.repos.d/picoscope.repo ];
    # then
    #    sudo curl -o /etc/yum.repos.d/picoscope.repo https://labs.picotech.com/rpm/picoscope.repo
    #    sudo rpmkeys --import https://labs.picotech.com/rpm/repodata/repomd.xml.key
    # fi
    # sudo yum install --skip-broken libpl1000

    if [ ! isinstalled "libpl1000" ];
    then
        cd
        wget https://labs.picotech.com/rpm/x86_64/libpl1000-2.0.0-1r570.x86_64.rpm
        sudo yum install ./libpl1000-*.x86_64.rpm
        sudo ldconfig
        rm -f ./libpl1000-*.x86_64.rpm
    fi

    sudo yum update
    sudo yum upgrade
    sudo yum -y install epel-release
    sudo yum -y update
    sudo yum install --skip-broken make automake gcc gcc-c++ kernel-devel python python-devel \
         python-pip psmisc git SDL-devel SDL_ttf-devel elog python-sphinx \
         libAfterImage flex flex-devel expat-devel lua-devel libcurl \
         python-progressbar R httpd python-requests motif-devel tcsh libXt-devel \
         curl curl-devel boost-devel boost-filesystem boost-system boost-thread \
         boost-regex jsoncpp-devel scons libmongo-client couchdb libX11-devel \
         boost-program-options unzip cmake3 perl-XML-LibXML openssl-devel \
         libusb libusb-devel pyserial python2-distro python-lxml notify-python \
         python2-future python2-bitarray python2-six python-setuptools python-scp \
	 python-paramiko pytz python36-tinydb python2-numpy tkinter

    # To generate the documentation with sphinx
    sudo yum install --skip-broken python-sphinx
    
    # Install some python2 packages
    sudo python2 -m pip install --upgrade pip
    sudo python2 -m pip install --upgrade argparse couchdb pyvisa pyvisa-py arduinoserial
fi

#install root if necessary
if [ "${ROOTREP}" = "y" ];
then
    echo ""
    echo "-------------------"
    echo "ROOT INSTALLATION"
    echo "-------------------"

    if [ $UBUNTU = "y" ];
    then
        echo ""
        echo "Insert the directory where you want ROOT to be installed."
        echo "Don't insert the trailing slash. For example \"$HOME/Code/ROOT\"."
        echo "This script is not intended to be run as root, so please insert"
        echo "a directory that is writable by the current user. If you wish to"
        echo "install ROOT in a system directory, please do it manually or just"
        echo "place \"sudo\" in front of every relevant line in this script"
        echo "from line 562 to line 569 (more or less)."
        read -r ROOTDIR

        # If nothing is inserted assume the user home as installation directory
        # Remove any previous installation
        if [ -z "$ROOTDIR" ]; then
            if [ -d "${HOME}/ROOT" ];
            then rm -rf "${HOME}/ROOT"; fi
            mkdir -p "${HOME}/ROOT"
            ROOTSYS="${HOME}/ROOT"
        else
            if [ -d "${ROOTDIR}/ROOT" ];
            then rm -rf "${ROOTDIR}/ROOT"; fi
            mkdir -p "${ROOTDIR}/ROOT"
            ROOTSYS="${ROOTDIR}/ROOT"
        fi
        
        sudo apt-get install -y build-essential git dpkg-dev cmake xutils-dev \
             binutils libx11-dev libxpm-dev libxft-dev libxext-dev \
             libssl-dev libpcre3-dev libglu1-mesa-dev libglew-dev \
             libmysqlclient-dev libfftw3-dev libcfitsio-dev libgraphviz-dev \
             libavahi-compat-libdnssd-dev libldap2-dev python-dev libxml2-dev \
             libkrb5-dev libgsl-dev qtdeclarative5-dev libmotif-dev libmotif-common \
             libblas-dev liblapack-dev xfstt xfsprogs t1-xfree86-nonfree \
             ttf-xfree86-nonfree ttf-xfree86-nonfree-syriac xfonts-75dpi \
             xfonts-100dpi libgif-dev libtiff-dev libjpeg-dev liblz4-dev \
             liblzma-dev lzma lzma-dev libgl2ps-dev libpostgresql-ocaml-dev libsqlite3-dev \
             libpythia8-dev davix-dev srm-ifce-dev libtbb-dev python-numpy \
             python3-numpy python2 python3 python2-dev python3-dev zstd libzstd-dev \
             xxhash libxxhash-dev libafterimage-dev 
        cd
        # Download and install ROOT
        mkdir -p "${ROOTSYS}/sources" "${ROOTSYS}/${ROOTVERS}" "${ROOTSYS}/${ROOTVERS}-build"
        cd "${ROOTSYS}"
        git clone http://github.com/root-project/root.git sources
        cd sources
        git checkout -b v${ROOTVERS} v${ROOTVERS}
        cd ../${ROOTVERS}-build
        cmake -Dminuit2=On \
              -DCMAKE_INSTALL_PREFIX="${ROOTSYS}/${ROOTVERS}" \
              ../sources
        cmake --build . --target install -- -j8
        cd
        # shellcheck source=/dev/null
        . "${ROOTSYS}/${ROOTVERS}/bin/thisroot.sh"

    elif [ $CENTOS = "y" ];
    then
        echo ""
        echo "In CentOS 7 ROOT can be either installed from repository or"
        echo "compiled from sources. If you want the latest version of ROOT"
        echo "it is better to install it from repositories but if, for whatever"
        echo "reason, you want to install an older version of ROOT, perhaps"
        echo "it is better to compile from sources. If this is a DAQ PC it"
        echo "is better to install from repository."
        echo ""
        echo "Do you want to install from repository? (y|n) : "
        read -r REP
        if [ "${REP}" = "y" ];
        then
            sudo yum install root-*
        elif [ "${REP}" = "n" ];
        then
            echo ""
            echo "Insert the directory where you want ROOT to be installed."
            echo "Don't insert the trailing slash. For example \"$HOME/Code/ROOT\"."
            echo "This script is not intended to be run as root, so please insert"
            echo "a directory that is writable by the current user. If you wish to"
            echo "install ROOT in a system directory, please do it manually or just"
            echo "place \"sudo\" in front of every relevant line in this script"
            echo "from line 642 to line 649 (more or less). You can change the version"
            echo "of ROOT to be installed tweaking the ROOTVERS (${ROOTVERS}) variable."
            echo ""
            read -r ROOTDIR
            echo ""
            echo "ROOT ${ROOTVERS} will be compiled from sources."
            echo ""
            # If nothing is inserted assume the user home as installation directory
            # Remove any previous installation
            if [ -z "$ROOTDIR" ]; then
                if [ -d "${HOME}/Code/ROOT" ];
                then rm -rf "${HOME}/Code/ROOT"; fi
                mkdir -p "${HOME}/Code/ROOT"
                ROOTSYS="${HOME}/Code/ROOT"
            else
                if [ -d "${ROOTDIR}" ];
                then rm -rf "${ROOTDIR}"; fi
                mkdir -p "${ROOTDIR}"
                ROOTSYS="${ROOTDIR}"
            fi
            
            sudo yum install make automake gcc gcc-c++ kernel-devel git cmake3 \
                 xorg-x11-util-macros binutils libX11-devel libXft-devel \
                 openssl-devel pcre2-devel mesa-libGLU-devel glew-devel \
                 avahi-compat-libdns_sd-devel mariadb-devel fftw-devel \
                 graphviz-devel openldap-devel python-devel \
                 libxml2-devel krb5-devel gsl-devel qt-devel motif-devel motif \
                 blas-devel lapack-devel xfsprogs cabextract xorg-x11-font-utils \
                 fontconfig xorg-x11-server-Xvfb xorg-x11-fonts-Type1 \
                 xorg-x11-fonts-75dpi xorg-x11-fonts-100dpi dejavu-sans-fonts \
                 urw-fonts giflib-devel libtiff-devel libjpeg-turbo-devel lz4-devel \
                 xz-devel lzma-devel gl2ps-devel postgresql-devel libsqlite3x-devel \
                 pythia8-devel davix-devel srm-ifce-devel tbb-devel python2-numpy \
                 libXpm-devel libXpm cfitsio cfitsio-devel gfal2-devel gfal2 ocaml \
                 xxhash xxhash-devel xxhash-libs

            if isinstalled "msttcore-fonts-installer";
            then echo "msttcore-fonts-installer is already installed"; 
            else 
                echo "msttcore-fonts-installer is not installed"
                wget https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
                sudo yum install msttcore-fonts-installer-2.6-1.noarch.rpm
                rm -f msttcore-fonts-installer-2.6-1.noarch.rpm
            fi
            # Download and install ROOT
            mkdir -p "${ROOTSYS}/sources" "${ROOTSYS}/${ROOTVERS}" "${ROOTSYS}/${ROOTVERS}-build"
            cd "${ROOTSYS}"
            git clone http://github.com/root-project/root.git sources
            cd sources
            git checkout -b v${ROOTVERS} v${ROOTVERS}
            cd ../${ROOTVERS}-build
            cmake3 \
                -Dbuiltin_xrootd=On \
                -Dminuit2=On \
                -Dbuiltin_lzma=On \
                -DPython=On \
                -DPYTHON_EXECUTABLE=/usr/bin/python3 \
                -DCMAKE_INSTALL_PREFIX="${ROOTSYS}/${ROOTVERS}" \
                -DCMAKE_EXE_LINKER_FLAGS="-pthread" \
                "$CENTOS_ROOT_FLAGS" \
                -DCMAKE_BUILD_TYPE=Optimized \
                ../sources
            cmake3 --build . --target install -- -j8
            cd
            # shellcheck source=/dev/null
            . "${ROOTSYS}/${ROOTVERS}/bin/thisroot.sh"
        else
            echo "I didn't understand your answer. Sorry, try again."
            exit 1
        fi
    fi
fi

# ROOT detection
if [ -z "${ROOTSYS}" ];
then
    if [ -d "/opt/root" ];
    then
        ROOTSYS=/opt/root
    elif [ -f "/usr/bin/root" ];
    then
        ROOTSYS=/usr
        sudo ln -s /usr /opt/root
    else
        echo "Couldn't detect ROOT installation."
        echo "Perhaps you forgot to run the thisroot.sh script."
    fi
fi

# ------------------------ Download --------------------------

if [ "${PYRAMEREP}" = "y" ] || [ "${ANPANREP}" = "y" ] || [ "${MIDASREP}" = "y" ];
then
    echo ""
    echo "Insert the directory where you would like to download and"
    echo "compile Pyrame, Anpan and MIDAS."
    echo "Don't insert the trailing slash. The default one is \"${HOME}\"."
    echo "Just press OK if you want to download it in the $HOME folder."
    read -r SOURCE_DIR
    if [ -z "$SOURCE_DIR" ]; then
        SOURCE_DIR=${HOME}
    fi
    
    cd "${SOURCE_DIR}"
    if [ "${PYRAMEREP}" = "y" ] && [ ! -d "${SOURCE_DIR}/Pyrame" ];
    then
        env GIT_SSL_NO_VERIFY=true git clone https://llrgit.in2p3.fr/online/pyrame.git Pyrame
        (
            cd "${SOURCE_DIR}/Pyrame"
            git checkout -b develop-jojo origin/develop-jojo
            # rm -rf bus/cmd_cserial/libserialport
            # rm -rf meters/cmd_usbrh/usbrh-linux
            # git submodule add --force https://github.com/sigrokproject/libserialport.git bus/cmd_cserial/libserialport
            # git submodule add --force https://github.com/YNUneutrino/usbrh-linux.git meters/cmd_usbrh/usbrh-linux
            git submodule update --init --recursive
        )
    fi
    if [ "${ANPANREP}" = "y" ] && [ ! -d "${SOURCE_DIR}/Anpan" ];
    then
        env GIT_SSL_NO_VERIFY=true git clone https://llrgit.in2p3.fr/online/wagasci.git Anpan
        (
            cd "${SOURCE_DIR}/Anpan"
            git checkout -b develop origin/develop
        )
    fi
    if [ "${MIDASREP}" = "y" ] && [ ! -d "${SOURCE_DIR}/Midas" ];
    then
        env GIT_SSL_NO_VERIFY=true git clone https://bitbucket.org/tmidas/midas.git Midas
        (
            cd "${SOURCE_DIR}/Midas"
            git checkout origin/develop
            git submodule update --init
        )
    fi
fi

# ------------------------ PYRAME --------------------------

# More info on the pyrame installation can be found on this webpage:
# http://llr.in2p3.fr/sites/pyrame/documentation/howto_install.html

if [ "${PYRAMEREP}" = "y" ];
then
    echo "--------------------------------"
    echo "PYRAME INSTALLATION"
    echo "--------------------------------"
    echo "More info on the pyrame installation can be found on this webpage:"
    echo "http://llr.in2p3.fr/sites/pyrame/documentation/howto_install.html"

    # In Debian systems you might need to create links for lua.h and liblua.so
    if [ $UBUNTU = "y" ];
    then
        sudo ln -sf /usr/lib/x86_64-linux-gnu/liblua5.2.so /usr/lib/liblua.so
        sudo ln -sf /usr/include/lua5.2/lua.h /usr/include/lua.h
        sudo ln -sf /usr/include/lua5.2/luaconf.h /usr/include/luaconf.h
        sudo ln -sf /usr/include/lua5.2/lualib.h /usr/include/lualib.h
        sudo ln -sf /usr/include/lua5.2/lauxlib.h /usr/include/lauxlib.h
    fi

    cd "${SOURCE_DIR}/Pyrame"

    # configure and install
    chmod +x ./configure
    bash ./configure
    make
    sudo make install

    # enable apache2
    if [ $UBUNTU = "y" ];
    then
        # make documentation
        (
            cd docs
            make
            sudo make install
        )
        sudo "${SOURCE_DIR}/Pyrame/xhr/install_xhr_debian8_apache2.sh"
        sudo systemctl restart apache2
        sudo systemctl enable apache2
    elif  [ $CENTOS = "y" ];
    then
        sudo "${SOURCE_DIR}/Pyrame/xhr/install_xhr_centos7_apache2.sh"
        sudo systemctl restart httpd
        sudo systemctl enable httpd
    fi

    # The following command is equivalent to
    # echo 1 > sudo tee /proc/sys/net/ipv4/tcp_tw_recycle
    # echo 1 > sudo tee /proc/sys/net/ipv4/tcp_fin_timeout
    # tcp_tw_recycle is not available in ubuntu since kernel 4.11,
    # moreover this is strictly a violation of the TCP specification.
    # In Linux 2.2, the default value for tcp_fin_timeout was 180 seconds.
    # I assumed that if the OS is CentOS that machine will only be used
    # as a DAQ machine with limited internet capabilities and so I allow
    # for a quick recycling of TCP connections. This is at expense of a
    # stable internet connection
    if [ $CENTOS = "y" ];
    then
        echo 1 > sudo tee /proc/sys/net/ipv4/tcp_tw_recycle
        echo 1 > sudo tee /proc/sys/net/ipv4/tcp_fin_timeout
        sudo cp -f "${SOURCE_DIR}/Pyrame/launcher/99-pyrame.conf" /etc/sysctl.d/
    fi  
fi

# --------------------- ANPAN ---------------------

# More info on the anpan installation can be found on this webpage:
# http://llr.in2p3.fr/sites/pyrame/anpan/documentation/install.html

if [ "${ANPANREP}" = "y" ];
then
    echo ""
    echo "-------------------"
    echo "ANPAN INSTALLATION"
    echo "-------------------"
    echo "ANPAN is based on anpan 3.0"
    echo "More info on the anpan installation can be found on this webpage:"
    echo "http://llr.in2p3.fr/sites/pyrame/anpan/documentation/install.html"

    cd "$SOURCE_DIR/anpan"

    # compile and install Anpan

    # I noticed that sometimes not all the scripts are copied in the /usr/local/bin
    # directory. This may be due to a misconfiguration of the Makefiles
    # In case try to manually run the specific Makefile inside each subdirectory. 

    sudo ./install.sh
    ROOTSYS=${ROOTSYS} make
    ROOTSYS=${ROOTSYS} sudo make install

    # Documentation compilation is currently broken in CentOS due to sphinx
    # version being too old
    if [ $UBUNTU = "y" ];
    then
        # install documentation   
        cd docs/documentation
        ROOTSYS=${ROOTSYS} make
        sudo mkdir -p /opt/anpan/doc
        ROOTSYS=${ROOTSYS} sudo make install
    fi

    echo ""
    echo "Post-configuration..."
    echo ""

    if [ ! -L "/var/www/html/phygui_rc" ];
    then
        sudo ln -s /opt/anpan/phygui_rc /var/www/html/phygui_rc
    fi
fi

# ------------------------ MIDAS --------------------------

# More info on the pyrame installation can be found on this webpage:
# https://midas.triumf.ca/MidasWiki/index.php/Main_Page

if [ "${MIDASREP}" = "y" ];
then
    echo ""
    echo "--------------------------------"
    echo "MIDAS INSTALLATION"
    echo "--------------------------------"
    echo "More info on the MIDAS installation can be found on this webpage:"
    echo "https://midas.triumf.ca/MidasWiki/index.php/Main_Page"

    cd "${SOURCE_DIR}/Midas"

    # install MIDAS
    mkdir -p build
    (
        cd build
        ${CMAKE} ..
        make "-j$(nproc)"
        make "-j$(nproc)" install
    )
    # create fake SSL certificate for localhost
    openssl req -new -nodes -newkey rsa:2048 -sha256 -out ssl_cert.csr -keyout ssl_cert.key \
            -subj "/C=JP/ST=Ibaraki/L=Tokai/O=midas/OU=mhttpd/CN=localhost"
    openssl x509 -req -days 365 -sha256 -in ssl_cert.csr -signkey ssl_cert.key -out ssl_cert.pem
    cat ssl_cert.key >> ssl_cert.pem

    # create password
    mkdir -p "${SOURCE_DIR}/Online"
    cat > "${SOURCE_DIR}/Online/htpasswd.txt" <<EOF
${USER}:${EXPERIMENT_NAME}:7d2a8e2d0b5716cc0ba0b26e1cece901
EOF

    # initialized odb
    cat > "${SOURCE_DIR}/Online/exptab" <<EOF
${EXPERIMENT_NAME} ${SOURCE_DIR}/Online ${USER}
EOF

    # -------------- MIDAS service ---------------

    cat >> "${HOME}/.profile" <<EOF
# set PATH so it includes MIDAS bin if they exists
if [ -d "${SOURCE_DIR}/Midas/bin" ] ; then
        export MIDASSYS="${SOURCE_DIR}/Midas"
    export PATH="\$PATH:\$MIDASSYS/bin"
fi

# set MIDAS environment
if [ -f ${SOURCE_DIR}/Online/exptab ] ; then
        export MIDAS_EXPTAB=${SOURCE_DIR}/Online/exptab
        export MIDAS_EXPT_NAME=${EXPERIMENT_NAME}
        export SVN_EDITOR="emacs -nw"
        export GIT_EDITOR="emacs -nw"
fi
EOF

    if [ -f /etc/systemd/system/midas.service ];
    then
        sudo rm -f /etc/systemd/system/midas.service
    fi
    cat > midas.service <<EOF
[Unit]
Description=MIDAS data acquisition system
After=network.target rpcbind.target ypbind.target
StartLimitIntervalSec=0
RequiresMountsFor=${HOME}

[Service]
Type=simple
Restart=always
RestartSec=3
User=${USER}
ExecStart=${SOURCE_DIR}/Midas/bin/mhttpd -e ${EXPERIMENT_NAME}
Environment="MIDASSYS=${SOURCE_DIR}/Midas" "MIDAS_EXPTAB=${SOURCE_DIR}/Online/exptab" "MIDAS_EXPT_NAME=${EXPERIMENT_NAME}" "SVN_EDITOR=emacs -nw" "GIT_EDITOR=emacs -nw"
PassEnvironment=MIDASSYS MIDAS_EXPTAB MIDAS_EXPT_NAME SVN_EDITOR GIT_EDITOR

[Install]
WantedBy=multi-user.target
EOF
    sudo mv midas.service /etc/systemd/system/midas.service

    echo ""
    echo "Don't forget to restart the PC and then initialize the"
    echo "ODB database with the command"
    echo "  odbedit"
    echo "Then start and enable the MIDAS service with the commands:"
    echo "  sudo systemctl enable midas"
    echo "  sudo systemctl start midas"
    echo ""
fi

# ------------------------ Start everything --------------------------

sleep 2s

if [ "${PYRAMEREP}" = "y" ];
then
    sudo systemctl enable pyrame
    sudo systemctl restart pyrame
fi

if [ "${ANPANREP}" = "y" ];
then
    sudo systemctl enable couchdb
    sudo systemctl restart couchdb
    if [ $UBUNTU = "y" ];
    then
        sensible-browser http://localhost/phygui_rc &
    elif  [ $CENTOS = "y" ];
    then
        firefox http://localhost/phygui_rc &
    fi
fi

echo ""
echo "Installation successfully completed! Thanks for using Anpan"
echo "For any questions about this script please contact:"
echo "Pintaudi Giorgio (PhD Student)"
echo "Yokohama National University"
echo "giorgio-pintaudi-kx@ynu.jp"
echo ""

exit 0

# AnpanInstaller.sh
#
# Copyright (C) 2018 by Pintaudi Giorgio <giorgio-pintaudi-kx@ynu.jp>
# Released under the GPLv3 license
#
#     Pintaudi Giorgio (PhD Student)
#     Yokohama National University
#     giorgio-pintaudi-kx@ynu.jp
