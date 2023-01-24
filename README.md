# Windows4Toughbook
A collection of Panasonic Toughbook Images

Toughbook is a registered trademark of Panasonic.  All code provided may have copyrights and or trademarks which are held by the respective owners, to include, but not limited to, Panasonic and Microsoft.  By downloading and using the factory code, you warrant that you are duly licensed to utilize the code on your computer.  I am not here to help you bypass any licensing, just to show you how to modify the original recovery to include the drivers, directories, or to perform the other modifcations you desire before the install.

YMMV

All Panasonic Toughbooks are preloaded with a recovery partition which allows the end user to restore the computer back to the factory state.  Unfortunately, this often includes bloatware from M$.  Stripping this out the image usually wasn't an option until recently.

Using the official Windows 10 download utility, I was able to extract the ISO files which make up the recovery partition.  Inside these ISO files are the WIM files which install the operating system, held in check by a MD5 check utility to ensure that tampering does not occur.

Inside each model subdirectory you will find the original ISO files along with the instructions to modify the data WITH OUT tripping the MD5 error.  In some cases, I have provided sample code in order to stream line the mounting of the WIM image in order to use DISM (or your favorite tool) in order to make modifications to the Windows image before the install.

Have Fun!
