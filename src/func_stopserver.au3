func StopServer()
	_cfl("StopServer")

	ProgressOff()
	ProgressOn($TITLE,$TITLE,$TITLE_SHORT&" Closing",Default,@DesktopHeight/2-200,16)

	ProgressSet(10,"Attempting Safe MySQL Shutdown")
	$PID=Run(@ComSpec & " /c " & 'mysql\bin\mysqladmin.exe --port='&$SQLPORT&' --user=root shutdown',@ScriptDir, @SW_HIDE)


	ProgressSet(30,"Waiting For MySQL Shutdown")
	if ProcessWaitClose($PID,3)=0 then
		ProcessClose ($PID)
		_cfl("MySQL seems to of failed a proper shutdown (we should now see it forced closed)")
	endif

	ProcessWaitClose($Proccess_MySQL,2)

	if ProcessExists($Proccess_MySQL) then
		_cfl("Closing MySQL Proccesses (forced) ")
		ProgressSet(50,"Closing MySQL Proccesses")
		_ProcessCloseOthers($Proccess_MySQL)
	endif

	if ProcessExists($Proccess_Apache) then
		_cfl("Closing Apache Proccesses (forced but expected)")
		ProgressSet(70,"Closing Apache Proccesses")
		_ProcessCloseOthers($Proccess_Apache)
	EndIf

	_cfl("Updating Program State")
	ProgressSet(90,"Updating Program State")

	OnAutoItExitUnregister("StopServer")
	$STATE_SERVER=0

	ProgressOff()

endfunc