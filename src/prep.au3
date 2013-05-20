#NoTrayIcon
if Msgbox(1,"Prep","Are you sure?") <> 1 then exit

FileRecycle("..\apache\logs\error.log")
FileRecycle("..\apache\logs\http.pid")
FileRecycle("..\apache\conf\httpd.conf")
FileRecycle("..\mysql\data\simple_invoices\*.frm")
FileRecycle("..\mysql\data\simple_invoices\*.myi")
FileRecycle("..\mysql\data\simple_invoices\*.myd")
FileRecycle("..\mysql\my.ini")
FileRecycle("..\php\php.ini")
FileRecycle("..\www\tmp\zend_cache---*")
FileRecycle("..\www\tmp\log\*.log")
FileRecycle("..\www\tmp\cache\*.php")

Msgbox(0,"Prep","Done")