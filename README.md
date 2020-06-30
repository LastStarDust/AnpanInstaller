Last Updated on 2020-05-02

Copyright (C) 2018 Pintaudi Giorgio, YNU

# AnpanInstaller.sh v4.3

This is a bash script that installs ANPAN (Acquisition Networked Program for
Accelerated Neutrinos) along with all its dependencies for the Ubuntu and CentOS
OSes. ANPAN is a collection of open-source and proprietary software used for the
remote control and for data acquisition of the [WAGASCI
experiment](https://www-he.scphys.kyoto-u.ac.jp/research/Neutrino/WAGASCI/wiki/dokuwiki/doku.php?id=start)
(one of the [T2K](http://t2k-experiment.org/) near detectors).

For further information about ANPAN refer to [this
link](https://www-he.scphys.kyoto-u.ac.jp/research/Neutrino/WAGASCI/wiki/dokuwiki/doku.php?id=components:anpan).
**Because ANPAN contains proprietary software, only the WAGASCI members are allowed
to install it.**

This script is an updated and heavily modified version based on the original
[Calicoes installation script for CentOS
7](http://llr.in2p3.fr/sites/pyrame/calicoes/disclaimer.html). Calicoes is a
software for control-command and data acquisition of the Silicium/Tungsten
Electromagnetic Calorimeter (SIW-Ecal) for the future ILC Detector on which
ANPAN is based.

## Details

This script assumes a vanilla install of Ubuntu 18.04/20.04 or CentOS 7. It
installs ANPAN automatically and with almost no input from the user. Only some
paths can be specified (if the user doesn't want to use the default ones).

The present script was developed by Pintaudi Giorgio, a member of the WAGASCI
collaboration. WAGASCI is a sub-experiment of the [T2K
experiment](http://t2k-experiment.org/). The Calicoes code (that is bundled with
Anpan) is proprietary code developed by the LLR laboratory specifically for the
CALICE and WAGASCI experiments. If you are a WAGASCI member there is no problem
but if you are not, please contact me for assistance (my address is on the
bottom).

All the dependencies are either downloaded from the repositories or directly
compiled. The compilation process may take some time depending on the CPU speed
and number or cores.

If the script encounters any error it immediately stops. When you resume it, you
can skip the installation of some dependencies if you have already installed
them.

# Installation

Please don't run the script as super user. You will be requested the super user
password AFTER the script has started. To run the script you can follow this
procedure:

 - CentOS 7:
 
   Open a shell and issue
   
```
sudo yum install git
git clone https://github.com/LastStarDust/AnpanInstaller.git
cd AnpanInstaller
chmod +x AnpanInstaller.sh
./AnpanInstaller.sh
```

 - Ubuntu 18.04/20.04 and Debian 9:
 
   Open a shell and issue
   
```
sudo apt-get install git
git clone https://github.com/LastStarDust/AnpanInstaller.git
cd AnpanInstaller
chmod +x AnpanInstaller.sh
./AnpanInstaller.sh
```

If for any reason the install script has failed and you need to run it again, it
may be a good idea to clean your home directory before doing that.  You can do
that by running the AnpanClean.sh script

```
chmod +x AnpanClean.sh
./AnpanClean.sh
```

This script assumes that you downloaded and compiled anpan and pyrame in the
default folder ($HOME).

## Changelog

 - v4.2 Added support for Debian 9
 - v4.1 Bugfix release
 - v4.0 Removed many useless packages.
 - v3.2 Compile MIDAS with CMake
 - v3.0 Install MIDAS
 - v2.0 Added support for CentOS 7 v1.0 First version

## TO-DO

 - [ ] Add support for other Linux distros
 
## License

Copyright (C) 2018 Pintaudi Giorgio <giorgio-pintaudi-kx_AT_ynu_DOT_jp>

AnpanInstaller.sh is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or any later version.

AnpanInstaller.sh is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
AnpanInstaller.sh.  If not, see <https://www.gnu.org/licenses/>.

Credits for the calicoes software and the original version of this script go to
Frédéric Magniette and Miguel Rubio-Roy.
