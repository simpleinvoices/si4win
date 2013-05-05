;This function is used to take the template config file replace pre set strings with values from global variables
func ParseConfig($FILE)
	_cfl("ParseConfig: "&$FILE)

	$ConfigTemplate=FileRead ($FILE&".template")
	$ConfigHand=FileOpen ($FILE,2)
	$ConfigTemplate=StringReplace ($ConfigTemplate, "!TEAMMCPATH!", @ScriptDir)
	$ConfigTemplate=StringReplace ($ConfigTemplate, "!TEAMMCWEBADDRESS_HTTPD!", $WEBADDRESS_HTTPD)
	$ConfigTemplate=StringReplace ($ConfigTemplate, "!TEAMMCWEBADDRESS!", $WEBADDRESS)
	$ConfigTemplate=StringReplace ($ConfigTemplate, "!TEAMMCWEBPORT!", $WEBPORT)
	$ConfigTemplate=StringReplace ($ConfigTemplate, "!TEAMMCSQLADDRESS!", $SQLADDRESS)
	$ConfigTemplate=StringReplace ($ConfigTemplate, "!TEAMMCSQLPORT!", $SQLPORT)
	FileWrite($ConfigHand,$ConfigTemplate)
	FileClose($ConfigHand)
endfunc