func TrayExitEvent()
	exit
endfunc
func About()
	_cfl("About")
	_msgbox(64+262144,$TITLE,$TeamMC_Title&@CRLF&"Version: "&$VERSION&@CRLF&$URL&@CRLF&@CRLF&$TITLE_SHORT&@CRLF&"Version: "&$VERSION_WWW&@CRLF&$URL_WWW)
endfunc
func OpenBrowser()
	_cfl("OpenBrowser")
	Run(@ComSpec & " /c start " & $URL_BASE & '/', "", @SW_HIDE)
EndFunc
func phpmyadmin()
	_cfl("phpmyadmin")
	Run(@ComSpec & " /c start " & $URL_BASE & '/phpmyadmin', "", @SW_HIDE)
endfunc