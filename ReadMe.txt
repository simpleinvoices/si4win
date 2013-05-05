Simple Invoices For Windows

http://SimpleInvoices.org

http://TeamMC.cc - john@teammc.cc


Instructions:

	1. Unzip the "Simple Invoices For Windows" folder to your desktop, hard drive or a portable USB drive.
	2. Run "SimpleInvoices.exe" inside the "Simple Invoices For Windows" folder
	3. Choose "Start Simple Invoices"
		3a. Choose the "GUI" option to start Simple Invoices in its own window.
		3b. Choose the "Default Browser" option to start Simple Invoices like a regular web page.
	4. Follow the instruction on screen to configure Simple Invoices.

	If You use the GUI Option 


Configuration:

	To configure options for Simple Invoices itself please visit http://SimpleInvoices.org

	To configure options specific to "SimpleInvoices for windows" (not Simple Invoices)
	open and edit Settings.ini in the "Simple Invoices For Windows" folder.

		
	Basic Settings:
		EnableGUI=1
			Setting this to 0 will not allow the user to choose the GUI option when starting Simple Invoices

		EnableDefaultBrowser=1
			Setting this to 0 will not allow the user to choose the DefaultBrowser option when starting Simple Invoices

		PromptBeforeLaunch=1
			Setting this to 0 will not prompt the user to choose the startup method of Simple Invoices, 
			whatever method is enabled will be the one to start, if both are enabled or disabled the GUI method will be used

		EnableTrayIcon=0
			Settings this to 1 wll show a system tray icon giving you a few simple functions

		ShowPHPMyAdminOption=1
			Setting this to 0 will hide the options to open the database manager PHPMyAdmin,
			note that PHPMyAdmin can still be accessed manualy in a web browser givin the proper url

		ShowToggleServerOption=1
			Setting this to 0 will hide the options to start and stop the server

		Address=localhost
			Setting this to blank will allow other computers on your network to access SimpleInvoice givin the correct URL
			For this to work other factors need to be acounted for including network configuration and firewall settings
			The URL should be in this format: http://<IP>:<port> check settings.ini for "WebPort"


Program Notes:
	-AutoIT 3.3.6.1 - http://www.autoitscript.com
	-Simple Invoices 2011.1  - http://www.simpleinvoices.org
	-PHP 5.2.17 - http://php.net
	-Apache 2.2.21 - http://httpd.apache.org
	-MySQL  5.5.16 - http://mysql.com/


Changes:
	1.6.0 - 9/18/2011
		Changed: Updated Apache to 2.2.21
		Changed: Updated MySQL to 5.5.16
		Changed: Updated To PHP 5.2.17
		Changed: Web root folder is now "www" instead of "si"
		Fixed: Using default browser option forces tray icon to apear (had no way to exit program otherwise)
		Fixed: About dialog not apearing
		Fixed: MySQL safe shutdown procedure failing
		Note: This release contains No binarys from a 3rd part, they are all direct from their respective projects. Also, no files are compressed (UPX)

	1.5.0 - 5/25/2011
		Added: ini Option EnableTrayIcon
		Added: Menu items previously used in the tray will no also apear in the 'help' menu
		Changed: Tray Disable By Default
		Changed: Renamed ini option "ShowPHPMyAdminTrayOption" to "ShowPHPMyAdminOption"
		Changed: Renamed "ShowPHPMyAdminTrayOption" to "ShowPHPMyAdminOption"
		Changed: Updated Simple Invoices to version 2011.1
		Changed: Added note to si config.ini, noting that the default port for MySQL is 3306
		Changed: Renamed apache and mysql server proccesses to start with "simpleinvoices_" making them easy to find in task manager
		Changed: Start or Stop server is now always displayed as "Toggle Server" but prompts you with a confirmation of the action to be taken
		Changed: Set password "1234" for mysql root user
		Fixed: Simple Invoices version not showing in about dialog
		Fixed: Default mysql port was set to 3306 instead of 3304 if settings.ini was missing
		Fixed: Default bind address was set incorrectly if settings.ini was missing
		Fixed: If bind address was blank (accept on all addresses) a false error would be displayed
		Fixed: Typo in settings.ini - height value was being ignored because key was spelled "hight"
		Note: Other minor tweaks and internal script adjustments

	1.4.1 - 9/17/2010
		Added: XLM support for reports
		Added: ReadMe.txt
		Changed: Default MySQL port is now 3304 instead of 3306
		Changed: Renamed the simpleinvoices folder to si to avoid confusion when following directions to unpack from zip
		Note: This version contains the exact same "SimpleInvoices.exe" as the previous version, no changes were needed.

	1.4 - First offical release