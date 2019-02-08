#!/bin/bash

# AnpanClean.sh
# Copyright (C) 2018 by Pintaudi Giorgio <giorgio-pintaudi-kx@ynu.jp>
# Released under the GPLv3 license
#
#     Pintaudi Giorgio (PhD Student)
#     Yokohama National University
#     giorgio-pintaudi-kx@ynu.jp
#
# This file (AnpanClean.sh) is part of the AnpanInstaller.sh software.
# It is a useful script to clean the user home directory before the
# AnpanInstaller.sh script is launched.
# It cleans all the previous installations and ensures a clean environment.

MIDAS_PREFIX="/opt/midas"

cd ${HOME}
rm -rf compileDIM.csh* dim_v20* levbdim tmp couch* lcio
sudo rm -rf /tmp/mongoose-cpp
if [ -d ${HOME}/pyrame ]; then
	cd ${HOME}/pyrame
	sudo make uninstall
	cd ..
	rm -rf pyrame*
fi
if [ -d ${HOME}/calicoes ]; then
	cd ${HOME}/calicoes
	sudo make uninstall
	cd ..
	rm -rf calicoes*
fi
if [ -d ${HOME}/midas ]; then
	cd ${HOME}/midas
	PREFIX=${MIDAS_PREFIX} sudo -E make uninstall
	cd ..
	rm -rf midas*
fi
if [ -d ${HOME}/usbrh-kimata ]; then
	cd ${HOME}/usbrh-kimata
	sudo make uninstall
	cd ..
	rm -rf usbrh-kimata
fi
if [ -d ${HOME}/usbrh-ynu ]; then
	cd ${HOME}/usbrh-ynu
	sudo make uninstall
	cd ..
	rm -rf usbrh-ynu
fi

# AnpanClean.sh
#
# Copyright (C) 2018 by Pintaudi Giorgio <giorgio-pintaudi-kx@ynu.jp>
# Released under the GPLv3 license
#
#     Pintaudi Giorgio (PhD Student)
#     Yokohama National University
#     giorgio-pintaudi-kx@ynu.jp
