;===============================================================================
;DONT FORGET TO UPDATE VERSION NUMBERS AND DATES
;REVISED 201101215
;===============================================================================
#include-once
#Include <Array.au3>
#include <Security.au3>
#Include <String.au3>
#include <File.au3>
;===============================================================================
; Function Name:    _TreeList()
; Description:
; Call With:		_TreeList()
; Parameter(s):
; Return Value(s):  On Success -
; 					On Failure -
; Author(s):        JohnMC - www.TeamMC.cc
; Date/Version:		06/02/2011  --  v1.0
;===============================================================================
func _TreeList($path, $mode=1)
	local $FileList_Original=_FileListToArray($path,"*",0)
	local $FileList[1]

	for $i=1 to ubound($FileList_Original)-1
		local $file_path=$path&"\"&$FileList_Original[$i]
		if StringInStr(FileGetAttrib($file_path),"D") then
			$new_array=_TreeList($file_path,$mode)
			_ArrayConcatenate($FileList,$new_array,1)
		else
			ReDim $FileList[UBound($FileList)+1]
			$FileList[UBound($FileList)-1]=$file_path
		endif
	next

	return $FileList
endfunc
;===============================================================================
; Function Name:    _StringStripWS()
; Description:		Strips all white chars, excluing char(32) the reglar space
; Call With:		_StringStripWS($String)
; Parameter(s): 	$String - String To Strip
; Return Value(s):  On Success - Striped String
; 					On Failure - Full String
; Author(s):        JohnMC - www.TeamMC.cc
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
func _StringStripWS($String)
	return StringRegExpReplace($string,"["&chr(0)&chr(9)&chr(10)&chr(11)&chr(12)&chr(13)&"]","")
endfunc
;===============================================================================
; Function Name:    _mousecheck()
; Description:		Checks for mouse movement
; Call With:		_mousecheck($Sleep)
; Parameter(s): 	$Sleep - Miliseconds between mouse checks, 0=Compare At Next Call
; Return Value(s):  On Success - 1 (Mouse Moved)
; 					On Failure - 0 (Mouse Didnt Move)
; Author(s):        JohnMC - www.TeamMC.cc
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
Func _MouseCheck($Sleep=300)
	Local $MOUSECHECK_POS1, $MOUSECHECK_POS2

	if $Sleep=0 then Global $MOUSECHECK_POS1
	if isarray($MOUSECHECK_POS1)=0 And $Sleep=0 then $MOUSECHECK_POS1=MouseGetPos()
	Sleep($Sleep)
	$MOUSECHECK_POS2=MouseGetPos()
	If Abs($MOUSECHECK_POS1[0]-$MOUSECHECK_POS2[0])>2 Or Abs($MOUSECHECK_POS1[1]-$MOUSECHECK_POS2[1])>2 Then
		if $Sleep=0 then $MOUSECHECK_POS1=$MOUSECHECK_POS2
		Return 1
	endif

	Return 0
EndFunc
;===============================================================================
; Function Name:    _sini()
; Description:		Easily create or work with 2d arrays, such as the ones produced by INIReadSection()
; Call With:		_sini(ByRef $Array, $Key[, $Value[, $Extended]])
; Parameter(s): 	$Array - A previously declared array, if not array, it will be made as one
;					$Key - The value to look for in the first column/dimention or the "Key" in an INI section
;		(Optional)	$Value - The value to write to the array
;		(Optional)	$Extended - Special options turned on by adding a letter to this string (See notes)
;
; Return Value(s):  On Success - The value found or set
; 					On Failure - "" and sets @error to 1 if value is not found ($Extended can override this)
;
; Author(s):        JohnMC - www.TeamMC.cc
; Date/Version:		01/29/2010  --  v1.0
; Notes:            $Array[0][0] Contains the number of stored parameters
;					Special $Extended Codes:
;						d=value passed is used as default value IF key doesnt already have a value
;						D=d+Check for default value in global var $default_xxx
;						e=encrypt/decrypt value
;						E=e+Use the computers hardware key to encrypt/decrypt
; Example:			_sini($Settings,"trayicon","1","d")
;===============================================================================
Func _sini(ByRef $Array,$Key,$Value=default,$Extended="")
	Local $Alert=0
	if $Value=default then $Alert=1

	If Not IsArray($array) Then Dim $array[1][2]
	If stringinstr($Extended,"E",1) Then $Pass=DriveGetSerial(StringLeft(@WindowsDir,2))&@CPUArch&@OSBuild&$Key
	If stringinstr($Extended,"e",1) Then $Pass="a1e2i3o4u5y6"&$Key

	For $i=1 To UBound($Array)-1;Check for existing key
		If $Array[$i][0]=$Key Then
			If $Value=default OR stringinstr($Extended,"D",1) OR ($Value="" and stringinstr($Extended,"d")=0) Then ;Read Existing Value
				If stringinstr($Extended,"e") Then
					$decrypt=_StringEncrypt(0,$array[$i][1],$Pass,2)
					If $decrypt=0 Then $decrypt=""
					Return $decrypt
				Else
					Return $array[$i][1]
				EndIf
			Else
				If stringinstr($Extended,"e") Then				;Change Existing Value
					$Array[$i][1]=_StringEncrypt(1,$Value,$Pass,2)
				Else
					$Array[$i][1]=$Value
				EndIf
				$Array[0][0]=UBound($Array)-1
				Return $Value
			EndIf
		EndIf
	Next

	if ($Value="" or $Value=default) and StringInStr($Extended,"D",1) then $Value=Eval("default_"&$Key)

	if $Value=default then
		MsgBox(48,"Error In "&@ScriptName,"Missing Value For Setting """&$Key&""""&@CRLF&"Press Ok To Continue")
	else
		$iUBound = UBound($Array)
		ReDim $Array[$iUBound + 1][2]
		$Array[$iUBound][0]=$Key
		$Array[$iUBound][1]=$Value
		if stringinstr($Extended,"e") then $Array[$iUBound][1]=_StringEncrypt(1,$Value,$Pass,2)
		$Array[0][0]=UBound($Array)-1
		return $Value
	endif

	SetError(1)
	return ""
EndFunc ;==>_sini
;===============================================================================
; Function Name:   	_cfl()
; Description:		Console & File Loging
; Call With:		_ProcessOwner($PID,$Hostname)
; Parameter(s): 	$Text - Text to print
;					$SameLine - (Optional) Will continue to print on the same line if  to 1
; Return Value(s):  The Text Originaly Sent
; Notes:			Will see if global var $DEBUGLOG=1 or $CmdLineRaw contains "-debuglog" to see if log file should be writen
;					If Text = "OPENLOG" then log file is displayed (casesense)
; Author(s):        JohnMC - www.TeamMC.cc
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
Func _cfl($Text,$SameLine=0)
	Local $LogFile, $Line, $Handle, $Data

	$LogFile=@ScriptFullPath&"_Log.txt"
	If Eval("DEBUGLOG")=2 Or StringInStr($CmdLineRaw,"-debuglogtempdir") then $LogFile=@TempDir&"\"&@ScriptName&"_Log.txt"
	If StringInStr($CmdLineRaw,"-debuglogworkingdir") then $LogFile=@WorkingDir&"\"&@ScriptName&"_Log.txt"

	$Line=@CRLF&@HOUR&":"&@MIN&":"&@SEC&"> "&$Text
	If $SameLine=1 Then $Line=$Text

	ConsoleWrite($Line)
	If Eval("DEBUGLOG")>0 Or StringInStr($CmdLineRaw,"-debuglog") Then
		if FileGetSize($LogFile)>1048576 then
			$Data=stringtrimleft(FileRead($LogFile),stringlen($Line)*2)
			$Handle=fileopen($LogFile,2)
			FileWrite($Handle,$Data)
		Else
			$Handle=fileopen($LogFile,1)
		endif
		FileWrite($Handle,$Line)
		fileclose($Handle)

	endif
	If $Text=="OPENLOG" Then shellexecute($LogFile)

	Return $Text
EndFunc
;===============================================================================
; Function Name:    _ntime()
; Description:		Returns time since 0 unlike the unknown timestamp behavior of timer_init
; Call With:		_ntime([$Flag])
; Parameter(s): 	$Flag - (Optional) Default is 0 (Miliseconds)
;						1 = Return Total Seconds
;						2 = Return Total Minutes
; Return Value(s):  On Success - Time
; Author(s):        JohnMC - www.TeamMC.cc
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
Func _ntime($Flag=0)
	Local $Time

	$Time=@YEAR*365*24*60*60*1000
	$Time=$Time+@YDAY*24*60*60*1000
	$Time=$Time+@HOUR*60*60*1000
	$Time=$Time+@MIN*60*1000
	$Time=$Time+@SEC*1000
	$Time=$Time+@MSEC

	If $Flag=1 Then Return Int($Time/1000) ;Return Seconds
	If $Flag=2 Then Return Int($Time/1000/60) ;Return Minutes
	Return Int($Time) ;Return Miliseconds
EndFunc
;===============================================================================
; Function Name:    _proc_waitnew()
; Description:		Wait for a new proccess to be created before continuing
; Call With:		_proc_waitnew($proc,$timeout=0)
; Parameter(s): 	$Process - PID or proccess name
;					$Timeout - (Optional) Miliseconds Before Giving Up
; Return Value(s):  On Success - 1
; 					On Failure - 0 (Timeout)
; Author(s):        JohnMC - www.TeamMC.cc
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
Func _proc_waitnew($Process,$Timeout=0)
	Local $Count1=_proc_count(), $Count2
	Local $StartTime=_ntime()

	While 1
		$Count2=_proc_count()
		if $Count2>$Count1 then return 1
		if $Count2<$Count1 then $Count1=$Count2

		If $Timeout>0 And $StartTime<_ntime()-$Timeout Then ExitLoop
		Sleep(100)
	WEnd

	Return 0
EndFunc
;===============================================================================
; Function Name:    _proc_count()
; Description:		Returns the number of processes with the same name
; Call With:		_proc_count([$Process[,$OnlyUser]])
; Parameter(s): 	$Process - PID or process name
;					$OnlyUser - Only evaluate processes from this user
; Return Value(s):  On Success - Count
; Author(s):        JohnMC - www.TeamMC.cc
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
Func _proc_count($Process=@AutoItPID,$OnlyUser="")
	Local $Count=0, $Array=ProcessList($Process)

	for $i=1 To $Array[0][0]
		if $Array[$i][1]=$Process then
			if $OnlyUser<>"" And $OnlyUser<>_ProcessOwner($Array[$i][1]) then ContinueLoop
			$Count=$Count+1
		endif
	Next

	Return $Count
EndFunc
;===============================================================================
; Function Name:    _ProcessOwner()
; Description:		Gets username of the owner of a PID
; Call With:		_ProcessOwner($PID[,$Hostname])
; Parameter(s): 	$PID - PID of proccess
;					$Hostname - (Optional) The computers name to check on
; Return Value(s):  On Success - Username of owner
; 					On Failure - 0
; Author(s):        JohnMC - www.TeamMC.cc
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
Func _ProcessOwner($PID,$Hostname=".")
	Local $User, $objWMIService, $colProcess, $objProcess

	$objWMIService = ObjGet("winmgmts://" & $Hostname & "/root/cimv2")
	$colProcess = $objWMIService.ExecQuery("Select * from Win32_Process Where ProcessID ='" & $PID & "'")

	For $objProcess In $colProcess
		If $objProcess.ProcessID = $PID Then
			$User = 0
			$objProcess.GetOwner($User)
			Return $User
		EndIf
	Next
EndFunc
;===============================================================================
; Function Name:    _ProcessCloseOthers()
; Description:		Closes other proccess of the same name
; Call With:		_ProcessCloseOthers([$Process[,$ExcludingUser[,$OnlyUser]]])
; Parameter(s): 	$Process - (Optional) Name or PID
;					$ExcludingUser - (Optional) Username of owner to exclude
;					$OnlyUser - (Optional) Username of proccesses owner to close
; Return Value(s):  On Success - 1
; Author(s):        JohnMC - www.TeamMC.cc
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
func _ProcessCloseOthers($Process=@ScriptName,$ExcludingUser="",$OnlyUser="")
	Local $Array=ProcessList($Process)

	for $i=1 To $Array[0][0]
		if ($Array[$i][1]<>@AutoItPID) then
			if $ExcludingUser<>"" AND _ProcessOwner($Array[$i][1])<>$ExcludingUser then
				ProcessClose($Array[$i][1])
			elseif $OnlyUser<>"" and _ProcessOwner($Array[$i][1])=$OnlyUser then
				ProcessClose($Array[$i][1])
			elseif $OnlyUser="" AND $ExcludingUser="" then
				ProcessClose($Array[$i][1])
			endif
		endif
	Next
endfunc
;===============================================================================
; Function Name:    _only_instance()
; Description:		Checks to see if we are the only instance running
; Call With:		_only_instance($Flag)
; Parameter(s): 	$Flag
;						0 = Continue Anyway
;						1 = Exit Without Notification
;						2 = Exit After Notifying
;						3 = Prompt What To Do
;						4 = Close Other Proccesses
; Return Value(s):  On Success - 1 (Found Another Instance)
; 					On Failure - 0 (Didnt Find Another Instance)
; Author(s):        JohnMC - www.TeamMC.cc
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
func _only_instance($Flag);0=Continue 1=Exit 2=Inform/Exit 3=Prompt
	Local $ERROR_ALREADY_EXISTS = 183, $Handle, $LastError, $Message

	if @Compiled=0 then return 0

	$Handle = DllCall("kernel32.dll", "int", "CreateMutex", "int", 0, "long", 1, "str", @ScriptName)
	$LastError = DllCall("kernel32.dll", "int", "GetLastError")
	If $LastError[0] = $ERROR_ALREADY_EXISTS Then
		SetError($LastError[0], $LastError[0], 0)
		Switch $Flag
			case 0
				return 1
			case 1
				ProcessClose(@AutoItPID)
			case 2
				MsgBox(262144+48,@ScriptName,"The Program Is Already Running")
				ProcessClose(@AutoItPID)
			case 3
				if MsgBox(262144+256+48+4,@ScriptName, "The Program ("&@ScriptName&") Is Already Running, Continue Anyway?")=7 then ProcessClose(@AutoItPID)
			case 4
				_ProcessCloseOthers()
		EndSwitch
		return 1
	EndIf
	return 0
endfunc
;===============================================================================
; Function Name:    _MsgBox()
; Description:		Displays a msgbox without haulting script by using /AutoIt3ExecuteLine
; Call With:		_MsgBox($Flag,$Title,$Text,$Timeout=0)
; Parameter(s): 	All the same options as standard message box
; Return Value(s):  On Success - PID of new proccess
; 					On Failure - 0
; Author(s):        JohnMC - www.TeamMC.cc
; Date/Version:		01/29/2010  --  v1.1
;===============================================================================
Func _MsgBox($Flag,$Title,$Text,$Timeout=0)
	if $Title="" then $Title=@ScriptName
	if $Flag="" or IsInt($Flag)=0 then $Flag=0
	return Run('"'&@AutoItExe&'"' & ' /AutoIt3ExecuteLine "msgbox('&$Flag&','''&$Title&''','''&$Text&''','''&$Timeout&''')"')
EndFunc
;===============================================================================
; Function Name:    _drive_find()
; Description:		Find a drives letter based on the drives serial
; Call With:		_drive_find($Serial)
; Parameter(s): 	$Serial - Serial of the drive
; Return Value(s):  On Success - Drive letter with ":"
; 					On Failure - 0
; Author(s):        JohnMC - www.TeamMC.cc
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
Func _drive_find($Serial)
	Local $Drivelist
	$Drivelist=StringSplit("c:,d:,e:,f:,g:,h:,i:,j:,k:,l:,m:,n:,o:,p:,q:,r:,s:,t:,u:,v:,w:,x:,y:,z:",",")
	for $i=1 to $Drivelist[0]
		If (DriveGetSerial($Drivelist[$i])=$Serial AND DriveStatus($Drivelist[$i]) = "READY") then return $Drivelist[$i]
	next
	return 0
endfunc
;===============================================================================
; Function Name:    _drive_serial()
; Description:		Gets a drives serial from inputbox, and displays it
; Call With:		_drive_serial()
; Parameter(s): 	None
; Return Value(s):  On Success - Drive letter with ":"
; 					On Failure - 0
; Author(s):        JohnMC - www.TeamMC.cc
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
Func _drive_serial()
	Local $Letter, $Serial

	while 1
		$Letter = InputBox("Drive Serial", "Please Enter Drive Letter To Get The Serial Number")
		if @Error=1 then return 0
		if StringLen($Letter)=1 then $Letter=$Letter&":"
		$Serial=DriveGetSerial($Letter)
		if @error then
			msgbox(0,"Drive Serial","Invalid Input")
		Else
			InputBox("Drive Serial", "This is the drives serial number",$Serial)
			return $Serial
		endif
	wend
endfunc
;===============================================================================
; Function Name:    _Speak()
; Description:		Speaks or creates audio file of the specified text
; Call With:		_Speak($Text[,$Speed,[$File]])
; Parameter(s): 	$Text - What to speak
;					$Speed - (Optional) How fast to speak
;					$File - (Optional) Filename to record to if specified (Wont speak outloud)
; Return Value(s):  On Success - 1
; Author(s):        JohnMC - www.TeamMC.cc
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
func _Speak($Text,$Speed=-3,$File="")
	Local $ObjVoice, $ObjFile

	$ObjVoice=ObjCreate("Sapi.SpVoice")
    if $File<>"" then
		$ObjFile=ObjCreate("SAPI.SpFileStream.1")
		$objFile.Open($File,3)
		$objVoice.AudioOutputStream = $objFile
	endif
    $objVoice.Speak ('<rate speed="'&$Speed&'">'&$Text&'</rate>', 8)

	return 1
endfunc
;===============================================================================
; Function Name:    Junk Functions & Other Peoples Functions
;===============================================================================
Func _GetDefaultPrinter()
    Local $result,$strComputer,$np,$colEvents
    $result = ''

    $strComputer = "."
    $objWMIService = ObjGet("winmgmts:\\" & $strComputer & "\root\cimv2")

    $colEvents = $objWMIService.ExecQuery _
            ("Select * From Win32_Printer Where Default = TRUE");TRUE
    $np = 0

    For $objPrinter in $colEvents
        $result = $objPrinter.DeviceID
    Next

    Return $result
EndFunc
Func _PrinterSetAsDefault($PrinterName)
    Local $result, $strComputer, $colEvents, $np

    ;If $currentPrinter = $PrinterName Then Return
    $result = 0
    $strComputer = "."
    $objWMIService = ObjGet("winmgmts:\\" & $strComputer & "\root\cimv2")
    $colEvents = $objWMIService.ExecQuery _
            (StringFormat('Select * From Win32_Printer')); Where DeviceID = "%s"', $PrinterName));TRUE
    $np = 0
    For $objPrinter in $colEvents
        If $objPrinter.DeviceID = $PrinterName Then
            $objPrinter.SetDefaultPrinter()
            $result = 1
        EndIf

    Next
    Return $result

EndFunc
func _PrintDialogWait($sPrinter="",$sPages="",$sCopies="",$sProssess="",$iTimeout=20)
	local $timer=TimerInit(), $proccess, $pid, $reqpid, $index, $title="[TITLE:Print; CLASS:#32770]"

	while 1;WAIT LOOP
		sleep(10)
		if TimerDiff($timer)>$iTimeout*1000 then return 0;Timed Out

		$pid=WinGetProcess($title)
		if $pid<>-1 then
			if $sProssess<>"" Then
				$reqpid=ProcessExists($sProssess)
				if $reqpid=0 OR $pid<>$reqpid then continueloop
			endif

			exitloop
		endif
	wend

	sleep(500)

	for $i=1 to 4;CHECK FOR UNEXPECTED WINDOW
		if StringInStr(WinGetText("[TITLE:Print; INSTANCE:"&$i&"]"),"Before you can print, you need to select a printer") then
			ControlCommand ("[TITLE:Print; INSTANCE:"&$i&"]","","[CLASS:Button; INSTANCE:1]","Check")
			sleep(1000)
			$handle=WinGetHandle($title)
		endif
	next

	if $sPrinter<>"" then;ADJ PRINTER
		for $i=1 to 80;FIND
			$index=ControlListView ($title,"","[CLASS:SysListView32; INSTANCE:1]","FindItem",$sPrinter)
			if $index<>-1 then ExitLoop
			sleep(10)
		Next
		if $i>=80 then return -7

		for $i=1 to 80;SELECT
			ControlListView ($title,"","[CLASS:SysListView32; INSTANCE:1]","Select",$index)
			if NOT @error then ExitLoop
			sleep(10)
		Next
		if $i>=40 then return -3
	endif

	if $sPages<>"" then;PAGES
		for $i=1 to 80
			ControlSetText ($title,"","[CLASS:Edit; INSTANCE:4]",$sPages)
			if NOT @error then ExitLoop
			sleep(10)
		Next
		if $i>=20 then return -4
	endif

	if $sCopies<>"" then;COPIES
		for $i=1 to 80
			ControlSetText ($title,"","[CLASS:Edit; INSTANCE:5]",$sCopies)
			if NOT @error then ExitLoop
			sleep(10)
		Next
		if $i>=20 then return -5
	endif

	sleep(500)

	for $i=1 to 80;PRESS OK
		ControlCommand ($title,"","[CLASS:Button; INSTANCE:13]","check")
		if NOT @error then ExitLoop
		sleep(10)
	Next
	if $i>=80 then return -6

	return 1
endfunc
Func _isip($ip,$P_strict=0)
    $t_ip=$ip
    $port=StringInStr($t_ip,":");check for : (for the port)
    If $port Then ;has a port attached
        $t_ip=StringLeft($ip,$port-1);remove the port from the rest of the ip
        If $P_strict Then ;return 0 if port is wrong
            $zport=Int(StringTrimLeft($ip,$port));retrieve the port
            If $zport>65000 Or $zport<0 Then Return 0;port is wrong
        EndIf
    EndIf
    $zip=StringSplit($t_ip,".")
    If $zip[0]<>4  Then Return 0;incorect number of segments
    If Int($zip[1])>255 Or Int($zip[1])<1 Then Return 0;xxx.ooo.ooo.ooo
    If Int($zip[2])>255 Or Int($zip[1])<0 Then Return 0;ooo.xxx.ooo.ooo
    If Int($zip[3])>255 Or Int($zip[3])<0 Then Return 0;ooo.ooo.xxx.ooo
    If Int($zip[4])>255 Or Int($zip[4])<0 Then Return 0;ooo.ooo.ooo.xxx
    $bc=1 ; is it 255.255.255.255 ?
    For $i=1 To 4
        If $zip[$i]<>255 Then $bc=0;no
        ;255.255.255.255 can never be a ip but anything else that ends with .255 can be
        ;ex:10.10.0.255 can actually be an ip address and not a broadcast address
    Next
    If $bc Then Return 0;a broadcast address is not really an ip address...
    If $zip[4]=0 Then;subnet not ip
        If $port Then
            Return 0;subnet with port?
        Else
            Return 2;subnet
        EndIf
    EndIf
    Return 1;;string is a ip
EndFunc
func _IsInternet()
	local $Ret = DllCall("wininet.dll", 'int', 'InternetGetConnectedState', 'dword*', 0x20, 'dword', 0)
	if (@error) then
		return SetError(1, 0, 0)
	endif
	local $wError = _WinAPI_GetLastError()
	return SetError((not ($wError = 0)), $wError, $Ret[0])
endfunc
Func _array2string($array)
	Local $string
	For $i=0 To UBound($array)-1
		$string=$string&"["&$i&"] => "&$array[$i]&@CRLF
	Next
	Return $string
EndFunc
Func _ImageSearch($findImage,$wndhnd="",$tolerance=0,$drawbox=0,$DLL="_ImageSearchDLL.dll",$x1=0,$y1=0,$x2=@DesktopWidth,$y2=@DesktopHeight)
	Dim $cords[6]

	If $wndhnd <> "" Then
		$wpos=WinGetPos($wndhnd)
		$x1=$wpos[0]
		$y1=$wpos[1]
		$x2=$wpos[0]+$wpos[2]
		$y2=$wpos[1]+$wpos[3]
	EndIf

	if $drawbox=1 then _DrawBox($x1,$y1,$x2,$y2)

	If Not IsDeclared("ImageSearch_hDll") Then
        Global $ImageSearch_hDll
		$ImageSearch_hDll=DllOpen($DLL)
    EndIf

	if $findImage="unload" then
		DllClose($ImageSearch_hDll)
		return
	EndIf

	if $tolerance>0 then $findImage = "*" & $tolerance & " " & $findImage
	$result = DllCall($ImageSearch_hDll,"str","ImageSearch","int",$x1,"int",$y1,"int",$x2,"int",$y2,"str",$findImage)

    if @error Or $result[0]="0" then return 0

	$array = StringSplit($result[0],"|")

	$cords[0]=Int(Number($array[2]));Top?
	$cords[1]=Int(Number($array[3]));Left?
	$cords[2]=Int(Number($array[2]))+Int(Number($array[4]))-1;Bottom?
	$cords[3]=Int(Number($array[3]))+Int(Number($array[5]))-1;Right?
	$cords[4]=Int(($cords[0]+$cords[2])/2);Center X
	$cords[5]=Int(($cords[1]+$cords[3])/2);Center Y

	return $cords
EndFunc
Func _DrawBox($X1,$Y1,$X2,$Y2);LEFT TOP RIGHT BOTTOM
	$COLOR=0x00FF00

    $DC = DllCall ("user32.dll", "int", "GetDC", "hwnd", "")
    $DLLH = DllOpen ("gdi32.dll")

	For $i=$X1 To $X2
		DllCall ($DLLH, "long", "SetPixel", "long", $DC[0], "long", $i, "long", $Y1, "long", $COLOR)
		DllCall ($DLLH, "long", "SetPixel", "long", $DC[0], "long", $i, "long", $Y2, "long", $COLOR)
	Next
	For $i=$Y1 To $Y2
		DllCall ($DLLH, "long", "SetPixel", "long", $DC[0], "long", $X1, "long", $i, "long", $COLOR)
		DllCall ($DLLH, "long", "SetPixel", "long", $DC[0], "long", $X2, "long", $i, "long", $COLOR)
	Next

	$DLLH = DllClose($DLLH)
EndFunc
;=============================================================================================
; Name...........: _HighPrecisionSleep()
; Description ...: Sleeps down to 0.1 microseconds
; Syntax.........: _HighPrecisionSleep( $iMicroSeconds, $hDll=False)
; Parameters ....:  $iMicroSeconds        - Amount of microseconds to sleep
;                   $hDll  - Can be supplied so the UDF doesn't have to re-open the dll all the time.
; Return values .: None
; Author ........: Andreas Karlsson (monoceres)
; Remarks .......: Even though this has high precision you need to take into consideration that it will take some time for autoit to call the function.
;=============================================================================================
Func _HighPrecisionSleep($iMicroSeconds,$dll="")
    Local $hStruct, $bLoaded
	If $dll<>"" Then $HPS_hDll=$dll
    If Not IsDeclared("HPS_hDll") Then
        Global $HPS_hDll
		$HPS_hDll=DllOpen("ntdll.dll")
        $bLoaded=True
    EndIf
    $hStruct=DllStructCreate("int64 time;")
    DllStructSetData($hStruct,"time",-1*($iMicroSeconds*10))
    DllCall($HPS_hDll,"dword","ZwDelayExecution","int",0,"ptr",DllStructGetPtr($hStruct))
EndFunc
;===============================================================================
; Function:		_ProcessGetWin
; Purpose:		Return information on the Window owned by a process (if any)
; Syntax:		_ProcessGetWin($iPID)
; Parameters:	$iPID = integer process ID
; Returns:  	On success returns an array:
; 					[0] = Window Title (if any)
;					[1] = Window handle
;				If $iPID does not exist, returns empty array and @error = 1
; Notes:		Not every process has a window, indicated by an empty array and
;   			@error = 0, and not every window has a title, so test [1] for the handle
;   			to see if a window existed for the process.
; Author:		PsaltyDS at www.autoitscript.com/forum
;===============================================================================
Func _ProcessGetWin($iPID)
    Local $avWinList = WinList(), $avRET[2]
    For $n = 1 To $avWinList[0][0]
        If WinGetProcess($avWinList[$n][1]) = $iPID Then
            $avRET[0] = $avWinList[$n][0] ; Title
            $avRET[1] = $avWinList[$n][1] ; HWND
            ExitLoop
        EndIf
    Next
    If $avRET[1] = "" Then SetError(1)
    Return $avRET
EndFunc   ;==>_ProcessGetWin
;===============================================================================
Func _FileSetDefaultContextItem($ext, $verb)
	$loc = RegRead("HKCR\." & $ext, "")
	If @error Then return 0

	RegWrite("HKCR\" & $loc & "\shell", "", "REG_SZ", $verb)
	If @error Then return 0
	return 1
EndFunc
;===============================================================================
Func _FileGetDefaultContextItem($ext)
	$loc = RegRead("HKCR\." & $ext, "")
	If @error Then return 0

	$curverb = RegRead("HKCR\" & $loc & "\shell", "")
	If @error Then return 0

	return $curverb
EndFunc
;==============================================================================================
; Description:		FileRegister($ext, $cmd, $verb[, $def[, $icon = ""[, $desc = ""]]])
;					Registers a file type in Explorer
; Parameter(s):		$ext - 	File Extension without period eg. "zip"
;					$cmd - 	Program path with arguments eg. '"C:\test\testprog.exe" "%1"'
;							(%1 is 1st argument, %2 is 2nd, etc.)
;					$verb - Name of action to perform on file
;							eg. "Open with ProgramName" or "Extract Files"
;					$def - 	Action is the default action for this filetype
;							(1 for true 0 for false)
;							If the file is not already associated, this will be the default.
;					$icon - Default icon for filetype including resource # if needed
;							eg. "C:\test\testprog.exe,0" or "C:\test\filetype.ico"
;					$desc - File Description eg. "Zip File" or "ProgramName Document"
;===============================================================================================
Func _FileRegister($ext, $cmd, $verb, $def = 0, $icon = "", $desc = "")
	$loc = RegRead("HKCR\." & $ext, "")
	If @error Then
		RegWrite("HKCR\." & $ext, "", "REG_SZ", $ext & "file")
		$loc = $ext & "file"
	EndIf
	$curdesc = RegRead("HKCR\" & $loc, "")
	If @error Then
		If $desc <> "" Then
			RegWrite("HKCR\" & $loc, "", "REG_SZ", $desc)
		EndIf
	Else
		If $desc <> "" And $curdesc <> $desc Then
			RegWrite("HKCR\" & $loc, "", "REG_SZ", $desc)
			RegWrite("HKCR\" & $loc, "olddesc", "REG_SZ", $curdesc)
		EndIf
		If $curdesc = "" And $desc <> "" Then
			RegWrite("HKCR\" & $loc, "", "REG_SZ", $desc)
		EndIf
	EndIf
	$curverb = RegRead("HKCR\" & $loc & "\shell", "")
	If @error Then
		If $def = 1 Then
			RegWrite("HKCR\" & $loc & "\shell", "", "REG_SZ", $verb)
		EndIf
	Else
		If $def = 1 Then
			RegWrite("HKCR\" & $loc & "\shell", "", "REG_SZ", $verb)
			RegWrite("HKCR\" & $loc & "\shell", "oldverb", "REG_SZ", $curverb)
		EndIf
	EndIf
	$curcmd = RegRead("HKCR\" & $loc & "\shell\" & $verb & "\command", "")
	If Not @error Then
		RegRead("HKCR\" & $loc & "\shell\" & $verb & "\command", "oldcmd")
		If @error Then
			RegWrite("HKCR\" & $loc & "\shell\" & $verb & "\command", "oldcmd", "REG_SZ", $curcmd)
		EndIf
	EndIf
	RegWrite("HKCR\" & $loc & "\shell\" & $verb & "\command", "", "REG_SZ", $cmd)
	If $icon <> "" Then
		$curicon = RegRead("HKCR\" & $loc & "\DefaultIcon", "")
		If @error Then
			RegWrite("HKCR\" & $loc & "\DefaultIcon", "", "REG_SZ", $icon)
		Else
			RegWrite("HKCR\" & $loc & "\DefaultIcon", "", "REG_SZ", $icon)
			RegWrite("HKCR\" & $loc & "\DefaultIcon", "oldicon", "REG_SZ", $curicon)
		EndIf
	EndIf
EndFunc
;===============================================================================
; Description:		FileUnRegister($ext, $verb)
;					UnRegisters a verb for a file type in Explorer
; Parameter(s):		$ext - File Extension without period eg. "zip"
;					$verb - Name of file action to remove
;							eg. "Open with ProgramName" or "Extract Files"
;===============================================================================
Func _FileUnRegister($ext, $verb)
	$loc = RegRead("HKCR\." & $ext, "")
	If Not @error Then
		$oldicon = RegRead("HKCR\" & $loc & "\shell", "oldicon")
		If Not @error Then
			RegWrite("HKCR\" & $loc & "\DefaultIcon", "", "REG_SZ", $oldicon)
		Else
			RegDelete("HKCR\" & $loc & "\DefaultIcon", "")
		EndIf
		$oldverb = RegRead("HKCR\" & $loc & "\shell", "oldverb")
		If Not @error Then
			RegWrite("HKCR\" & $loc & "\shell", "", "REG_SZ", $oldverb)
		Else
			RegDelete("HKCR\" & $loc & "\shell", "")
		EndIf
		$olddesc = RegRead("HKCR\" & $loc, "olddesc")
		If Not @error Then
			RegWrite("HKCR\" & $loc, "", "REG_SZ", $olddesc)
		Else
			RegDelete("HKCR\" & $loc, "")
		EndIf
		$oldcmd = RegRead("HKCR\" & $loc & "\shell\" & $verb & "\command", "oldcmd")
		If Not @error Then
			RegWrite("HKCR\" & $loc & "\shell\" & $verb & "\command", "", "REG_SZ", $oldcmd)
			RegDelete("HKCR\" & $loc & "\shell\" & $verb & "\command", "oldcmd")
		Else
			RegDelete("HKCR\" & $loc & "\shell\" & $verb)
		EndIf
	EndIf
EndFunc
;===============================================================================
Func _GET_BROADCAST($IP)
    $objWMIService = ObjGet("winmgmts:{impersonationLevel=Impersonate}!\\" & @ComputerName & "\root\cimv2")
    If Not IsObj($objWMIService) Then Exit
    $colAdapters = $objWMIService.ExecQuery ("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")
    For $objAdapter in $colAdapters
        If Not ($objAdapter.IPAddress) = " " Then
            For $i = 0 To UBound($objAdapter.IPAddress)-1
                If $objAdapter.IPAddress($i)=$IP Then Return _BC_ADDR($objAdapter.IPAddress($i),$objAdapter.IPSubnet($i))
            Next
        EndIf
    Next
    Return 0
EndFunc
Func _BC_ADDR($IP, $MASK)
    Local $BC=""
    $IP=StringSplit($IP , ".")
    $MASK=StringSplit($MASK , ".")
    If $IP[0]<>4 Then Return SetError(1,0,0)
    If $MASK[0]<>4 Then Return SetError(2,0,0)
    For $i=1 To 4
        $BC&=BitXOR(BitXOR($MASK[$i],255),BitAND($IP[$i],$MASK[$i]))&"."
    Next
    Return StringTrimRight($BC,1)
EndFunc
;===============================================================================
; Function Name:    _ProcessListProperties()
; Description:   Get various properties of a process, or all processes
; Call With:       _ProcessListProperties( [$Process [, $sComputer]] )
; Parameter(s):  (optional) $Process - PID or name of a process, default is "" (all)
;          (optional) $sComputer - remote computer to get list from, default is local
; Requirement(s):   AutoIt v3.2.4.9+
; Return Value(s):  On Success - Returns a 2D array of processes, as in ProcessList()
;            with additional columns added:
;            [0][0] - Number of processes listed (can be 0 if no matches found)
;            [1][0] - 1st process name
;            [1][1] - 1st process PID
;            [1][2] - 1st process Parent PID
;            [1][3] - 1st process owner
;            [1][4] - 1st process priority (0 = low, 31 = high)
;            [1][5] - 1st process executable path
;            [1][6] - 1st process CPU usage
;            [1][7] - 1st process memory usage
;            [1][8] - 1st process creation date/time = "MM/DD/YYY hh:mm:ss" (hh = 00 to 23)
;            [1][9] - 1st process command line string
;            ...
;            [n][0] thru [n][9] - last process properties
; On Failure:      Returns array with [0][0] = 0 and sets @Error to non-zero (see code below)
; Author(s):        PsaltyDS at http://www.autoitscript.com/forum
; Date/Version:   12/01/2009  --  v2.0.4
; Notes:            If an integer PID or string process name is provided and no match is found,
;            then [0][0] = 0 and @error = 0 (not treated as an error, same as ProcessList)
;          This function requires admin permissions to the target computer.
;          All properties come from the Win32_Process class in WMI.
;            To get time-base properties (CPU and Memory usage), a 100ms SWbemRefresher is used.
;===============================================================================
Func _ProcessListProperties($Process = "", $sComputer = ".")
    Local $sUserName, $sMsg, $sUserDomain, $avProcs, $dtmDate
    Local $avProcs[1][2] = [[0, ""]], $n = 1

    ; Convert PID if passed as string
    If StringIsInt($Process) Then $Process = Int($Process)

    ; Connect to WMI and get process objects
    $oWMI = ObjGet("winmgmts:{impersonationLevel=impersonate,authenticationLevel=pktPrivacy, (Debug)}!\\" & $sComputer & "\root\cimv2")
    If IsObj($oWMI) Then
        ; Get collection processes from Win32_Process
        If $Process == "" Then
            ; Get all
            $colProcs = $oWMI.ExecQuery("select * from win32_process")
        ElseIf IsInt($Process) Then
            ; Get by PID
            $colProcs = $oWMI.ExecQuery("select * from win32_process where ProcessId = " & $Process)
        Else
            ; Get by Name
            $colProcs = $oWMI.ExecQuery("select * from win32_process where Name = '" & $Process & "'")
        EndIf

        If IsObj($colProcs) Then
            ; Return for no matches
            If $colProcs.count = 0 Then Return $avProcs

            ; Size the array
            ReDim $avProcs[$colProcs.count + 1][10]
            $avProcs[0][0] = UBound($avProcs) - 1

            ; For each process...
            For $oProc In $colProcs
                ; [n][0] = Process name
                $avProcs[$n][0] = $oProc.name
                ; [n][1] = Process PID
                $avProcs[$n][1] = $oProc.ProcessId
                ; [n][2] = Parent PID
                $avProcs[$n][2] = $oProc.ParentProcessId
                ; [n][3] = Owner
                If $oProc.GetOwner($sUserName, $sUserDomain) = 0 Then $avProcs[$n][3] = $sUserDomain & "\" & $sUserName
                ; [n][4] = Priority
                $avProcs[$n][4] = $oProc.Priority
                ; [n][5] = Executable path
                $avProcs[$n][5] = $oProc.ExecutablePath
                ; [n][8] = Creation date/time
                $dtmDate = $oProc.CreationDate
                If $dtmDate <> "" Then
                    ; Back referencing RegExp pattern from weaponx
                    Local $sRegExpPatt = "\A(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})(?:.*)"
                    $dtmDate = StringRegExpReplace($dtmDate, $sRegExpPatt, "$2/$3/$1 $4:$5:$6")
                EndIf
                $avProcs[$n][8] = $dtmDate
                ; [n][9] = Command line string
                $avProcs[$n][9] = $oProc.CommandLine

                ; increment index
                $n += 1
            Next
        Else
            SetError(2); Error getting process collection from WMI
        EndIf
        ; release the collection object
        $colProcs = 0

        ; Get collection of all processes from Win32_PerfFormattedData_PerfProc_Process
        ; Have to use an SWbemRefresher to pull the collection, or all Perf data will be zeros
        Local $oRefresher = ObjCreate("WbemScripting.SWbemRefresher")
        $colProcs = $oRefresher.AddEnum($oWMI, "Win32_PerfFormattedData_PerfProc_Process" ).objectSet
        $oRefresher.Refresh

        ; Time delay before calling refresher
        Local $iTime = TimerInit()
        Do
            Sleep(20)
        Until TimerDiff($iTime) >= 100
        $oRefresher.Refresh

        ; Get PerfProc data
        For $oProc In $colProcs
            ; Find it in the array
            For $n = 1 To $avProcs[0][0]
                If $avProcs[$n][1] = $oProc.IDProcess Then
                    ; [n][6] = CPU usage
                    $avProcs[$n][6] = $oProc.PercentProcessorTime
                    ; [n][7] = memory usage
                    $avProcs[$n][7] = $oProc.WorkingSet
                    ExitLoop
                EndIf
            Next
        Next
    Else
        SetError(1); Error connecting to WMI
    EndIf

    ; Return array
    Return $avProcs
EndFunc  ;==>_ProcessListProperties
;===============================================================================
Func _SocketToIP($SHOCKET)
    Local $sockaddr, $aRet

    $sockaddr = DllStructCreate("short;ushort;uint;char[8]")

    $aRet = DllCall("Ws2_32.dll", "int", "getpeername", "int", $SHOCKET, _
            "ptr", DllStructGetPtr($sockaddr), "int*", DllStructGetSize($sockaddr))
    If Not @error And $aRet[0] = 0 Then
        $aRet = DllCall("Ws2_32.dll", "str", "inet_ntoa", "int", DllStructGetData($sockaddr, 3))
        If Not @error Then $aRet = $aRet[0]
    Else
        $aRet = 0
    EndIf

    $sockaddr = 0

    Return $aRet
EndFunc   ;==>SocketToIP
