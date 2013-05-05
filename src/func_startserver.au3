func StartServer()
	_cfl("StartServer")

	if NOT FileExists($DIR_WWW) Then
		msgbox(16,$TITLE,"Web root is missing ("&$DIR_WWW&")")
		exit
	endif

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
	_cfl("Waitng For Connections")

	TCPStartUp()
	for $i=1 to 60
		$SQLSocket = TCPListen($SQLADDRESS, $SQLPORT)
		$SQLERROR=@error
		TCPCloseSocket ($SQLSocket)
		$WebSocket = TCPListen($WebADDRESS, $WEBPORT)
		$WEBERROR=@error
		TCPCloseSocket ($WebSocket)

		if $SQLERROR=10048 AND $WEBERROR=10048 then exitloop
		;if $SQLERROR=10048 AND ($WEBERROR=10048 OR $APACHELISTEN="") then exitloop

		sleep(100)
	next

	ProgressSet(80,"Checking Proccesses & Connections")
	_cfl("Checking Proccesses & Connections")

	if ProcessExists($PID_Apache)=0 AND $WEBERROR<>10048 Then
		_cfl("Apache proccess failed to start and connection could not be detected")
		msgbox(16,$TITLE,"Apache proccess failed to start and connection could not be detected")
		Exit

	elseif ProcessExists($PID_Apache)=1 AND $WEBERROR<>10048 Then
		_cfl("Apache proccess started but connection could not be detected")
		msgbox(16,$TITLE,"Apache proccess started but connection could not be detected")
		Exit

	elseif ProcessExists($PID_MySQL)=0 AND $WEBERROR<>10048 Then
		_cfl("MySQL proccess failed to start and connection could not be detected")
		msgbox(16,$TITLE,"MySQL proccess failed to start and connection could not be detected")
		Exit

	elseif ProcessExists($PID_MySQL)=1 AND $WEBERROR<>10048 Then
		_cfl("MySQL proccess started but connection could not be detected")
		msgbox(16,$TITLE,"MySQL proccess started but connection could not be detected")
		Exit
	endif

	ProgressOff()

endfunc