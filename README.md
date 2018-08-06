Last Updated on 2018-08-06
Copyright (C) 2018  Pintaudi Giorgio

# CalicoesInstaller.sh

This is a bash script that installs the [calicoes
software](http://llr.in2p3.fr/sites/pyrame/calicoes/index.html) along
with all its dependencies for the Ubuntu OS. It is an updated and
corrected version based on the original installation script for CentOS
7. The original script can be found and downloaded
[here](http://llr.in2p3.fr/sites/pyrame/calicoes/disclaimer.html).

Credits for the calicoes software and the original version of this
script go to Frédéric Magniette and Miguel Rubio-Roy.

## Details

This script assumes a vanilla install of Ubuntu 18.04. It install
Calicoes automatically and with almost no input from the user. Only
some paths have to be specified.

Calicoes is a software for control-command and data acquisition of the
Silicium/Tungsten Electromagnetic Calorimeter (SIW-Ecal) for the
future ILC Detector. It is based on the Pyrame framework.

Anyway, the present script was developed by a member of the WAGASCI
collaboration (a subexperiment of the [T2K
experiment](http://t2k-experiment.org/). Some archives will be
downloaded from the [WAGASCI website](https://www-he.scphys.kyoto-u.ac.jp/research/Neutrino/WAGASCI/wiki/dokuwiki/doku.php?id=components:firmware)
for which is needed a username and a password. If you are a WAGASCI
member there is no problem but if you are not, please contact me for
assistance (my address is on the bottom).

All the dependencies are either downloaded from the repositories or directly
compiled. The compilation process may take some time depending on the
CPU speed and number or cores.

If the script encounters any error it immediately stops. When you
resume it, you can skip the installation of some dependencies if you
have already installed them.

## TO-DO

 - [ ] Add support for other Ubuntu versions or Linux distributions

## License

Copyright (C) 2018  Pintaudi Giorgio <giorgio-pintaudi-kx_AT_ynu_DOT_jp>

CalicoesInstaller.sh is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.

CalicoesInstaller.sh is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with CalicoesInstaller.sh.  If not, see <https://www.gnu.org/licenses/>.
