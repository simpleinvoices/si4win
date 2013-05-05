#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=_icon.ico
#AutoIt3Wrapper_outfile=..\SimpleInvoices.exe
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Change2CUI=n
#AutoIt3Wrapper_Res_Fileversion=1.6.0.1
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;=====================================================================================
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "_MyFuncs.au3"
#Include <File.au3>
#include <IE.au3>
#include <Array.au3>
#Include <String.au3>

;=====================================================================================
Global $INI_SETTINGS="Settings.ini"
Global $WEBPORT=iniread($INI_SETTINGS,"SETTINGS","WebPort","8877")
Global $SQLPORT=iniread($INI_SETTINGS,"SETTINGS","SQLPort","3304")
Global $ADDRESS=iniread($INI_SETTINGS,"SETTINGS","Address","127.0.0.1")

if $ADDRESS="localhost" then $ADDRESS="127.0.0.1"

if $ADDRESS="" Then
	$ADDRESS="127.0.0.1"
	$APACHELISTEN=""
Else
	$APACHELISTEN=$ADDRESS&":"
endif

Global $URL_BASE="http://"&$ADDRESS&":"&$WEBPORT
Global $URL_SCRIPTS=$URL_BASE&"/scripts/"
Global $URL_SI=$URL_BASE&"/"
Global $HIGHT=iniread($INI_SETTINGS,"SETTINGS","WinHeight",680)
Global $WIDTH=iniread($INI_SETTINGS,"SETTINGS","WinWidth",1020)
Global $SIVERSION=_StringProper(iniread("www\config\config.ini","production","version.name","ERROR"));"2010.2 Update 1"
Global $VERSION=FileGetVersion(@AutoItExe)
Global $TITLE="Simple Invoices For Windows"
Global $Proccess_Apache="simpleinvoices_httpd.exe"
Global $Proccess_MySQL="simpleinvoices_mysqld.exe"
Global $STATE_SERVER=0
Global $DEBUGLOG=iniread($INI_SETTINGS,"SETTINGS","Log",0)

_cfl($TITLE&" "&$VERSION)

;=====================================================================================
_cfl("_only_instance")
If _only_instance(0)=1 then
	if WinActivate("Simple Invoices",$URL_BASE) then
	elseif WinActivate("Simple Invoices - Mozilla Firefox") then
	elseif WinActivate($TITLE) then
	else
		OpenBrowser()
	EndIf

	Exit
endif

;=====================================================================================
_cfl("Tray Build")
if iniread($INI_SETTINGS,"SETTINGS","EnableTrayIcon",0)=1 then Opt("TrayIconHide", 0)

Opt("TrayMenuMode", 1+2)
Opt("TrayOnEventMode", 1)
TraySetToolTip ($TITLE)

if iniread($INI_SETTINGS,"SETTINGS","EnableDefaultBrowser",1)=1 then
	TrayCreateItem("Open In Browser")
	TrayItemSetOnEvent(-1,"OpenBrowser")
endif
if iniread($INI_SETTINGS,"SETTINGS","ShowPHPMyAdminOption",1)=1 then
	TrayCreateItem("PHPMyAdmin")
	TrayItemSetOnEvent(-1,"phpmyadmin")
endif
if iniread($INI_SETTINGS,"SETTINGS","ShowStartStopServerOption",1)=1 then
	$Tray_ToggleServer=TrayCreateItem("Toggle Server")
	TrayItemSetOnEvent(-1,"toggleserver")
endif

if iniread($INI_SETTINGS,"SETTINGS","RemoteFunctionsEnable",0)=1 then
	TrayCreateItem("Download Database")
	TrayItemSetOnEvent(-1,"RemoteDBToLocalDB")

	TrayCreateItem("Upload DB Changes")
	TrayItemSetOnEvent(-1,"LocalChangesToRemoteDB")
endif

TrayCreateItem("")

TrayCreateItem("About")
TrayItemSetOnEvent(-1,"About")

TrayCreateItem("Exit")
TrayItemSetOnEvent(-1,"TrayExitEvent")

;=====================================================================================
_cfl("GUI-1 Build")
$Form1 = GUICreate($TITLE, 277, 87)
$Group1 = GUICtrlCreateGroup("", 4, 0, 269, 81)
$Button1 = GUICtrlCreateButton("Start Simple Invoices (GUI)", 12, 10, 251, 19)
if iniread($INI_SETTINGS,"SETTINGS","EnableGUI",1)=0 then GUICtrlSetState ($Button1,$GUI_DISABLE)
$Button3 = GUICtrlCreateButton("Start Simple Invoices (Default Browser)", 12, 30, 251, 19)
if iniread($INI_SETTINGS,"SETTINGS","EnableDefaultBrowser",1)=0 then GUICtrlSetState ($Button3,$GUI_DISABLE)

$Button2 = GUICtrlCreateButton("Exit", 12, 50, 251, 19)

$Dummy1=GUICtrlCreateDummy ( )
$Dummy2=GUICtrlCreateDummy ( )
GUISetState(@SW_SHOW,$Form1)

if iniread($INI_SETTINGS,"SETTINGS","PromptBeforeLaunch",1)=0 then
	if iniread($INI_SETTINGS,"SETTINGS","EnableGUI",1)=1 Then
		GUICtrlSendToDummy ($Dummy1)
	elseif iniread($INI_SETTINGS,"SETTINGS","EnableDefaultBrowser",1)=1 Then
		GUICtrlSendToDummy ($Dummy2)
	endif
endif

_cfl("GUI-1 Loop")

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE, $Button2
			exit

		Case $Button1, $Dummy1
			GUIDelete($Form1)

			StartServer()

			$oIE = ObjCreate("Shell.Explorer.2")

			_cfl("GUI-2 Build")
			$GUI_Main = GUICreate($TITLE,$WIDTH,$HIGHT, (@DesktopWidth - $WIDTH) / 2, round((@DesktopHeight - $HIGHT) / 3),BitOr($GUI_SS_DEFAULT_GUI,$WS_SIZEBOX,$WS_MAXIMIZEBOX))
			$GUIActiveX = GUICtrlCreateObj ($oIE, 1, 1,$WIDTH-2,$HIGHT-4-20)
			GUICtrlSetResizing ($GUIActiveX,2+4+32+64)
			$MenuItem1 = GUICtrlCreateMenu("&File")
			$MenuItem7 = GUICtrlCreateMenuItem("Exit", $MenuItem1)
			$MenuItem10 = GUICtrlCreateMenu("Controls")
			$MenuItem2 = GUICtrlCreateMenuItem("Back <<", $MenuItem10)
			$MenuItem5 = GUICtrlCreateMenuItem("Forward >>", $MenuItem10)
			$MenuItem6 = GUICtrlCreateMenuItem("Refresh ", $MenuItem10)
			$MenuItem11 = GUICtrlCreateMenuItem("Home", $MenuItem10)
			$MenuItem8 = GUICtrlCreateMenu("Help")
			if iniread($INI_SETTINGS,"SETTINGS","ShowPHPMyAdminOption",1)=1 then $MenuItem4 = GUICtrlCreateMenuItem("PHPMyAdmin", $MenuItem8)
			if iniread($INI_SETTINGS,"SETTINGS","EnableDefaultBrowser",1)=1 then $MenuItem9 = GUICtrlCreateMenuItem("Open In Browser", $MenuItem8)
			if iniread($INI_SETTINGS,"SETTINGS","ShowToggleServerOption",1)=1 then $MenuItem12 = GUICtrlCreateMenuItem("Toggle Server", $MenuItem8)
			GUICtrlCreateMenuItem("", $MenuItem8)
			$MenuItem3 = GUICtrlCreateMenuItem("About", $MenuItem8)
			;$StatusBar1 = _GUICtrlStatusBar_Create($Form1)
			GUISetState()

			Dim $Form1_AccelTable[1][2] = [["^f", $MenuItem1]]
			GUISetAccelerators($Form1_AccelTable)

			$oIE.navigate($URL_SI)

			_cfl("GUI-2 Loop")
			While 1
				$msg = GUIGetMsg()
				switch $msg
					Case $GUI_EVENT_CLOSE, $MenuItem7
						if Msgbox(1,$TITLE,"Exit Simple Invoices? (Unsaved data will be lost)") = 1 then Exit
					Case $MenuItem2
						$oIE.GoBack
					Case $MenuItem5
						$oIE.GoForward
					Case $MenuItem11
						$oIE.navigate($URL_SI)
					Case $MenuItem6
						$oIE.ReFresh
					Case $MenuItem3
						About()
					Case $MenuItem4
						phpmyadmin()
					Case $MenuItem9
						OpenBrowser()
					Case $MenuItem12
						toggleserver()
				Endswitch

				sleep(10)
			WEnd

		Case $Button3, $Dummy2
			GUIDelete($Form1)
			Opt("TrayIconHide", 0)
			StartServer()
			OpenBrowser()

	EndSwitch

	sleep(10)
WEnd

;=====================================================================================
func TrayExitEvent()
	exit
endfunc
func About()
	_cfl("About")
	_msgbox(64+262144,$TITLE,$TITLE&@CRLF&"Version: "&$VERSION&@CRLF&"www.TeamMC.cc/simpleinvoices"&@CRLF&@CRLF&"Simple Invoices"&@CRLF&"Version: "&$SIVERSION&@CRLF&"www.SimpleInvoices.org")
endfunc
func OpenBrowser()
	_cfl("OpenBrowser")
	Run(@ComSpec & " /c start " & $URL_BASE & '/', "", @SW_HIDE)
EndFunc
func phpmyadmin()
	_cfl("phpmyadmin")
	Run(@ComSpec & " /c start " & $URL_BASE & '/phpmyadmin', "", @SW_HIDE)
endfunc
func StopServer()
	_cfl("StopServer")

	ProgressOff()
	ProgressOn($TITLE,$TITLE,"Simple Invoices Closing",Default,@DesktopHeight/2-200,16)

	ProgressSet(10,"Attempting Safe MySQL Shutdown")
	$PID=Run(@ComSpec & " /c " & 'mysql\bin\mysqladmin.exe --port='&$SQLPORT&' --user=root shutdown',@ScriptDir, @SW_HIDE)


	ProgressSet(30,"Waiting For MySQL Shutdown")
	ProcessWaitClose($PID,3)
	ProcessClose ($PID)
	sleep(1000)

	ProgressSet(50,"Closing Remaining MySQL Proccesses")
	_ProcessCloseOthers($Proccess_MySQL)

	ProgressSet(70,"Closing Apache Proccesses")
	_ProcessCloseOthers($Proccess_Apache)

	ProgressSet(90,"Updating Menu Options")

	OnAutoItExitUnregister("StopServer")
	$STATE_SERVER=0

	ProgressOff()

endfunc
func StartServer()
	_cfl("StartServer")

	ProgressOff()
	ProgressOn($TITLE,$TITLE,"Starting Server",Default,@DesktopHeight/2-200,16)

	OnAutoItExitRegister( "StopServer" )
	$STATE_SERVER=1

	ProgressSet(20,"Reading/Updating Configuration 1")
	ParseConfig("apache\conf\httpd.conf")

	ProgressSet(30,"Reading/Updating Configuration 2")
	ParseConfig("mysql\my.ini")

	ProgressSet(40,"Reading/Updating Configuration 3")
	ParseConfig("php\php.ini")

	Sleep(100)

	ProgressSet(50,"Starting Apache")
	;$PID_Apache=Run(@ComSpec & " /k " & 'Apache\bin\'&$Proccess_Apache, "", @SW_HIDE)
	$PID_Apache=Run('Apache\bin\'&$Proccess_Apache,@ScriptDir,@SW_HIDE)
	Sleep(100)

	ProgressSet(60,"Starting MySQL")
	;$PID_MySQL=Run(@ComSpec & " /k " & 'Mysql\bin\'&$Proccess_MySQL, "", @SW_HIDE)
	$PID_MySQL=Run('Mysql\bin\'&$Proccess_MySQL,@ScriptDir,@SW_HIDE)
	Sleep(100)

	ProgressSet(70,"Waitng For Connections")

	TCPStartUp()
	for $i=1 to 40
		$SQLSocket = TCPListen($ADDRESS, $SQLPORT)
		$SQLERROR=@error
		TCPCloseSocket ($SQLSocket)
		$WebSocket = TCPListen($ADDRESS, $WEBPORT)
		$WEBERROR=@error
		TCPCloseSocket ($WebSocket)

		if $SQLERROR=10048 AND ($WEBERROR=10048 OR $APACHELISTEN="") then exitloop

		sleep(100)
	next
	if $i=41 then msgbox(0,$TITLE,"Connections failed or could not be detected"&@CRLF&"Error: "&$SQLERROR&"/"&$WEBERROR)
	TCPShutdown()

	Sleep(1000)

	ProgressSet(80,"Checking Proccesses")

	if ProcessExists($PID_Apache)=0 Then
		msgbox(0,$TITLE,"Apache failed to start")
		Exit

	elseif ProcessExists($PID_MySQL)=0 then
		msgbox(0,$TITLE,"MySQL failed to start")
		Exit

	endif

	ProgressOff()

endfunc
func ParseConfig($FILE)
	_cfl("ParseConfig: "&$FILE)

	$ConfigTemplate=FileRead ($FILE&".template")
	$ConfigHand=FileOpen ($FILE,2)
	$ConfigTemplate=StringReplace ($ConfigTemplate, "!TEAMMCPATH!", @ScriptDir)
	$ConfigTemplate=StringReplace ($ConfigTemplate, "!TEAMMCADDRESSAPACHELISTEN!", $APACHELISTEN)
	$ConfigTemplate=StringReplace ($ConfigTemplate, "!TEAMMCADDRESS!", $ADDRESS)
	$ConfigTemplate=StringReplace ($ConfigTemplate, "!TEAMMCWEBPORT!", $WEBPORT)
	$ConfigTemplate=StringReplace ($ConfigTemplate, "!TEAMMCSQLPORT!", $SQLPORT)
	FileWrite($ConfigHand,$ConfigTemplate)
	FileClose($ConfigHand)
endfunc
func ToggleServer()
	_cfl("ToggleServer")

	if $STATE_SERVER > 0 then
		if msgbox(1,$TITLE,"Are you sure you want to STOP the server?") <> 1 then return
		StopServer()
	Else
		if msgbox(1,$TITLE,"Are you sure you want to START the server?") <> 1 then return
		StartServer()
	EndIf
EndFunc










;=======================================================================
;=======================================================================
;DB Functions Section===================================================
;=======================================================================
;=======================================================================
func BinToSql()
	_cfl("BinToSql")

	FileDelete(@ScriptDir&'\mysql\data\binarylog.0?????_.sql')

	$FileList=_FileListToArray(@ScriptDir&'\mysql\data','binarylog.0?????',1)

	for $i=1 to $FileList[0]
		_cfl($FileList[$i])

		$File=$FileList[$i]
		$OutFile=StringTrimLeft($File&"_.sql",StringInStr($File,"\",1,-1))
		$OutFileRelative='mysql\data\'&$OutFile


		$XString=@ComSpec & ' /c ' & 'mysql\bin\mysqlbinlog.exe --user=root --short-form --database=simple_invoices --result-file='&$OutFileRelative&' mysql\data\'&$File
		$PID_Apache=Runwait($XString,@ScriptDir, @SW_SHOW)

		Local $BinHand=FileOpen($OutFileRelative,0)
		if @error then msgbox(0,$TITLE,"Couldnt open file")

		$SQLData=fileread($BinHand)
		if @error then
			msgbox(0,$TITLE,$File & 'could not be read ('&@error&')')
			Return
		EndIf

		FileClose($BinHand)
		$BinHand=FileOpen($OutFileRelative,2)

		while 1
			$Place1=StringInStr ($SQLData,"/*")
			$Place2=StringInStr ($SQLData,"*/")
			if $Place1=0 or $Place2=0 then ExitLoop

			$Place2=$Place2+2

			$SearchString=StringMid ($SQLData,$Place1,$Place2-$Place1)

			$SQLData=StringReplace($SQLData,$SearchString,"")
		WEnd

		FileWrite($BinHand,$SQLData)
		FileClose($BinHand)
	next

endfunc
func UploadSQL($URL,$DATA)
	_cfl("UploadSQL")

	$oIE=_IECreate ($URL,0,1,1,0)
	if @error then msgbox(0,$TITLE,"Error 1")

	_cfl("_IEFormGetObjByName")
	$oForm = _IEFormGetObjByName($oIE,"sqlform")
	if @error then msgbox(0,$TITLE,"Error 2")

	_cfl("_IEFormElementGetObjByName")
	$oText = _IEFormElementGetObjByName ($oForm,"data")
	if @error then msgbox(0,$TITLE,"Error 3")

	_cfl("_IEFormElementSetValue")
	_cfl($DATA)
	_IEFormElementSetValue ($oText,$DATA)
	if @error then msgbox(0,$TITLE,"Error 4")

	msgbox(0,$TITLE,"Pause")

	_cfl("_IEFormSubmit")
	_IEFormSubmit ($oForm,1)
	if @error then msgbox(0,$TITLE,"Error 5")

	msgbox(0,$TITLE,"Pause")
	_cfl("_IEFormSubmit - Returned Source Start")
	_cfl(_IEDocReadHTML ($oIE))
	_cfl("_IEFormSubmit - Returned Source End")

	Sleep(2000)
	_IEQuit($oIE)
endfunc
func LocalChangesToRemoteDB()
	_cfl("LocalChangesToRemoteDB")

	;FileWrite(@ScriptDir&'\mysql\data\RemoteUpdateBackup.SQL',DownloadRemoteDB())

	if $STATE_SERVER>=1 then
		StopServer()
		$STATE_SERVER=-1
	endif

	BinToSql()

	_cfl("FileList")
	$FileList=_FileListToArray(@ScriptDir&'\mysql\data','binarylog.0?????_.sql',1)
	_ArrayDisplay($FileList)

	for $i=1 to $FileList[0]
		_cfl($FileList[$i])
		$data=fileread(@ScriptDir&'\mysql\data\'&$FileList[$i])
		if @error then MsgBox(0,$TITLE,"File Read Error (370)")
		_cfl("Data: "&$data)
		$URL=iniread($INI_SETTINGS,"SETTINGS","RemoteSQLPHPURL","")&"?q=set&d1="&iniread($INI_SETTINGS,"SETTINGS","RemoteDBAddress","")&"&d2="&iniread($INI_SETTINGS,"SETTINGS","RemoteDBUsername","")&"&d3="&iniread($INI_SETTINGS,"SETTINGS","RemoteDBPassword","")&"&d4="&iniread($INI_SETTINGS,"SETTINGS","RemoteDBName","")
		UploadSQL($URL,$data)
	next

	if msgbox(4+32,$TITLE,"Process completed with unknown result. Delete binary log files?")=6 then
		FileDelete(@ScriptDir&'\mysql\data\binarylog.0?????')
		if @error then msgbox(0,$TITLE,"Couldn't delete old binarylog files.")
	EndIf

	if $STATE_SERVER=-1 then StartServer()

endfunc
func RemoteDBToLocalDB()
	_cfl("RemoteDBToLocalDB")

	$URL=iniread($INI_SETTINGS,"SETTINGS","RemoteSQLPHPURL","")&"?q=get&d1="&iniread($INI_SETTINGS,"SETTINGS","RemoteDBAddress","")&"&d2="&iniread($INI_SETTINGS,"SETTINGS","RemoteDBUsername","")&"&d3="&iniread($INI_SETTINGS,"SETTINGS","RemoteDBPassword","")&"&d4="&iniread($INI_SETTINGS,"SETTINGS","RemoteDBName","")
	_cfl($URL)

	$data=InetRead ($URL,1+2+16)
	$data=BinaryToString($data)
	if @error then
		msgbox(0,$TITLE,"Couldn't download database.")
		return 0
	endif

	if Not $STATE_SERVER then
		StartServer()
		$STATE_SERVER=2
	EndIf

	$URL=$URL_SCRIPTS&"sql.php?q=set&d1="&$ADDRESS&"&d2="&iniread($INI_SETTINGS,"SETTINGS","LocalDBUsername","")&"&d3="&iniread($INI_SETTINGS,"SETTINGS","LocalDBPassword","")&"&d4="&iniread($INI_SETTINGS,"SETTINGS","LocalDBName","")
	_cfl($URL)

	UploadSQL($URL,$data)

	if $STATE_SERVER=1 then
		StopServer()
		$STATE_SERVER=-2

	Elseif $STATE_SERVER then
		StopServer()

	EndIf

	_cfl("Deleting BinLogs")
	FileDelete(@ScriptDir&'\mysql\data\binarylog*')
	if @error then msgbox(0,$TITLE,"Couldn't delete old binarylog files.")

	if $STATE_SERVER=-2 then StartServer()

EndFunc