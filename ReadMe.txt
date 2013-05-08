=Simple Invoices For Windows=

Simple Invoices For Windows is a combination of the simple invoices web app and a custom portable webserver. Simple Invoices For Windows
will allow you to use or just try Simple Invoices without having to own or configure a webserver. Simple Invoices For Windows doesn't require
you to install it to your computer, once unzipped you can move the SimpleInvoices folder anyplace on your computer or even to a USB drive to take with you to another computer.

This Windows based version of Simple Invoices is maintained by John McLaren at http://JohnsCS.com/SimpleInvoices  -  john@johnscs.com

Support may be offered by emailing John or by visiting the Simple Invoices Google+ community at 

==Limitations & Special Considerations:==

	* Simple Invoices offers you a quick and easy way to email an invoice using the SMTP protocol, this function could experience problems. Follow the Simple Invoices instructions like normal for configuring email and make sure you use SSL/Secure settings.
	   
	* Simple Invoices allows you to setup recurring invoices (i.e. monthly automatic billing). This feature uses a webserver feature called 'cron', this feature is not available in a portable webserver such as the one used for Simple Invoices For Windows and no workaround is currently known.

	* Simple Invoices For Windows uses a custom configured portable webserver and database server, these services use a network connection to communicate with each other even though they remain on the same computer, some antivirus programs or firewalls might try to block these connections
	
	* Using Simple Invoices For Windows on a computer that has an installation of Apache, MySQL or PHP could cause problems, please report these issues along with details about your configuration
	
==Instructions:==

	* Unzip the "Simple Invoices For Windows" folder to your desktop, hard drive or a portable USB drive.
	* Run "SimpleInvoices.exe" inside the "Simple Invoices For Windows" folder
	* Select one of the following:
		* "GUI" to start Simple Invoices in its own window.
		* "Browser" to start Simple Invoices in you web browser (close Simple Invoices using its tray icon).
	* Follow the instruction on screen to configure Simple Invoices.
	* If advanced or specific configuration is necessary for Simple Invoices, simply navigate and edit the Simple Invoices Installation in the "www" folder.

==Configuration:==

	To configure options for Simple Invoices itself please visit [Install]  or  http://code.google.com/p/simpleinvoices/wiki/Install

	To configure options specific to "Simple Invoices For Windows" (not Simple Invoices)
	open and edit Settings.ini in the "Simple Invoices For Windows" folder. 
	Here is an explanation of some options you will see in Settings.ini.

	* GUI=1
		* Setting this to 0 will not allow the user to choose the GUI option when starting Simple Invoices

	* Browser=1
		* Setting this to 0 will not allow the user to choose the DefaultBrowser option when starting Simple Invoices.

	* PromptGUIBrowser=1
		* Setting this to 0 will not prompt the user to choose the startup method of Simple Invoices, 
		* Whatever method is enabled will be the one to start, if both are enabled or disabled the GUI method will be used.

	* TrayIcon=0
		* Settings this to 1 will show a system tray icon giving you a few simple functions (Browser mode forces the tray icon to appear).

	* PHPMyAdmin=1
		* Setting this to 0 will hide the options to open the database manager PHPMyAdmin,
		* Note that PHPMyAdmin can still be accessed manually in a web browser given the correct URL, to make PHPMyAdmin inaccessible you may remove or move the contents of the 'phpmyadmin' folder

	* ToggleServer=1
		* Setting this to 0 will hide the options to start and stop the server.

	* WebAddress=localhost
		* Setting this to blank will allow other computers on your network to access SimpleInvoice given the correct URL.
		* For this to work other factors need to be accounted for, including network configuration and firewall settings.
		* The URL should be in this format: http://*IP*:*port* check settings.ini for "WebPort"

	* WebPort=8877
		* Change this only if you get a message saying apache won't start and you suspect that another program on your computer is using this port.

	* SQLServer,SQLAddress,SQLPort
		* Advanced settings for the MySQL server, change these only if you have a port conflict or want to disable the SQL server to use a remote server.
		* Note that changing these settings will require you to reconfigure Simple Invoice's 'config.ini'
			

==Software Versions:==
        * AutoIT 3.3.8.1 - http://www.autoitscript.com
        * Simple Invoices 2011.1 - http://www.simpleinvoices.org
        * PHP 5.2.17 - http://php.net
        * Apache 2.2.21 - http://httpd.apache.org
        * MySQL  5.0.96 - http://mysql.com/


==Changes:==
      * 1.7.0 - 
               * Changed: Updated AutoIT to 3.3.8.1
               * Changed: Updated PHPMyAdmin to 3.5.1
      	       * Changed: Downgraded MySQL to match PHP library and database server versions potentially solving some db setup issues
	       * Changes: Made sure that all external projects had a properly formatted and named LICENSE.txt file
               * Changed: Browser UI menus have been consolidated under the file submenu
               * Changed: Moved "<< Back" button from sub menu to main menu
               * Changed: Split some primary functions into separate include files to make group editing tolerable
               * Changed: Updated and Optimized this readme for google code wiki (will be maintained on google code going forward)
               * Changed: Restructured Settings.ini for simplicity
               * Changed: "ToggleServer" (previously "startstopserveroption") is disabled by default
	       * Added: Error handling for if "www" folder is missing
               * Added: Print button to main menu
               * Added: New ini values for program name and version, instead of having them embedded
               * Added: "SQLServer" and "SQLAddress" options in settings.ini, use this to disable the built in SQL server and use your own
               * Added: New Custom GUI for GUI prompt
               * Added: Check box on GUI prompt screen to set the default start option
               * Added: Gear icon on GUI prompt and 'Settings' item to file menu (currently opens settings.ini)
	       * Fixed: PHP modules not loading in some instances (libeay32.dll & ssleay32.dll).
	       * Fixed: Added GD2 php extension to enable logos in generated PDF's
	       * Fixed: Browser back button causing program to crash if nothing to go back to
	       * Fixed: Added openssl php extension (fixed error when using ssl with email configuration)
	       * Fixed: Server shutdown adjusted for speed and safety
               * Fixed: Updates to ReadMe.txt
               * Fixed: mcrypt module not loading in php
	       * Fixed: Window activation priority when opening the program and its already running
               * Fixed: Minor code optimizations and adjustments
               * Removed: Unused PHP extension for connecting to MSSQL

      * 1.6.0 - 9/18/2011
               * Changed: Updated Apache to 2.2.21
               * Changed: Updated MySQL to 5.5.16
               * Changed: Updated To PHP 5.2.17
               * Changed: Web root folder is now "www" instead of "si"
               * Fixed: Using default browser option forces tray icon to appear (had no way to exit program otherwise)
               * Fixed: About dialog not appearing
               * Fixed: MySQL safe shutdown procedure failing
               * Note: This release contains No binary's from a 3rd party, 
	       		they are all direct from their respective projects. Also, no files are compressed (UPX)
			This should solve any false positives with any anti-virus program

      * 1.5.0 - 5/25/2011
               * Added: ini Option EnableTrayIcon
               * Added: Menu items previously used in the tray will no also appear in the 'help' menu
               * Changed: Tray Disable By Default
               * Changed: Renamed ini option "ShowPHPMyAdminTrayOption" to "ShowPHPMyAdminOption"
               * Changed: Renamed "ShowPHPMyAdminTrayOption" to "ShowPHPMyAdminOption"
               * Changed: Updated Simple Invoices to version 2011.1
               * Changed: Added note to si config.ini, noting that the default port for MySQL is 3306
               * Changed: Renamed apache and mysql server processes to start with "simpleinvoices_" making them easy to find in task manager
               * Changed: Start or Stop server is now always displayed as "Toggle Server" but prompts you with a confirmation of the action to be taken
               * Changed: Set password "1234" for mysql root user
               * Fixed: Simple Invoices version not showing in about dialog
               * Fixed: Default mysql port was set to 3306 instead of 3304 if settings.ini was missing
               * Fixed: Default bind address was set incorrectly if settings.ini was missing
               * Fixed: If bind address was blank (bind to all addresses) a false error would be displayed
               * Fixed: Typo in settings.ini - height value was being ignored because key was spelled "hight"
               * Note: Other minor tweaks and internal script adjustments

      * 1.4.1 - 9/17/2010
               * Added: XLM support for reports
               * Added: ReadMe.txt
               * Changed: Default MySQL port is now 3304 instead of 3306
               * Changed: Renamed the simpleinvoices folder to si to avoid confusion when following directions to unpack from zip
               * Note: This version contains the exact same "SimpleInvoices.exe" as the previous version, no changes were needed.

      * 1.4.0 - 8/30/2010
               * First official release
 
