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