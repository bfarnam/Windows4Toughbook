#Requires -Version 5.0
param( [string]$operation )
$operation = $operation.ToLower();
[bool]$isDebug = $false;
[bool]$bAdmin = $true;
$verNumber = "1.3";
$verDate = "2023 January 13";
$scriptName = $MyInvocation.MyCommand.Name;
$scriptDir = $PSSCriptRoot;

if ($isDebug) { 
	Write-Host "DEBUG: Starting Script with the Following Parameters" -backgroundcolor "Black" -foregroundcolor "Red"; 
	Write-Host "DEBUG: `$operation                           $operation" -backgroundcolor "Black" -foregroundcolor "Red"; 
	Write-Host "DEBUG: `$isDebug                             $isDebug" -backgroundcolor "Black" -foregroundcolor "Red"; 
	Write-Host "DEBUG: `$bAdmin                              $bAdmin" -backgroundcolor "Black" -foregroundcolor "Red"; 
	Write-Host "DEBUG: `$verNumber                           $verNumber" -backgroundcolor "Black" -foregroundcolor "Red"; 
	Write-Host "DEBUG: `$verDate                             $verDate" -backgroundcolor "Black" -foregroundcolor "Red"; 
	Write-Host "DEBUG: `$scriptName                          $scriptName" -backgroundcolor "Black" -foregroundcolor "Red"; 
	Write-Host "DEBUG: `$scriptDir                           $scriptDir" -backgroundcolor "Black" -foregroundcolor "Red"; 
	Write-Host "DEBUG: `$MyInvocation.MyCommand.Name         $($MyInvocation.MyCommand.Name)" -backgroundcolor "Black" -foregroundcolor "Red"; 
	Write-Host "DEBUG: `$myInvocation.MyCommand.Definition   $($myInvocation.MyCommand.Definition)" -backgroundcolor "Black" -foregroundcolor "Red"; 
}	

<#
0        1         2         3         4         5         6         7         8
12345678901234567890123456789012345678901234567890123456789012345678901234567890
	img.ps1
	
	This utility is a wrapper for dism.exe.  It makes calling dism 
	easier for repetitve tasks.  When working with images it is often 
	nescarry to perform repetitve taks over and over while testing the 
	image deployment.  This utility stores path and name information in 
	an ini file and constructs the command line for you so that you 
	don't have to do it manually.  Additionally, the utility will self 
	elevate in case you forget to run-as.
	
	v1.3	2023 January 13		Created Script from single scripts and
								added ini capabilities and licensing 
								notices
	
	Copyright (C) 2023 Brett A. Farnam (brett_farnam@gmail.com)
	
	This program is free software: you can redistribute it and/or modify 
	it under the terms of the GNU General Public License as published by 
	the Free Software Foundation, either version 3 of the License, or 
	(at your option) any later version.

	This program is distributed in the hope that it will be useful, but 
	WITHOUT ANY WARRANTY; without even the implied warranty of 
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
	General Public License for more details.

	You should have received a copy of the GNU General Public License 
	along with this program. If not, see <https://www.gnu.org/licenses/>.
#>

function readINI()
{
	if ($isDebug) { Write-Host "DEBUG: readINI()" -backgroundcolor "Black" -foregroundcolor "Red"; }
	#read the key pairs
	$iniData = Get-Content "$scriptDir\$($scriptName.replace('.ps1','.ini'))" -raw -verbose | ConvertFrom-StringData ;
	
	# check values
	[bool]$iniError = $false
	if ( [string]::IsNullOrWhiteSpace($iniData.wimPath) -or [string]::IsNullOrEmpty($iniData.wimPath) ) { $iniError = $true; }
	if ( [string]::IsNullOrWhiteSpace($iniData.wimFile) -or [string]::IsNullOrEmpty($iniData.wimFile) ) { $iniError = $true; }
	if ( [string]::IsNullOrWhiteSpace($iniData.swmPath) -or [string]::IsNullOrEmpty($iniData.swmPath) ) { $iniError = $true; }
	if ( [string]::IsNullOrWhiteSpace($iniData.swmFile) -or [string]::IsNullOrEmpty($iniData.swmFile) ) { $iniError = $true; }
	if ( [string]::IsNullOrWhiteSpace($iniData.imgIndex) -or [string]::IsNullOrEmpty($iniData.imgIndex) ) { $iniError = $true; }
	if ( [string]::IsNullOrWhiteSpace($iniData.maxFileSize) -or [string]::IsNullOrEmpty($iniData.maxFileSize) ) { $iniError = $true; }
	if ( [string]::IsNullOrWhiteSpace($iniData.mountPath) -or [string]::IsNullOrEmpty($iniData.mountPath) ) { $iniError = $true; }
	if ( [string]::IsNullOrWhiteSpace($iniData.bExtraConfirmation) -or [string]::IsNullOrEmpty($iniData.bExtraConfirmation) ) { $iniError = $true; }
		
	if ($isDebug) { Write-Host "DEBUG: `$iniError:$iniError" -backgroundcolor "Black" -foregroundcolor "Red"; }
	
	if ($iniError)
	{
		Write-Host "`n";
		Write-Warning "$scriptDir\$($scriptName.replace('.ps1','.ini')) is damaged or missing - do you wish to regenerate it?";
		Write-Host "`n";
		Write-Host "Press <ENTER> to continue or <CTRL><C> to abort" -backgroundcolor "Black" -foregroundcolor "Yellow"; $nothing = Read-Host;
		writeINI;
	}

	[bool]$iniData.bExtraConfirmation = $($iniData.bExtraConfirmation);

	$iniData; #return this
}

function writeINI()
{
	if ($isDebug) { Write-Host "DEBUG: writeINI()" -backgroundcolor "Black" -foregroundcolor "Red"; }
	if (test-path "$scriptDir\$($scriptName.replace('.ps1','.ini'))") {
		if ($isDebug) { Write-Host "DEBUG: FOUND: $scriptDir\$($scriptName.replace('.ps1','.ini'))" -backgroundcolor "Black" -foregroundcolor "Red"; }
		Write-Host "`n";
		Write-Warning "$scriptDir\$($scriptName.replace('.ps1','.ini')) exists - do you wish delete it and regenerate it?";
		Write-Host "`n";
		Write-Host "Press <ENTER> to continue or <CTRL><C> to abort" -backgroundcolor "Black" -foregroundcolor "Yellow"; $nothing = Read-Host;
		Write-Warning "Deleting $scriptDir\$($scriptName.replace('.ps1','.ini'))";
		rm "$scriptDir\$($scriptName.replace('.ps1','.ini'))";
	}
	
	$var = $scriptDir.replace("\","\\")
	# There can be NO extra white space becuase this is literal so it must be left justified
	# BEGIN FILE
$iniData = @"
# Auto-Generated by $scriptName version $verNumber
# Copyright (C) 2023 Brett A. Farnam (brett_farnam@yahoo.com)
# Distributed under GNU General Public License v3
# Please see COPYING.txt or <https://www.gnu.org/licenses/>
 
# All path names must have "\\" instead of "\"
 
# This is the path to the .WIM file
wimPath = $var
 
# This is the name of the .WIM file
wimFile = install.wim
 
# This is the path to the .SWM files
swmPath = $var
 
# This is the name of the .SWM files
swmFile = install.swm
 
# This is the index number of the .WIM file
imgIndex = 1
 
# This is the max file size in MB when splitting WIMs
maxFileSize = 3600
 
# This is the mount directory
mountPath = c:\\offline
 
# Turns on extra confirmations
bExtraConfirmation = 0
"@
	
	Set-Content "$scriptDir\$($scriptName.replace('.ps1','.ini'))" $iniData;
	Write-Host "`n";
	Write-Host "$scriptDir\$($scriptName.replace('.ps1','.ini')) has been created.  After confirming and or making changes to it, please save`nthe file and then exit notepad and the script will continue.";
	start-process -FilePath "$env:SystemRoot\notepad.exe" -ArgumentList "$scriptDir\$($scriptName.replace('.ps1','.ini'))" -PassThru -Wait
	return; # return nothing
}

if (test-path "$scriptDir\$($scriptName.replace('.ps1','.ini'))") {
	if ($isDebug) { Write-Host "DEBUG: READY TO READ: $scriptDir\$($scriptName.replace('.ps1','.ini'))" -backgroundcolor "Black" -foregroundcolor "Red"; }
	$iniData = readINI; # read file
} else {
	if ($isDebug) { Write-Host "DEBUG: NOT FOUND: $scriptDir\$($scriptName.replace('.ps1','.ini'))" -backgroundcolor "Black" -foregroundcolor "Red"; }
	Write-Host "`n";
	Write-Warning "$scriptDir\$($scriptName.replace('.ps1','.ini')) is damaged or missing - do you wish to regenerate it?";
	Write-Host "`n";
	Write-Host "Press <ENTER> to continue or <CTRL><C> to abort" -backgroundcolor "Black" -foregroundcolor "Yellow"; $nothing = Read-Host;
	writeINI;
#	notepad.exe $scriptDir\$($scriptName.replace('.ps1','.ini'));
#	read-host "Press ENTER to Continue" -backgroundcolor "Black" -foregroundcolor "Yellow";
#	$iniData = readINI;
}

# we want to catch user level here becuase we want this to run at the lowest level in stead of always admin
if ($operation -eq "ini") { $bAdmin = $false; }
if ($operation -eq "") { $bAdmin = $false; }

if ($isDebug) { Write-Host "DEBUG: CHECK ADMIN STATUS" -backgroundcolor "Black" -foregroundcolor "Red"; }
# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if ( ($myWindowsPrincipal.IsInRole($adminRole)) -and ($bAdmin))
   { 
   # We are running 'as Administrator' - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " $scriptName v$verNumber (Elevated)";
   $Host.UI.RawUI.BackgroundColor = "DarkRed"; $Host.UI.RawUI.ForegroundColor = "DarkYellow"; 
   clear-host; 
   }
elseif ($bAdmin)
   {
   # We are not running "as Administrator" - so relaunch as administrator
 
   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
 
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = "-WindowStyle Maximized " + $myInvocation.MyCommand.Definition + " $operation";
 
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";
   
   if ($isDebug) { Write-Host "DEBUG: STARTING NEW PROCESS USING:`nPROCESS:`n"$($newProcess)"`nARGUEMENTS:`n"$($newProcess.Arguments)"`nVERBS:`n"$($newProcess.Verb) -backgroundcolor "Black" -foregroundcolor "Red"; }
   
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess)
 
   # Exit from the current, unelevated, process
   exit
   }
else
   {
   # must not need admin privs - lets continue as is
   }

Write-Host "Running as $env:UserName in $env:UserProfile from $scriptDir";
Write-Host "v$verNumber $verDate Copyright (C) 2023 Brett A. Farnam (brett_farnam@gmail.com)";
Write-Host "Image Manipulation Utility $scriptName";
Write-Host "Distributed under GNU General Public License v3";
Write-Host "Please see COPYING.txt or <https://www.gnu.org/licenses/>";

if ($isDebug) { Write-Host "DEBUG: BEGIN SWITCH: `$operation:$operation " -backgroundcolor "Black" -foregroundcolor "Red"; }
switch ($operation) {
	"ini" {
		if ($isDebug) { Write-Host "DEBUG: $operation" -backgroundcolor "Black" -foregroundcolor "Red"; }
		writeINI;
		Write-Host "SUCCESS!" -backgroundcolor "Black" -foregroundcolor "Green";
		Write-Host "$scriptDir\$scriptName is now configured using $scriptDir\$($scriptName.replace('.ps1','.ini'))" -backgroundcolor "Black" -foregroundcolor "Green";
		Write-Host "Command $operation Completed" -backgroundcolor "Black" -foregroundcolor "Green"; 
		Write-Host "Press <ENTER> to continue" -backgroundcolor "Black" -foregroundcolor "Green"; $nothing = Read-Host;
		break
	}
	
	"combine" {
		if ($isDebug) { Write-Host "DEBUG: $operation" -backgroundcolor "Black" -foregroundcolor "Red"; }
		Write-Host "`n";
		if ( test-path "$($iniData.wimPath)\$($iniData.wimFile)" ) {
			Write-Warning "$($iniData.wimPath)\$($iniData.wimFile) exists - ok to delete?" -WarningAction Inquire;
			Write-Host "Deleting $($iniData.wimPath)\$($iniData.wimFile)" -backgroundcolor "Black" -foregroundcolor "Yellow";
			if ($bExtraConfirmation) { read-host "Press ENTER to Continue or CTRL-C to abort"; }
			del "$($iniData.wimPath)\$($iniData.wimFile)" -verbose;
		}
		Write-Host "Combining Split Image - Running:`tdism.exe /export-image`n" `
			"`t/sourceimagefile:$($iniData.swmPath)\$($iniData.swmFile)`n" `
			"`t/swmfile:$($iniData.swmPath)\$($iniData.swmFile.replace('.swm','*.swm'))`n" `
			"`t/sourceindex:$($iniData.imgIndex)`n" `
			"`t/destinationimagefile:$($iniData.wimPath)\$($iniData.wimFile)";
		if ($bExtraConfirmation) { read-host "Press ENTER to Continue or CTRL-C to abort"; }
		if ($isDebug) { 
			Write-Host "DEBUG MODE";
		} else {
			dism.exe /export-image /sourceimagefile:"$($iniData.swmPath)\$($iniData.swmFile)" /swmfile:"$($iniData.swmPath)\$($iniData.swmFile.replace('.swm','*.swm'))" /sourceindex:$($iniData.imgIndex) /destinationimagefile:"$($iniData.wimPath)\$($iniData.wimFile)";
		}
		Write-Host "Command $operation Completed" -backgroundcolor "Black" -foregroundcolor "Yellow";
		break
	}
	
	"split" {
		if ($isDebug) { Write-Host "DEBUG: $operation" -backgroundcolor "Black" -foregroundcolor "Red"; }
		Write-Host "`n";
		if ( test-path "$($iniData.swmPath)\$($iniData.swmFile)" ) {
			Write-Warning "$($iniData.swmPath)\$($iniData.swmFile) exists - ok to delete ALL .swm files?" -WarningAction Inquire;
			Write-Host "Deleting $($iniData.swmPath)\$($iniData.swmFile.replace('.swm','*.swm'))" -backgroundcolor "Black" -foregroundcolor "Yellow";
			del "$($iniData.swmPath)\$($iniData.swmFile.replace('.swm','*.swm'))" -verbose;
		}
		Write-Host "Splitting Image - Running:`tdism.exe /split-image" `
			" /imagefile:$($iniData.wimPath)\$($iniData.wimFile)" `
			" /swmfile:$($iniData.swmPath)\$($iniData.swmFile)" `
			" /filesize:$($iniData.maxFileSize)";
		if ($bExtraConfirmation) { read-host "Press ENTER to Continue or CTRL-C to abort"; }
		dism.exe /split-image /imagefile:"$($iniData.wimPath)\$($iniData.wimFile)" /swmfile:"$($iniData.swmPath)\$($iniData.swmFile)" /filesize:$($iniData.maxFileSize);
		Write-Host "Command $operation Completed" -backgroundcolor "Black" -foregroundcolor "Yellow";
		break
	}
	
	"mount" {
		if ($isDebug) { Write-Host "DEBUG: $operation" -backgroundcolor "Black" -foregroundcolor "Red"; }
		Write-Host ""
		if ( -NOT (test-path "$($iniData.wimPath)\$($iniData.wimFile)") ) {
			Write-Warning "$($iniData.wimPath)\$($iniData.wimFile) DOES NOT EXIST";
			Write-Host "$($iniData.wimPath)\$($iniData.wimFile) DOES NOT EXIST - EXITING!" -backgroundcolor "Black" -foregroundcolor "Yellow"; 
			break
		}
		if ( -NOT (test-path "$($iniData.mountPath)") ) {
			Write-Warning "$($iniData.mountPath) does not exist - do you wish to create it?" -WarningAction Inquire;
			Write-Host "Creating $($iniData.mountPath)" -backgroundcolor "Black" -foregroundcolor "Yellow";
			md $iniData.mountPath -verbose
		}
		if ( test-path "$($iniData.mountPath)\*" ) {
			Write-Warning "$($iniData.mountPath) contains files - you can't mount to a directory with files";
			Write-Host "$($iniData.mountPath) contains files - you can't mount to a directory with files - EXITING!" -backgroundcolor "Black" -foregroundcolor "Yellow"; 
			break
		}
		Write-Host "Mounting Image - Running: dism.exe /mount-image" `
			" /imagefile:$($iniData.wimPath)\$($iniData.wimFile)" `
			" /index:$($iniData.imgIndex)" `
			" /mountdir:$($iniData.mountPath)";
		if ($bExtraConfirmation) { read-host "Press ENTER to Continue or CTRL-C to abort"; }
		dism.exe /mount-image /imagefile:"$($iniData.wimPath)\$($iniData.wimFile)" /index:$($iniData.imgIndex) /mountdir:$($iniData.mountPath);
		Write-Host "Command $operation Completed" -backgroundcolor "Black" -foregroundcolor "Yellow";
		break
	}
	
	"unmount" {
		if ($isDebug) { Write-Host "DEBUG: $operation" -backgroundcolor "Black" -foregroundcolor "Red"; }
		# first we have to trick powershell into not considering the hastable variables as seperate objects
		Write-Host "`n";
		Write-Warning "About to un-mount AND COMMIT the offline image located at $($iniData.mountPath)" -WarningAction Inquire
		Write-Host "Commiting Image - Running: dism.exe /unmount-image" `
			" /mountdir:$($iniData.mountPath)" `
			" /commit /checkintegrity";
		if ($bExtraConfirmation) { read-host "Press ENTER to Continue or CTRL-C to abort"; }
		dism.exe /unmount-image /mountdir:$($iniData.mountPath) /commit /checkintegrity
		Write-Host "Command $operation Completed" -backgroundcolor "Black" -foregroundcolor "Yellow";
		break
	}
	
	"commit" {
		if ($isDebug) { Write-Host "DEBUG: $operation" -backgroundcolor "Black" -foregroundcolor "Red"; }
		Write-Host "`n";
		Write-Warning "About to commit the offline image located at $($iniData.mountPath)" -WarningAction Inquire;
		Write-Host "Commiting Image - Running: dism.exe /commit-image" `
			" /mountdir:$($iniData.mountPath)" `
			" /checkintegrity";
		if ($bExtraConfirmation) { read-host "Press ENTER to Continue or CTRL-C to abort"; }
		dism.exe /commit-image /mountdir:$($iniData.mountPath) /checkintegrity;
		Write-Host "Command $operation Completed" -backgroundcolor "Black" -foregroundcolor "Yellow";
		break
	}
	
	"discard" {
		if ($isDebug) { Write-Host "DEBUG: $operation" -backgroundcolor "Black" -foregroundcolor "Red"; }
		Write-Host "`n";
		Write-Warning "About to DISCARD and un-mount the offline image located at $($iniData.mountPath)" -WarningAction Inquire;
		Write-Host "Discarding Image - Running: dism.exe /unmount-image" `
			" /mountdir:$($iniData.mountPath)" `
			" /discard";
		if ($bExtraConfirmation) { read-host "Press ENTER to Continue or CTRL-C to abort"; }
		dism.exe /unmount-image /mountdir:$($iniData.mountPath) /discard;
		Write-Host "Command $operation Completed" -backgroundcolor "Black" -foregroundcolor "Yellow"; 
		break
	}
	
	"optimize" {
		if ($isDebug) { Write-Host "DEBUG: $operation" -backgroundcolor "Black" -foregroundcolor "Red"; }
		Write-Host "`n";
		Write-Warning "About to optimize the image located at $($iniData.mountPath)" -WarningAction Inquire;
		Write-Host "Discarding Image - Running: dism.exe /image:$($iniData.mountPath)" `
			" /Optimize-Image /Boot";
		if ($bExtraConfirmation) { read-host "Press ENTER to Continue or CTRL-C to abort"; }
		dism.exe /image:$($iniData.mountPath) /Optimize-Image /Boot;
		Write-Host "Command $operation Completed" -backgroundcolor "Black" -foregroundcolor "Yellow"; 
		break
	}
	
	"analyze" {
		if ($isDebug) { Write-Host "DEBUG: $operation" -backgroundcolor "Black" -foregroundcolor "Red"; }
		Write-Host "`n";
		Write-Warning "About to analyze the image located at $($iniData.mountPath) for cleanup" -WarningAction Inquire;
		Write-Host "Analyzing Image - Running: dism.exe /image:$($iniData.mountPath)" `
			" /Cleanup-Image /AnalyzeComponentStore";
		if ($bExtraConfirmation) { read-host "Press ENTER to Continue or CTRL-C to abort"; }
		dism.exe /image:$($iniData.mountPath) /Cleanup-Image /AnalyzeComponentStore;
		Write-Host "Command $operation Completed" -backgroundcolor "Black" -foregroundcolor "Yellow"; 
		break
	}
	
	default {
		if ($isDebug) { Write-Host "DEBUG: `$operation: DEFAULT" -backgroundcolor "Black" -foregroundcolor "Red"; }
		Write-Host "`n";
		Write-Warning "No command specified - please re-run and specify one of the following commands:";
		Write-Host "$scriptName ini         redetect environment and rebuild img.ini";
		Write-Host "$scriptName split       split a WIM into smaller SWM files";
		Write-Host "$scriptName combine     combine a WIM into smaller SWM files";
		Write-Host "$scriptName mount       mount a WIM onto an offline path";
		Write-Host "$scriptName unmount     save and unmount a offline image";
		Write-Host "$scriptName discard     discard and unmount a offline image";
		Write-Host "$scriptName commit      commit an offline image leaving it mounted";
		Write-Host "$scriptName optimize    optimize image leaving it mounted";
		Write-Host "$scriptName analyze     analyze image component store leaving it mounted";
		Write-Host "`nSettings (can be modified in $scriptDir\$($scriptName.replace('.ps1','.ini'))):" -backgroundcolor "Black" -foregroundcolor "Yellow";
		Write-Host "WIM path used for mount, combine, and split operations: "$iniData.wimPath;
		Write-Host "WIM name used for mount, combine, and split operations: "$iniData.wimFile;
		Write-Host "SWM path used for combine and split operations:         "$iniData.swmPath;
		Write-Host "SWM name used for combine and split operations:         "$iniData.swmFile;
		Write-Host "Image Index used for mount and combine operations:      "$iniData.imgIndex;
		Write-Host "SWM Image Size (in MB) used for split operations:       "$iniData.maxFileSize;
		Write-Host "Mount Path used for mount, unmount, commit, and`n" `
		            "discard operations:                                    "$iniData.mountPath;
		if ($iniData.bExtraConfirmation) { $msg = "ON"; } else { $msg = "OFF"; }
		Write-Host "Extra Confirmations are turned $msg";
		Write-Host "Command $operation Completed" -backgroundcolor "Black" -foregroundcolor "Yellow"; 
		Write-Host "Press <ENTER> to continue" -backgroundcolor "Black" -foregroundcolor "Yellow"; $nothing = Read-Host;
		break
	}
}
Write-Host "Press <ENTER> to continue" -backgroundcolor "Black" -foregroundcolor "Yellow"; $nothing = Read-Host;
<# 
UNUSED TEST ITEMS
#										stanalone		qouted  "string"
#	write-host $iniData.wimFile; 		# works
#	write-host "$iniData.wimFile"; 						# does not work
#	write-host $iniData['wimFile']; 	# works
#	write-host "$iniData['wimFile']"; 					# does not work
#	write-host "$($iniData.wimFile)"; 					# WORKS
#	write-host "$($iniData['wimFile']"; 				# does not work

write-host '$iniData.wimPath:'$iniData.wimPath;
write-host '$iniData.wimFile:'$iniData.wimFile;
write-host '$iniData.swmPath:'$iniData.swmPath;
write-host '$iniData.swmFile:'$iniData.swmFile;
write-host '$iniData.imgIndex:'$iniData.imgIndex;
write-host '$iniData.maxFileSize:'$iniData.maxFileSize;
write-host '$iniData.mountPath:'$iniData.mountPath;
write-host '$iniData.bExtraConfirmation:'$iniData.bExtraConfirmation;
read-host "pause";
#>
