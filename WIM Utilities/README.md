# Windows4Toughbook

In order to make my life easier I created a couple of utilities:

img.ps1 is an image maniputlation utility which calls DISM in order to perform common and repetative tasks.
img.ini, which is created the first time you run img.ps1, contains the paths and file names, which you can modify.

If you just run img.ps1 you will get a help screen which shows all of the commands.

Some of the most helpful are combine, which takes all of the .SWM files (i.e. install.swm and install2.swm) and combines them into a singel install.wim which you can then mount as an offline image to perform modifications on.  When you are down, you can then split the single image back up to recopy back to the bootable USB drive to install.

appx-util.ps1 is a helpful utility which allows you to remove pre-provisioned .appx files such as cortana, all the xbox utils, etc.  appx-util.ini, which is created the first time you run appx-util.ps1, contains the paths and file names as well as offline registry paths.

Some of the most helpful are the abitliy to generate a complete list of all pre-provisioned apps into a text file which you can then remove the items you want to keep.  Then you can generate a list of reg id's which you can import into an offline registry to add "deprovisioned" keys for the apps you removed so that they don't reinstall when M$ pushes an update.

If you just run appx-util.ps1 you will get a help screen which shows all of the commands.

Both scripts will self-elevate with a UAC prompt if need be.

build-iso.ps1 can take the modified USB that you create and turn it into an ISO file for mounting to a VM.  This file prompts you for the path and ISO name when you run it.