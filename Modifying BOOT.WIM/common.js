
var SUCCESS = 0;
var ERROR   = 1;
var WARN    = 2;
var INFO    = 3;
var DEBUG   = 4;

function cmnCHK_MD5(LIST, FOLDER)
{
	var strFunc = "cmnCHK_MD5()";
	log.record("[" + strFunc + "] start",log.DEBUG);

	var ret = true; // var ret = false; // added exception to bypass MD5
	/* var retMD5 = -1;
	var listname = fsu.getBaseName(LIST);
	if(listname!=null) {
		var ERRORLOG = strLogFileFolder + "\\" + listname + "_ERROR.txt";

		retMD5 = cmnRUN( strParentfolder + "\\tool\\ChkMD5.exe -c " + LIST + " -d " + FOLDER + ":\\ -e " + ERRORLOG, 0, true);

		if(retMD5!=0) {
			ret = false;
			var errorlog = fsu.openText(ERRORLOG,1,false,-1);
			while(!errorlog.AtEndOfStream)
			{
				log.record(errorlog.ReadLine(),log.ERROR);
			}
			errorlog.Close();

		} else {
			ret = true;

		}
	} */

	log.record("[" + strFunc + "] end",log.DEBUG);
	return ret;

}

function cmnCHK_isAC( )
{
	var strFunc = "cmnCHK_isAC()";
	log.record("[" + strFunc + "] start",log.DEBUG);
	// added exception to bypass AC check to run in VM
	/* var flag = true;
	while(flag){
		if(cmnRUN(strParentfolder + "\\tool\\ChkPwr.exe /AC", 0, true)) {
			htaDSP_ConnectAC();

		} else {
			flag=false;

		}
	} */

	log.record("[" + strFunc + "] end",log.DEBUG);
	return 0;

}

function cmnCHK_isTargetMODEL( TARGET_BIOSID )
{
	var strFunc = "cmnCHK_isTargetMODEL()";
	log.record("[" + strFunc + "] start",log.DEBUG);

	var ret = true; // var ret = false;  // added exception to bypass BIOS check to run in VM

	/* var PANASONICPC_BIOSID = new Array(3);
	PANASONICPC_BIOSID[0] = "CF";
	PANASONICPC_BIOSID[1] = "FZ";
	PANASONICPC_BIOSID[2] = "UT";

	for(var i=0;i<PANASONICPC_BIOSID.length;i++){
		log.record("with: CONFIG.biosid[" + i + "] = " + PANASONICPC_BIOSID[i],log.INFO);

		if(MACHINE.biosid.match(PANASONICPC_BIOSID[i])) {
			log.record("* MATCH * " + MACHINE.biosid + " :: " + PANASONICPC_BIOSID[i],log.INFO);
			ret = true;

		}
	}

	if(ret) {
		if(TARGET_BIOSID==null) {
			
		} else {
			log.record("compare: MACHINE BIOS_ID = " + MACHINE.biosid,log.INFO);
			ret = false;
			for(var i=0;i<TARGET_BIOSID.length;i++) {
				log.record("with: CONFIG.biosid[" + i + "] = " + TARGET_BIOSID[i],log.INFO);

				if(MACHINE.biosid.match(TARGET_BIOSID[i])) {
					log.record("* MATCH * " + MACHINE.biosid + " :: " + TARGET_BIOSID[i],log.INFO);
					ret = true;

				}
			}
		}

	} else {
		ret = false;
	} */

	log.record("[" + strFunc + "] end",log.DEBUG);
	return ret;

}

function cmnCHK_isBOOTMODE( )
{
	var strFunc = "cmnCHK_isBOOTMODE()";
	log.record("[" + strFunc + "] start",log.DEBUG);

	var ret = false;

	log.record("CONFIG  UEFI BOOT = " + CONFIG.uefi,log.INFO);
	log.record("MACHINE UEFI BOOT = " + MACHINE.isUEFI(),log.INFO);

	if(CONFIG.uefi == MACHINE.isUEFI()) {
		ret = true;

	}

	log.record("[" + strFunc + "] end",log.DEBUG);
	return ret;

}

function cmnCHK_isRCVMEDIA( TARGET_DRV )
{
	var strFunc = "cmnCHK_isRCVMEDIA()";
	log.record("[" + strFunc + "] start",log.DEBUG);
	var ret = true;

	if(!fsu.folderExists(TARGET_DRV + "Boot"))     ret = false;
	if(!fsu.folderExists(TARGET_DRV + "EFI"))      ret = false;
	if(!fsu.folderExists(TARGET_DRV + "media"))    ret = false;
	if(!fsu.folderExists(TARGET_DRV + "recovery")) ret = false;
	if(!fsu.folderExists(TARGET_DRV + "sources"))  ret = false;
	if(!fsu.fileExists(TARGET_DRV + "bootmgr"))    ret = false;
	if(!fsu.fileExists(TARGET_DRV + "bootmgr.efi"))ret = false;
	if(!fsu.fileExists(TARGET_DRV + "version.doc"))ret = false;


	log.record("[" + strFunc + "] end",log.DEBUG);
	return ret;

}

function cmnCHK_isPEBoot()
{
	var PEBOOT  = "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\WinPE\\";

	try{
		WSHShell.RegRead(PEBOOT);
	}
	catch(e){
		WSHShell.popup("Run on WinPE", 0, "Sorry...");
		WScript.Quit(0);
	}
	return 0;
}

function cmnCHK_bMBRFormat(DataDISK)
{
	var strFunc = "cmnCHK_bMBRFormat()";
	log.record("[" + strFunc + "] start",log.DEBUG);

	var ret = false;
	var MBRTargetMachine = new Array("FZ55");
	var MaxMBRDiskSize = 2150;
	var DiskSize = 0;
	switch(String(DataDISK.index).toLowerCase())
	{
		case "0":
			DiskSize = MACHINE.dsize1
			log.record("DATA_DISKINDEX :: " + DataDISK.index,log.INFO);
			break;
		case "1":
			DiskSize = MACHINE.dsize2
			log.record("DATA_DISKINDEX :: " + DataDISK.index,log.INFO);
			break;
		case "nan":
			log.record("DATA_DISKINDEX :: " + DataDISK.index,log.INFO);
			return ret;			
		default:
			log.record("DATA_DISKINDEX :: " + DataDISK.index,log.INFO);
			WSHShell.popup("NOT SUPPORT: Unknown Data disk.", 0, "Sorry...");
			WScript.Quit(0);
	}
	log.record("DATA_DISKSIZE  :: " + DiskSize,log.INFO);
	if(DiskSize <= MaxMBRDiskSize)
	{
		log.record("TARGET_MBR_FORMAT_SIZE",log.INFO);
		for(var TgtCnt = 0; TgtCnt < MBRTargetMachine.length; TgtCnt++)
		{
			if(MACHINE.biosid.indexOf(MBRTargetMachine[TgtCnt]) === 0)
			{
				log.record("TARGET_MBR_FORMAT_MACHINE",log.INFO);
				ret = true;
			}
		}
	}
	log.record("[" + strFunc + "] end",log.DEBUG);
	return ret
}

function cmnCHK_DISKSIZE(TARGET_DISK)
{
	var strFunc = "cmnCHK_DISKSIZE()";
	log.record("[" + strFunc + "] start",log.DEBUG);

	var ret = false;

	var DISKINFO;
	if(parseInt(DISK2.index)==parseInt(TARGET_DISK.index)) {
		log.record("(1).1 Target :: DISK2",log.DEBUG);
		DISKINFO = DISK2;

	} else {
		log.record("(1).2 Target :: DISK1",log.DEBUG);
		DISKINFO = DISK1;

	}

	var NEED_SIZE_SYSMSRRE = TARGET_DISK.partition[RE_INDEX].size;
	for(var i=0;i<OS_INDEX;i++) {
		NEED_SIZE_SYSMSRRE += TARGET_DISK.partition[i].size
	}
	var NEED_SIZE_OS  = CONFIG.sizeMinOS;
	var NEED_SIZE_RCV = CONFIG.sizeRcv;
	log.record("NEED_SIZE_SYSMSRRE :: " + NEED_SIZE_SYSMSRRE,log.INFO);
	log.record("NEED_SIZE_OS       :: " + NEED_SIZE_OS,log.INFO);
	log.record("NEED_SIZE_RCV      :: " + NEED_SIZE_RCV,log.INFO);

	var SPACE_SIZE_ALL = 0;
	if(parseInt(DISK2.index)==parseInt(TARGET_DISK.index)) {
		log.record("(2).1 Target :: DISK2",log.DEBUG);
		SPACE_SIZE_ALL = MACHINE.dsize2 * 1024;

	} else {
		log.record("(2).2 Target :: DISK1",log.DEBUG);
		SPACE_SIZE_ALL = MACHINE.dsize1 * 1024;

	}
	var SPACE_SIZE_WORCV = 0;
	var SPACE_SIZE_RCV =0;
	var SPACE_SIZE_WODATA = 0;
	if(DISKINFO.rcv) {
		log.record("(3).1 RCOVERY PARTITION ENABLE",log.DEBUG);
		SPACE_SIZE_RCV = DISKINFO.partition[DISKINFO.rcv-1].size;
		SPACE_SIZE_WORCV = SPACE_SIZE_ALL - SPACE_SIZE_RCV;
		if(DISKINFO.data) {
			log.record("(3).1.a DATA PARTITION ENABLE",log.DEBUG);
			var DATA_SIZE = 0;
			for(var i=DISKINFO.data-1;i<DISKINFO.rcv-1;i++) {
				DATA_SIZE += DISKINFO.partition[i].size;
			}
			SPACE_SIZE_WODATA = SPACE_SIZE_WORCV - DATA_SIZE;
		}
	} else {
		log.record("(3).2 RCOVERY PARTITION DISABLE",log.DEBUG);
		SPACE_SIZE_RCV = 0;
		SPACE_SIZE_WORCV = SPACE_SIZE_ALL - SPACE_SIZE_RCV;
		if(DISKINFO.data) {
			log.record("(3).2.a DATA PARTITION ENABLE",log.DEBUG);
			var DATA_SIZE = 0;
			for(var i=DISKINFO.data-1;i<DISKINFO.partition.length;i++) {
				DATA_SIZE += DISKINFO.partition[i].size;
			}
			SPACE_SIZE_WODATA = SPACE_SIZE_WORCV - DATA_SIZE;
		}

	}
	log.record("SPACE_SIZE_ALL    :: " + SPACE_SIZE_ALL,log.INFO);
	log.record("SPACE_SIZE_WORCV  :: " + SPACE_SIZE_WORCV,log.INFO);
	log.record("SPACE_SIZE_RCV    :: " + SPACE_SIZE_RCV,log.INFO);
	log.record("SPACE_SIZE_WODATA :: " + SPACE_SIZE_WODATA,log.INFO);


	if(SELECTED.isRcvALL) {
		log.record("(4).1 RCVALL",log.DEBUG);
		if(!bHDDRcv) {
			log.record("(4).1.1 RCVALL + DVDRCV",log.DEBUG);
			var NEED_SIZE = NEED_SIZE_SYSMSRRE + NEED_SIZE_OS + NEED_SIZE_RCV*2;
			log.record("NEED_SIZE = " + NEED_SIZE,log.DEBUG);
			if(SPACE_SIZE_ALL >= NEED_SIZE) {
				log.record("(4).1.1.a SPACE_SIZE_ALL >= NEED_SIZE",log.DEBUG);
				ret = true;
			}

		} else {
			log.record("(4).1.2 RCVALL + HDDRCV",log.DEBUG);
			var NEED_SIZE = NEED_SIZE_SYSMSRRE + NEED_SIZE_OS + NEED_SIZE_RCV;
			log.record("NEED_SIZE = " + NEED_SIZE);
			if(SPACE_SIZE_WORCV >= NEED_SIZE) {
				log.record("(4).1.2.a SPACE_SIZE_ALL >= NEED_SIZE",log.DEBUG);
				ret = true;
			}
		}

	} else {
		log.record("(4).2 PARTRCV");
		if(SELECTED.hasRcvPrt) {
			log.record("(4).2.1 PARTRCV + RCVPART",log.DEBUG);
			if(SPACE_SIZE_RCV >= NEED_SIZE_RCV) {
				log.record("(4).2.1.a SPACE_SIZE_RCV >= NEED_SIZE_RCV",log.DEBUG);
				var NEED_SIZE = NEED_SIZE_SYSMSRRE + NEED_SIZE_OS + NEED_SIZE_RCV;
				log.record("NEED_SIZE = " + NEED_SIZE,log.INFO);
				if(SPACE_SIZE_WODATA >= NEED_SIZE) {
					log.record("(4).2.a.a SPACE_SIZE_WODATA >= NEED_SIZE",log.DEBUG);
					ret = true;
				}
			}
		} else {
			log.record("(4).2.2 PARTRCV + NonRCVPART",log.DEBUG);
			var NEED_SIZE = NEED_SIZE_SYSMSRRE + NEED_SIZE_OS + NEED_SIZE_RCV;
			log.record("NEED_SIZE = " + NEED_SIZE,log.INFO);
			if(SPACE_SIZE_WODATA >= NEED_SIZE) {
				log.record("(4).2.2.a SPACE_SIZE_WODATA >= NEED_SIZE",log.DEBUG);
				ret = true;
			}
		}

	}

	if(!ret) {
		htaDSP_DiskSizeError();
		WScript.Quit(SHUTDOWN);
	}

	log.record("[" + strFunc + "] end",log.DEBUG);
	return 0;
}

function cmnCHK_isFACTORYMODE() 
{
	var strFunc = "cmnCHK_isFACTORYMODE()";
	log.record("[" + strFunc + "] start",log.DEBUG);

	var PathFactoryTxt = strParentfolder + "\\tool\\FACTORY.txt";
	var PathDumpTxt = log.log_folder + "\\DUMP.txt";

	if(!fsu.fileExists(PathFactoryTxt))
    {
		log.record("NOT Exist File :: " + PathFactoryTxt,log.INFO);
		log.record("[" + strFunc + "] end",log.DEBUG);
        return false;
    }
	if(!fsu.fileExists(PathDumpTxt))
    {
		log.record("NOT Exist File :: " + PathDumpTxt,log.INFO);
		log.record("[" + strFunc + "] end",log.DEBUG);
		return false;
    }

	var FACTORY_file = fsu.openText(PathFactoryTxt, 1, true);
	var DUMP_file =  fsu.openText(PathDumpTxt, 1, true);
	while(!FACTORY_file.AtEndOfStream)
	{
		FACTORY_line = FACTORY_file.ReadLine();
		DUMP_line = DUMP_file.ReadLine();
		if(FACTORY_line != DUMP_line)
		{
			FACTORY_file.Close();
			DUMP_file.Close();
			log.record("[" + strFunc + "] end",log.DEBUG);
			return false;
		}
	}
	FACTORY_file.Close();
	DUMP_file.Close();

	log.record("[" + strFunc + "] end",log.DEBUG);
	return true;
}

function cmnSET_DISKNAME( )
{
	var strFunc = "cmnSET_DISKNAME()";
	log.record("[" + strFunc + "] start",log.DEBUG);

	var DISP_NAME_DISK = new Array();

	DISP_NAME_DISK[0] = "Disk " + MACHINE.disk1;
	DISP_NAME_DISK[1] = "Disk " + MACHINE.disk2;

	if(CONFIG.qrelease_bus!==false) {
		if(CONFIG.qrelease_bus==MACHINE.disk1bus) {
			DISP_NAME_DISK[0] = "Quick Release Drive";

		} else if(CONFIG.qrelease_bus==MACHINE.disk2bus) {
			DISP_NAME_DISK[1] = "Quick Release Drive";

		} else {
		}
	}

	if(CONFIG.onboard_bus!==false) {
		if(CONFIG.onboard_bus==MACHINE.disk1bus) {
			DISP_NAME_DISK[0] = "On Board Drive";

		} else if(CONFIG.onboard_bus==MACHINE.disk2bus) {
			DISP_NAME_DISK[1] = "On Board Drive";

		} else {
		}
	}

	for(var i = 0; i < CONFIG.logical_if.length; i++) {
		if(MACHINE.disk1connection==CONFIG.logical_if[i].connection 
			&& MACHINE.disk1locnum==CONFIG.logical_if[i].location_number) {
			DISP_NAME_DISK[0] = CONFIG.logical_if[i].display_name;
		} else {
		}

		if(MACHINE.disk2connection==CONFIG.logical_if[i].connection 
			&& MACHINE.disk2locnum==CONFIG.logical_if[i].location_number) {
			DISP_NAME_DISK[1] = CONFIG.logical_if[i].display_name;
		} else {
		}
	}	

	log.record(".disk1 Display Name = " + DISP_NAME_DISK[0],log.INFO);
	log.record(".disk2 Display Name = " + DISP_NAME_DISK[1],log.INFO);


	log.record("[" + strFunc + "] end",log.DEBUG);
	return DISP_NAME_DISK;

}

function cmnRUN(CMD,WINDOW,WAIT,EXP)
{
	var strFunc = "cmnRUN()";
	log.record("[" + strFunc + "] start",log.DEBUG);

	if(EXP==null) {
		EXP = 0;

	}

	try {
		var retRun = WSHShell.Run( CMD, WINDOW, WAIT );
	
		if(retRun==EXP) {
			log.record("(return="+  retRun + ") " + CMD, log.INFO );

		} else {
			log.record("(return="+  retRun + ") " + CMD, log.WARN );

		}

	} catch(e) {
		cmnError( CMD + "\n" + e.description );

	}
	log.record("[" + strFunc + "] end",log.DEBUG);
	return retRun;

}

function cmnError( MSG ,FLAG )
{
	htaClose();
	htaDSP_Popup( MSG, 0, "ERROR");
	htaDSP_Err();
	if(FLAG==SHUTDOWN) {
		WSHShell.Run( "wpeutil Shutdown", 0, true );
	} else {
		WScript.Quit(SHUTDOWN);
	}
}

