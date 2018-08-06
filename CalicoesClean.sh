#!/bin/bash

# CalicoesInstaller.sh
# Copyright (C) 2018 by Pintaudi Giorgio <giorgio-pintaudi-kx@ynu.jp>
# Released under the GPLv3 license
#
#     Pintaudi Giorgio (PhD Student)
#     Yokohama National University
#     giorgio-pintaudi-kx@ynu.jp
#
# This file (CalicoesClean.sh) is part of the CalicoesInstaller.sh software.
# It is a useful script to clean the user home directory before the
# CalicoesInstaller.sh script is launched.
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
if [ -d ${HOME}/calicoes ]; then
	cd ${HOME}/calicoes
	sudo make uninstall
	cd ..
	sudo rm -rf calicoes*
fi

# CalicoesInstaller.sh
#
# Copyright (C) 2018 by Pintaudi Giorgio <giorgio-pintaudi-kx@ynu.jp>
# Released under the GPLv3 license
#
#     Pintaudi Giorgio (PhD Student)
#     Yokohama National University
#     giorgio-pintaudi-kx@ynu.jp
