#!/bin/bash

# AnpanInstaller.sh
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

cd ${HOME}
sudo rm -rf compileDIM.csh* dim_v20* levbdim tmp couch*
sudo rm -fr /tmp/mongoose-cpp
if [ -d ${HOME}/pyrame ]; then
	cd ${HOME}/pyrame
	sudo make uninstall
	cd ..
	sudo rm -rf pyrame*
fi
if [ -d ${HOME}/anpan ]; then
	cd ${HOME}/anpan
	sudo make uninstall
	cd ..
	sudo rm -rf anpan*
fi

# AnpanInstaller.sh
#
# Copyright (C) 2018 by Pintaudi Giorgio <giorgio-pintaudi-kx@ynu.jp>
# Released under the GPLv3 license
#
#     Pintaudi Giorgio (PhD Student)
#     Yokohama National University
#     giorgio-pintaudi-kx@ynu.jp
