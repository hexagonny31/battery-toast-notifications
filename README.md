# battery-toast-notifications
A simple VBScript that deploys a toast notification for your battery levels.<br><br>
Before running this script, you need a powershell module called "BurntToast".<br>
If you don't have this module yet, visit it's official website: 'https://github.com/Windos/BurntToast'<br>
or directly run this install command in powershell(ran by administrator): 'Install-Module -Name BurntToast'

### To automatically run at start up
Create a shortcut of the script (vbs file) and put into startup directory:<br>
Win+R: Open: [shell:startup] -> [OK]<br>
(C:\Users\YOU\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup)

### To end the script
Go to task manager and find "Microsoft ® Windows Based Script Host"<br>
Simply select then click [End Task]
