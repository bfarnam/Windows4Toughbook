#Requires -Version 5.0
param( $operation )
$operation = $operation.ToLower();
[bool]$isDebug = $true;

function readINI
{
	#read the key pairs
	$iniData = Get-Content '.\appx-util.ini' | ConvertFrom-StringData;

	# check for missing values
	[bool]$iniError = $false
	if ( [string]::IsNullOrWhiteSpace($iniData.filePath) -or [string]::IsNullOrEmpty($iniData.filePath) ) { $iniError = $true; }
	if ( [string]::IsNullOrWhiteSpace($iniData.appxFile) -or [string]::IsNullOrEmpty($iniData.appxFile) ) { $iniError = $true; }
	if ( [string]::IsNullOrWhiteSpace($iniData.regidFile) -or [string]::IsNullOrEmpty($iniData.regidFile) ) { $iniError = $true; }
	if ( [string]::IsNullOrWhiteSpace($iniData.mountPath) -or [string]::IsNullOrEmpty($iniData.mountPath) ) { $iniError = $true; }
	if ( [string]::IsNullOrWhiteSpace($iniData.hiveBase) -or [string]::IsNullOrEmpty($iniData.hiveBase) ) { $iniError = $true; }
	if ( [string]::IsNullOrWhiteSpace($iniData.hiveName) -or [string]::IsNullOrEmpty($iniData.hiveName) ) { $iniError = $true; }
	if ( [string]::IsNullOrWhiteSpace($iniData.hiveSource) -or [string]::IsNullOrEmpty($iniData.hiveSource) ) { $iniError = $true; }
	if ( [string]::IsNullOrWhiteSpace($iniData.hiveAlias) -or [string]::IsNullOrEmpty($iniData.hiveAlias) ) { $iniError = $true; }
	if ( [string]::IsNullOrWhiteSpace($iniData.registryPath) -or [string]::IsNullOrEmpty($iniData.registryPath) ) { $iniError = $true; }
	if ( [string]::IsNullOrWhiteSpace($iniData.bExtraConfirmation) -or [string]::IsNullOrEmpty($iniData.bExtraConfirmation) ) { $iniError = $true; }

	<#write-host $iniData.filePath;
	write-host $iniData.appxFile;
	write-host $iniData.regidFile;
	write-host $iniData.mountPath;
	write-host $iniData.hiveBase;
	write-host $iniData.hiveName;
	write-host $iniData.hiveSource;
	write-host $iniData.hiveAlias;
	write-host $iniData.registryPath;
	write-host $iniData.bExtraConfirmation;
	write-host $iniError;
	read-host "pause"#>

	if ($iniError)
	{
		Write-Warning ".\appx-util.ini is empty or missing a key pair.  Please fix!";
		Read-Host "Press Enter to Abort";
		exit
	}

	#[bool]$iniData.bExtraConfirmation = $iniData.bExtraConfirmation; 

	$iniData;
}

function writeINI
{
	if (test-path .\appx-util.ini) {
		Write-Host "`n`n";
		Write-Warning ".\appx-util.ini found - OK to Overwrite?" -WarningAction Inquire;
		del .\appx-util.ini - verbose;
	}
	$var = $PSScriptRoot.replace("\","\\");
	# There can be NO extra white space becuase this is literal
$iniData = @"
filePath = $var
appxFile = appx-provo-list.txt
regidFile = appx-regid-list.txt
mountPath = C:\\offline
hiveBase = HKLM
hiveName = SOFTWARE
hiveSource = \\Windows\\System32\\config
hiveAlias = OFFLINE_SOFTWARE
registryPath = \\Microsoft\\Windows\\CurrentVersion\\Appx\\AppxAllUserStore\\Deprovisioned
bExtraConfirmation = 0
"@ ;
	Set-Content .\appx-util.ini $iniData;
	return
}

if (test-path .\appx-util.ini) {
	# read file
	$iniData = readINI;
	write-host $iniData;
	read-host "pause";
} else {
	Write-Warning ".\appx-util.ini NOT FOUND";
	Write-Warning "Do you wish to create it and continue?"  -WarningAction Inquire;
	writeINI
	notepad.exe .\appx-util.ini;
	
	$iniData = readINI;
}

# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
   { 
   # We are running 'as Administrator' - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Elevated)";
   $Host.UI.RawUI.BackgroundColor = "DarkRed"; $Host.UI.RawUI.ForegroundColor = "DarkYellow"; 
   # clear-host; 
   }
else
   {
   # We are not running "as Administrator" - so relaunch as administrator
 
   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
 
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = "-WindowStyle Maximized " + $myInvocation.MyCommand.Definition;
 
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";
 
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);
 
   # Exit from the current, unelevated, process
   exit
   }

Write-Host "Running as $env:UserName in $env:UserProfile from $PSScriptRoot";
Write-Host "`nv1.0 2023 January 13 Brett A. Farnam (brett_farnam@yahoo.com)";
Write-Host "`nOffline Image AppxProvisionedPackage Manipulation Utility appx-util.ps1";

# HKLM \ OFFLINE_SOFTWARE
$hiveMount = $iniData.hiveBase + ":\" + $iniData.hiveAlias;
# HKLM :\ OFFLINE_SOFTWARE
$hiveTarget = $iniData.hiveBase + ":\" + $iniData.hiveAlias;
# C:\offline \Windows\System32\config \ SOFTWARE
$hivePath = $iniData.mountPath + $iniData.hiveSource + "\" + $hiveName;

switch ($operation) {
	
	"build" {
		if (test-path $iniData.filePath\$iniData.appxFile) {
			Write-Host "`n`n";
			Write-Warning "$iniData.filePath\$iniData.appxFile found - deleting now" -WarningAction Inquire;
			del $iniData.filePath\$iniData.appxFile - verbose;
		}
		if (test-path $iniData.filePath\$iniData.regidFile) {
			Write-Host "`n`n";
			Write-Warning "$iniData.filePath\$iniData.regidFile found - deleting now" -WarningAction Inquire;
			del $iniData.filePath\$iniData.regidFile - verbose;
		}
		Write-Host "`nExporting Provisioned APPX Packages from the offline windows installation" `
			"`nlocated at $iniData.mountPath and saving as $iniData.filePath\$iniData.appxFile";
		$fileData = Get-AppxProvisionedPackage -Path $iniData.mountPath | Format-Table -Property PackageName -HideTableHeaders | Out-String; 
		$fileData = $fileData.Trim() -replace '\s+', "`n";
		$fileData | out-file -filepath $iniData.filePath\$iniData.appxFile -Encoding "ascii";
		Write-Host "`n`nPlease edit the file located at ""$iniData.filePath\$iniData.appxFile"" and delete the lines for" `
			"`nthe APPX Packages you wish to KEEP.  Any listings in this file will REMOVE the APPX" `
			"`nprovisioned package for ALL USERS." `
			"`nAfter you are done editing the list, save the list and run "".\appx-util.ps1 mkregid""" `
			"`nThis will generate the list used for importing into the registry so that the package" `
			"`nis deprovisioned against future re-installation by a system update.";
		notepad.exe $iniData.filePath\$iniData.appxFile;
		Write-Host "`nCommand Completed - Exiting";
		break
	}
	
	"mkregid" {
		if ( -NOT (test-path $iniData.filePath\$iniData.appxFile) ) {
			Write-Host "`n";
			Write-Warning "$iniData.filePath\$iniData.appxFile DOES NOT EXIST!";
			Write-Host "`nPlease run "".\appx-util.ps1 build"" to create the list!`nEXITING NOW!";
			exit
		}
		if (test-path $iniData.filePath\$iniData.regidFile) {
			Write-Host "`n`n";
			Write-Warning "`n$iniData.filePath\$iniData.regidFile found - deleting now";
			del $iniData.filePath\$iniData.regidFile - verbose;
		}
		Write-Host "Converting $iniData.filePath\$iniData.appxFile as REG ID and saving as $iniData.filePath\$iniData.regidFile";
		$fileData = get-content $iniData.filePath\$iniData.appxFile; 
		$OutputFile = foreach ($appxName in $fileData)
		{
			$appxName = $appxName.Trim();
			($appxName.split('_'))[0,-1] -Join '_';
		}
		$OutputFile | out-file -filepath $iniData.filePath\$iniData.regidFile -Encoding "ascii";
		Write-Host "`n`nAny listings in this file will add a deprovisioned registry key under" `
			"`n$iniData.hiveBase\$hiveName$iniData.registryPath" `
			"`nYou may now run "".\appx-util.ps1 remove"" to uninstall the APPX Package and/or" `
			"`n"".\appx-util.ps1 depro"" so that the package is deprovisioned against future" `
			"`nre-installation by a system update.";
		notepad $iniData.filePath\$iniData.regidFile;
		Write-Host "`nCommand Completed - Exiting";
		break
	}
	
	"remove" {
		if ( -NOT (test-path $iniData.filePath\$iniData.appxFile) ) {
			Write-Host "`n";
			Write-Warning "$iniData.filePath\$iniData.appxFile DOES NOT EXIST!";
			Write-Host "`nPlease run "".\appx-util.ps1 build"" to create the list!`nEXITING NOW!";
			break
		}
		$appx_list = Get-Content -Path $iniData.filePath\$iniData.appxFile;
		foreach ($appxName in $appx_list)
		{
			$appxName = $appxName.Trim();
			if ($iniData.bExtraConfirmation) {
				Write-Warning "Removing $appxName from offline image located at $iniData.mountPath" -WarningAction Inquire;
			} else {
				Write-Warning "Removing $appxName from offline image located at $iniData.mountPath";
			}
			Remove-AppxProvisionedPackage -Path $iniData.mountPath -PackageName $appxName;
		}
		Write-Host "`nCommand Completed - Exiting";
		break
	}
	
	"depro" {
		if ( -NOT (test-path $hiveTarget) ) {
			Write-Host "`n";
			Write-Warning "Remote offline registry not mounted at $hiveMount";
			Write-Host "`nPlease run "".\appx-util.ps1 load"" to attach the registry`nEXITING NOW!";
			exit
		}
		if ( -NOT (test-path $iniData.filePath\$iniData.regidFile) ) {
			Write-Host "`n";
			Write-Warning "$iniData.filePath\$iniData.regidFile DOES NOT EXIST!";
			Write-Host "`nPlease run "".\appx-util.ps1 build"" and/or "".\appx-util.ps1 mkregid""" ` 
				"to create the list!`nEXITING NOW!";
			exit
		}	
		
		if ($iniData.bExtraConfirmation) {
			Write-Warning "Creating $hiveTarget$iniData.registryPath" -WarningAction Inquire;
		} else {
			Write-Warning "Creating $hiveTarget$iniData.registryPath";
		}
		new-item -path $hiveTarget$iniData.registryPath -force - verbose;

		$appx_list = Get-Content -Path $iniData.filePath\$iniData.regidFile;
		foreach ($appxName in $appx_list)
		{
			$appxName = $appxName.Trim();
			if ($iniData.bExtraConfirmation) {
				Write-Warning "Adding Deprovisioned Registry Entry for: ";
				Write-Warning "$appxName";
				Write-Warning "under: ";
				Write-Warning "$hiveTarget$iniData.registryPath" -WarningAction Inquire;
			} else {
				Write-Warning "Adding Deprovisioned Registry Entry for: ";
				Write-Warning "$appxName";
				Write-Warning "under: ";
				Write-Warning "$hiveTarget$iniData.registryPath";
			}
			new-item -path $hiveTarget$iniData.registryPath\$appxName -force -verbose;
		}
		Write-Host "`nCommand Completed - Exiting";
		break
	}
	
	"load" {
		if ( -NOT (test-path $iniData.mountPath\Windows) ) {
			Write-Host "`n";
			Write-Warning "Offline Image at $iniData.mountPath\Windows NOT FOUND - EXITING NOW!";
			exit
		}
		if ( -NOT (test-path $hivePath) ) {
			Write-Host "`n";
			Write-Warning "Windows offline HIVE $hivePath NOT FOUND - EXITING NOW!";
			exit
		}
		if ($iniData.bExtraConfirmation) {
			Write-Warning "Mounting offline $iniData.hiveBase\$hiveName to mount point $hiveMount" -WarningAction Inquire;
		} else {
			Write-Warning "Mounting offline $iniData.hiveBase\$hiveName to mount point $hiveMount";
		}
		reg load $hiveMount $hivePath -verbose
		Write-Host "`nCommand Completed - Exiting";
		break
	}
	
	"unload" {
		if ( -NOT (test-path $hiveTarget) ) {
			Write-Host "`n";
			Write-Warning "Remote offline registry not mounted at $hiveMount";
			Write-Host "`nPlease run "".\appx-util.ps1 load"" to attach the registry`nEXITING NOW!";
			exit
		}
		if ($iniData.bExtraConfirmation) {
			Write-Warning "Unmounting $hiveMount" -WarningAction Inquire;
		} else {
			Write-Warning "Unmounting $hiveMount";
		}
		#reg unload $hiveMount
		#this context has the registry locked.  We must fire this off as itself with a secure option and close this window to release the registry.
		$newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
 
		# Specify the current script path and name as a parameter
		$newProcess.Arguments = "-WindowStyle Maximized " + $myInvocation.MyCommand.Definition + "-secure-true";
 
		# Start the new process
		[System.Diagnostics.Process]::Start($newProcess);
 
		# Exit from the current process
		exit
	}
	
	"unload-secure-true" {
		if ( -NOT (test-path $hiveTarget) ) {
			Write-Host "`n";
			Write-Warning "Remote offline registry not mounted at $hiveMount";
			Write-Host "`nPlease run "".\appx-util.ps1 load"" to attach the registry`nEXITING NOW!";
			exit
		}
		if ($iniData.bExtraConfirmation) {
			Write-Warning "Unmounting $hiveMount" -WarningAction Inquire;
		} else {
			Write-Warning "Unmounting $hiveMount";
		}
		reg unload $hiveMount - verbose;
		Write-Host "`nCommand Completed - Exiting";
		break
	}
	
	default {
		
		Write-Host "`n ";
		Write-Warning "No command specified - please re-run and specify one of the following commands:";
		Write-Host "  "".\appx-util.ps1 ini""`t`tredetect environment and rebuild .\appx-util.ini";
		Write-Host "`n  "".\appx-util.ps1 build""`tbuild the appx list for audit and use with remove";
		Write-Host "`n  "".\appx-util.ps1 mkregid""`tmake the regid list from the audited appx file";
		Write-Host "`n  "".\appx-util.ps1 remove""`tremove the appx-provisioned-package from the" `
					"`n`t`t`t`tmounted offline windows installation";
		Write-Host "`n  "".\appx-util.ps1 depro""`tadd deprovisioned registry entries so that the" `
					"`n`t`t`t`tappx package isn't re-added after an os update later";
		Write-Host "`n  "".\appx-util.ps1 load""`tmount an offline registry from an offline image";
		Write-Host "`n  "".\appx-util.ps1 unload""`tunload the mounted offline registry";
		Read-Host "Press ENTER to Continue...";
		Write-Host "  Settings (can be modified in .\appx-util.ini):" -backgroundcolor "Black" -foregroundcolor "Yellow";
		Write-Host "  file path used for appx and regid lists:`n`t"$iniData.filePath;
		Write-Host "`n  appx list file name:`n`t"$iniData.appxFile;
		Write-Host "`n  regid list file name:`n`t"$iniData.regidFile;
		Write-Host "`n  mount path of the offline image:`n`t"$iniData.mountPath;
		Write-Host "`n  targeted registry hive base:`n`t"$iniData.hiveBase;
		Write-Host "`n  targeted registry hive:`n`t"$iniData.hiveName;
		Write-Host "`n  path to registry hives:`n`t"$iniData.hiveSource;
		Write-Host "`n  local registry mount point:`n`t"$iniData.hiveAlias;
		Write-Host "`n  targeted registry path:`n`t"$iniData.registryPath;
		if ($iniData.bExtraConfirmation) { $msg = "ON"; } else { $msg = "OFF"; }
		Write-Host "`n  Extra Confirmations are turned:`n`t$msg";
		break
	}
}


<#
write-host $iniData.filePath;
write-host $iniData.appxFile;
write-host $iniData.regidFile;
write-host $iniData.mountPath;
write-host $iniData.hiveBase;
write-host $iniData.hiveName;
write-host $iniData.hiveSource;
write-host $iniData.hiveAlias;
write-host $iniData.registryPath;
write-host $iniData.bExtraConfirmation;
write-host $iniError;
read-host "pause";
#>