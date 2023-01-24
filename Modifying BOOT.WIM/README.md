# Windows4Toughbook

Modified BOOT.WIM Files

The Panny ISO's create a DVD or USB so that you can use to perform a factory restore.

During this process the contents of the \source directory is copied to the Recovery Partition and are used during the reimage process.  When the Recovery Process starts, WinRE is loaded from the BOOT.WIM file into a RAM disk and the files there copy the contents of INSTALL.SWM and INSTALl2.SWM to the Windows HDD partition.

The BOOT.WIM file has code that checks to ensure that the image is being installed on the target model, that it is plugged in, and that the contents of INSTALL.SWM and INSTALL2.SWM have not been altered.

The main checks are done through a java file: \sources\recovery\oem\script\common.js

The functions cmnCHK_MD5, cmnCHK_isAC, and cmnCHK_isTargetMODEL perform these checks.

I have included the java file here so that you can see how I commented out the sections.  You only need the MD5 check commented out if you are debloating or adding files to the image.  You need to comment out all three if you are testing inside of a VM.

