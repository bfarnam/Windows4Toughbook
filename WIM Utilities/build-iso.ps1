param (
	[string]$source = $(Read-Host "Please enter the source USB drive letter [i.e. D:]"),
	[string]$iso = $(Read-Host "Please enter the ISO name for the output [i.e. MyIso.ISO]")
)
write-host "Building bootable ISO from bootable $source\ drive - Running .\Oscdimg.exe -b$source\recovery\fwfiles\efisys.bin -pEF -u1 -udfver102 $source\ .\$iso";
Read-Host "Press Enter to build bootable ISO";
.\Oscdimg.exe -b"$source\recovery\fwfiles\efisys.bin" -pEF -u1 -udfver102 "$source\" ".\$iso"
