#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=_icon.ico
#AutoIt3Wrapper_Outfile=..\SimpleInvoices.exe
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Fileversion=1.7.0.116
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#Obfuscator_Parameters=/striponly
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;=====================================================================================
#include "_CommonFunctions.au3"
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>

#Include <File.au3>
#include <IE.au3>
#include <Array.au3>
#Include <String.au3>

;=====================================================================================
if @compiled=0 then;Change only for testing purposes when script is executed as uncompiled
	msgbox(0,"Error...","This script contains features that require it to be compiled")
	Exit
EndIf

Global $INI_SETTINGS_FILE="Settings.ini"
Global $INI_SETTINGS=@ScriptDir&"\"&$INI_SETTINGS_FILE
Global $WEBPORT=iniread($INI_SETTINGS,"SETTINGS","WebPort","8877")
Global $SQLPORT=iniread($INI_SETTINGS,"SETTINGS","SQLPort","3304")
Global $WEBADDRESS=iniread($INI_SETTINGS,"SETTINGS","WebAddress","localhost")
Global $SQLADDRESS=iniread($INI_SETTINGS,"SETTINGS","SQLAddress","localhost")
Global $WEBADDRESS_HTTPD=$WEBADDRESS&":"

if $WEBADDRESS="localhost" then
	$WEBADDRESS="127.0.0.1"
	$WEBADDRESS_HTTPD=$WEBADDRESS&":"
elseif $WEBADDRESS="" then
	$WEBADDRESS="127.0.0.1"
	$WEBADDRESS_HTTPD=""
endif

if $SQLADDRESS="localhost" OR $SQLADDRESS="" then $SQLADDRESS="127.0.0.1"

Global $HIGHT=iniread($INI_SETTINGS,"SETTINGS","WinHeight",680)
Global $WIDTH=iniread($INI_SETTINGS,"SETTINGS","WinWidth",1020)
Global $DEBUGLOG=iniread($INI_SETTINGS,"SETTINGS","Log",0)

Global $DIR_ROOT=@ScriptDir
Global $DIR_WWW=$DIR_ROOT&"\www"

Global $URL_BASE="http://"&$WEBADDRESS&":"&$WEBPORT
;Global $URL_SCRIPTS=$URL_BASE&"/scripts/"
Global $URL_SI=$URL_BASE&"/"
Global $URL_SI_START=$URL_SI&"#START"
Global $TeamMC_Title="TeamMC Portable Web Server"
Global $TITLE=iniread($INI_SETTINGS,"SETTINGS","Title","Portable Web Server")
Global $TITLE_SHORT=iniread($INI_SETTINGS,"SETTINGS","Title_Short","Portable Web Server")
Global $Proccess_Apache="simpleinvoices_httpd.exe"
Global $Proccess_MySQL="simpleinvoices_mysqld.exe"

Global $VERSION_WWW=iniread($INI_SETTINGS,"SETTINGS","Version","Unknown")
Global $VERSION=FileGetVersion(@AutoItExe)
Global $URL_WWW=iniread($INI_SETTINGS,"SETTINGS","URL","Unknown")
Global $URL="www.TeamMC.cc/simpleinvoices"

Global $STATE_SERVER=0

_cfl("====================================================")
_cfl($TITLE&" "&$VERSION)

;=====================================================================================
_cfl("_only_instance")
If _only_instance(0)=1 then
	if WinActivate($TITLE) then
	elseif WinActivate("",$URL_BASE) then
	elseif WinActivate("",StringReplace($URL_BASE,"http://","")) then

	;find a way to deal with firefox

	else
		OpenBrowser()
	EndIf

	Exit
endif

;=====================================================================================
_cfl("Tray Build")
if iniread($INI_SETTINGS,"SETTINGS","TrayIcon",0)=1 then Opt("TrayIconHide", 0)

Opt("TrayMenuMode", 1+2)
Opt("TrayOnEventMode", 1)
TraySetToolTip ($TITLE)

if iniread($INI_SETTINGS,"SETTINGS","Browser",1)=1 then
	TrayCreateItem("Open In Browser")
	TrayItemSetOnEvent(-1,"OpenBrowser")
	TrayCreateItem("")
endif

if iniread($INI_SETTINGS,"SETTINGS","Settings",1)=1 then
	TrayCreateItem("Settings")
	TrayItemSetOnEvent(-1,"settings")
endif
if iniread($INI_SETTINGS,"SETTINGS","PHPMyAdmin",1)=1 then
	TrayCreateItem("PHPMyAdmin")
	TrayItemSetOnEvent(-1,"phpmyadmin")
endif
if iniread($INI_SETTINGS,"SETTINGS","ToggleServer",1)=1 then
	$Tray_ToggleServer=TrayCreateItem("Toggle Server")
	TrayItemSetOnEvent(-1,"toggleserver")
endif

TrayCreateItem("")

TrayCreateItem("About")
TrayItemSetOnEvent(-1,"About")

TrayCreateItem("Exit")
TrayItemSetOnEvent(-1,"TrayExitEvent")

;=====================================================================================
_cfl("GUI-1 Build")
$GUI_Prompt = GUICreate($TITLE, 447, 147, -1, -1, BitOR($WS_MINIMIZEBOX,$WS_SYSMENU,$WS_DLGFRAME,$WS_POPUP,$WS_GROUP,$WS_CLIPSIBLINGS), BitOR($WS_EX_TOPMOST,$WS_EX_WINDOWEDGE))
GUISetBkColor(0xFFFFFF)
$Group1 = GUICtrlCreateGroup("", 4, 0, 437, 141, $BS_CENTER)
$Button1 = GUICtrlCreateButton("GUI (typical)", 20, 63, 127, 33, BitOR($BS_DEFPUSHBUTTON,$WS_GROUP))
GUICtrlSetFont(-1, 10, 400, 0, "Verdana")
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0xD54E21)
GUICtrlSetTip(-1, "Starts In Its Own Window")
$Button2 = GUICtrlCreateButton("Browser", 158, 63, 127, 33, $WS_GROUP)
GUICtrlSetFont(-1, 10, 400, 0, "Verdana")
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0xD54E21)
GUICtrlSetTip(-1, "Starts In A New Browser Window (You can exit using the tray icon)")
$Button3 = GUICtrlCreateButton("Exit", 296, 63, 127, 33, $WS_GROUP)
GUICtrlSetFont(-1, 10, 400, 0, "Verdana")
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0xD54E21)
$Label1 = GUICtrlCreateLabel($VERSION_WWW&"/"&$VERSION, 176, 118, 252, 17, $SS_RIGHT)
GUICtrlSetFont(-1, 8, 400, 0, "Verdana")
GUICtrlSetColor(-1, 0x808080)
$Label2 = GUICtrlCreateLabel("How would you like to open "&$TITLE_SHORT&"?", 104, 26, 300, 20)
GUICtrlSetFont(-1, 10, 400, 0, "Verdana")
$Checkbox1 = GUICtrlCreateCheckbox("Set As Default", 48, 116, 97, 17)
GUICtrlSetFont(-1, 8, 400, 2, "Verdana")
GUICtrlSetColor(-1, 0x808080)
$Icon1 = GUICtrlCreateIcon("src\_icon.ico", -1, 32, 12, 48, 48, BitOR($SS_NOTIFY,$WS_GROUP))
$Icon2 = GUICtrlCreateIcon("src\_gear.ico", -1, 20, 116, 16, 16, BitOR($SS_NOTIFY,$WS_GROUP))

GUICtrlCreateGroup("", -99, -99, 1, 1)

if iniread($INI_SETTINGS,"SETTINGS","GUI",1)=0 then GUICtrlSetState ($Button1,$GUI_DISABLE)
if iniread($INI_SETTINGS,"SETTINGS","Browser",1)=0 then GUICtrlSetState ($Button3,$GUI_DISABLE)
if iniread($INI_SETTINGS,"SETTINGS","Settings",1)=0 then GUICtrlSetState($Icon2, $GUI_HIDE)
if iniread($INI_SETTINGS,"SETTINGS","SetAsDefaultCheckBox",1)=0 then GUICtrlSetState($Checkbox1, $GUI_HIDE)

$Dummy1=GUICtrlCreateDummy ( )
$Dummy2=GUICtrlCreateDummy ( )

GUISetState(@SW_SHOW,$GUI_Prompt)

if iniread($INI_SETTINGS,"SETTINGS","PromptGUIBrowser",1)=0 then
	if iniread($INI_SETTINGS,"SETTINGS","GUI",1)=1 Then
		GUICtrlSendToDummy ($Dummy1)
	elseif iniread($INI_SETTINGS,"SETTINGS","Browser",1)=1 Then
		GUICtrlSendToDummy ($Dummy2)
	Else
		GUICtrlSendToDummy ($Dummy1)
	endif
endif

_cfl("GUI-1 Loop")

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE, $Button3
			exit

		Case $Button1, $Dummy1
			If GUICtrlRead ($Checkbox1)=$GUI_CHECKED Then IniWrite ($INI_SETTINGS,"SETTINGS", "PromptGUIBrowser","0")
			GUIDelete($GUI_Prompt)
			StartServer()
			exitloop

		Case $Button2, $Dummy2
			If GUICtrlRead ($Checkbox1)=$GUI_CHECKED Then
				IniWrite ($INI_SETTINGS,"SETTINGS", "PromptGUIBrowser","0")
				IniWrite ($INI_SETTINGS,"SETTINGS", "GUI","0")
			EndIf

			GUIDelete($GUI_Prompt)

			Opt("TrayIconHide", 0)
			TrayTip ($TITLE_SHORT,"Use this tray icon to close the program when your done",6,1)
			StartServer()
			OpenBrowser()
		Case $Icon2
			Settings()

	EndSwitch

	sleep(10)
WEnd
;=====================================================================================
_cfl("GUI-2 Build")

local $MenuItem14=1, $MenuItem4=1, $MenuItem9=1, $MenuItem12=1
$oIE = ObjCreate("Shell.Explorer.2")

$GUI_Browser = GUICreate($TITLE,$WIDTH,$HIGHT,-1,-1,BitOr($GUI_SS_DEFAULT_GUI,$WS_SIZEBOX,$WS_MAXIMIZEBOX))
$GUIActiveX = GUICtrlCreateObj ($oIE, 1, 1,$WIDTH-2,$HIGHT-4-20)
GUICtrlSetResizing ($GUIActiveX,2+4+32+64)
$MenuItem1 = GUICtrlCreateMenu("&File")
	$MenuItem6 = GUICtrlCreateMenuItem("Refresh", $MenuItem1)
	$MenuItem11 = GUICtrlCreateMenuItem("Home", $MenuItem1)
	$MenuItem5 = GUICtrlCreateMenuItem("Forward >>", $MenuItem1)

	$MenuItem8 = GUICtrlCreateMenuItem("",$MenuItem1)

	if iniread($INI_SETTINGS,"SETTINGS","Settings",1)=1 then $MenuItem14 = GUICtrlCreateMenuItem("Settings", $MenuItem1)
	if iniread($INI_SETTINGS,"SETTINGS","PHPMyAdmin",1)=1 then $MenuItem4 = GUICtrlCreateMenuItem("PHPMyAdmin", $MenuItem1)
	if iniread($INI_SETTINGS,"SETTINGS","Browser",1)=1 then $MenuItem9 = GUICtrlCreateMenuItem("Open In Browser", $MenuItem1)
	if iniread($INI_SETTINGS,"SETTINGS","ToggleServer",1)=1 then $MenuItem12 = GUICtrlCreateMenuItem("Toggle Server", $MenuItem1)

	$MenuItem13 = GUICtrlCreateMenuItem("",$MenuItem1)

	$MenuItem3 = GUICtrlCreateMenuItem("About", $MenuItem1)
	$MenuItem7 = GUICtrlCreateMenuItem("Exit", $MenuItem1)

$MenuItem2 = GUICtrlCreateMenuItem("<< &Back",-1)
$MenuItem10 = GUICtrlCreateMenuItem("&Print",-1)

GUISetState(@SW_SHOW,$GUI_Browser)

Dim $Form1_AccelTable[1][2] = [["^f", $MenuItem1]]
GUISetAccelerators($Form1_AccelTable)

_cfl("Registering Error Handler")
$objError = ObjEvent("AutoIt.Error", "_ErrorHandlerFunction")

$oIE.navigate($URL_SI_START)

_cfl("GUI-2 Loop")
While 1
	$msg = GUIGetMsg()
	switch $msg
		Case $GUI_EVENT_CLOSE, $MenuItem7
			if Msgbox(1,$TITLE,"Are you sure you want to exit? (Unsaved data will be lost)") = 1 then Exit
		Case $MenuItem2
			_cfl($oIE.LocationURL&" - "&$oIE.Busy)
			If $oIE.LocationURL<>$URL_SI_START AND NOT $oIE.Busy Then $oIE.GoBack
		Case $MenuItem5
			$oIE.GoForward
		Case $MenuItem11
			$oIE.navigate($URL_SI)
		Case $MenuItem6
			$oIE.ReFresh
		Case $MenuItem10
			$oIE.document.parentwindow.Print()
		Case $MenuItem3
			About()
		Case $MenuItem4
			phpmyadmin()
		Case $MenuItem9
			OpenBrowser()
		Case $MenuItem12
			toggleserver()
		Case $MenuItem14
			settings()
	Endswitch

	sleep(10)
WEnd

;=====================================================================================
func _ErrorHandlerFunction()
	;Nothing to do
	_cfl("_ErrorHandlerFunction Called - Nothing To Do")
endfunc
#include <func_settings.au3>
#include <func_misc.au3>
#include <func_stopserver.au3>
#include <func_startserver.au3>
#include <func_toggleserver.au3>
#Include <func_parseconfig.au3>