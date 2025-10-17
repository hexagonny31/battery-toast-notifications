' Before running this script, you need a powershell module called "BurntToast".
' If you don't have this module yet, visit it's official website: (https://github.com/Windos/BurntToast)
' or directly run this install command in powershell(ran by administrator): Install-Module -Name BurntToast

set oLocator = CreateObject("WbemScripting.SWbemLocator")
set oServices = oLocator.ConnectServer(".","root\wmi")
set oResults = oServices.ExecQuery("select * from batteryfullchargedcapacity")
for each oResult in oResults
  iFull = oResult.FullChargedCapacity
next

set oShell = CreateObject("WScript.Shell")
set fso = CreateObject("Scripting.FileSystemObject")
oScriptPath = fso.GetParentFolderName(WScript.ScriptFullName)
sIcon = oScriptPath & "\Power.ico"

dim bWarnLow, bWarnAlmostFull, bWasCharging ' Warning booleans - "to avoid constant pop-ups."
bWarnLow        = false
bWarnAlmostFull = false
bWasCharging    = false
while(true)
	set oResults = oServices.ExecQuery("select * from batterystatus")
	for each oResult in oResults
		iRemaining = oResult.RemainingCapacity
		bCharging = oResult.Charging
	next
	if bCharging <> bWasCharging then
		bWarnLow        = false
		bWarnAlmostFull = false
		bWasCharging = bCharging
	end if
	iPercent = int((iRemaining / iFull) * 100)
	if (not bCharging) and (iPercent <= 10) then
		oShell.Run "powershell -Command ""Try {Import-Module BurntToast -ErrorAction Stop} Catch {} ; " & _
		           "$Settings = New-BTButton -Content 'Open Settings' -Arguments 'ms-settings:batterysaver' ; " & _
		           "new-BurntToastNotification -Text 'Battery Monitor', 'Battery is critically low!', 'Hibernate your device to avoid complications.' " & _
		           "-AppLogo '" & sIcon & "' -Button $Settings""", 0, true
		bWarnLow        = false
		bWarnAlmostFull = false
	elseif (not bCharging) and (iPercent <= 25) and (not bWarnLow) then
		oShell.Run "powershell -Command ""Try {Import-Module BurntToast -ErrorAction Stop} Catch {} ; " & _
		           "new-BurntToastNotification -Text 'Battery Monitor', 'Battery is at " & iPercent & "%' " & _
		           "-AppLogo '" & sIcon & "'""", 0, true
		bWarnLow        = true
		bWarnAlmostFull = false
	elseif bCharging and (iPercent >= 98)  then
		oShell.Run "powershell -Command ""Try {Import-Module BurntToast -ErrorAction Stop} Catch {} ; " & _
		           "$Settings = New-BTButton -Content 'Open Settings' -Arguments 'ms-settings:batterysaver' ; " & _
		           "new-BurntToastNotification -Text 'Battery Monitor', 'Battery is at full capacity!', 'Unplug your device to avoid complications!' " & _
		           "-AppLogo '" & sIcon & "' -Button $Settings""", 0, true
		bWarnLow        = false
		bWarnAlmostFull = false
	elseif bCharging and (iPercent >= 90) and (not bWarnAlmostFull) then
		oShell.Run "powershell -Command ""Try {Import-Module BurntToast -ErrorAction Stop} Catch {} ; " & _
		           "new-BurntToastNotification -Text 'Battery Monitor', 'Battery is at " & iPercent & "%' " & _
		           "-AppLogo '" & sIcon & "'""", 0, true
		bWarnLow        = false
		bWarnAlmostFull = true
	end if
	wscript.sleep 180000 ' 3 minutes
wend