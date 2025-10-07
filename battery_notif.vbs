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

dim bWarnVeryLow, bWarnLow, bWarnAlmostFull, bWarnFull ' Warning booleans - "to avoid constant pop-ups."
bWarnVeryLow 		= false
bWarnLow 				= false
bWarnAlmostFull = false
bWarnFull 			= false
while(true)
	set oResults = oServices.ExecQuery("select * from batterystatus")
	for each oResult in oResults
		iRemaining = oResult.RemainingCapacity
		bCharging = oResult.Charging
	next
	iPercent = ((iRemaining / iFull) * 100) mod 100
	if bCharging and (iPercent >= 100) and (not bWarnFull)  then
		oShell.Run "powershell -Command ""Try {Import-Module BurntToast -ErrorAction Stop} Catch {} ; " & _
							 "$Settings = New-BTButton -Content 'Open Settings' -Arguments 'ms-settings:batterysaver' ; " & _
							 "new-BurntToastNotification -Text 'Battery Monitor', 'Battery is at full capcity!', 'Unplug your device to avoid complications!' " & _
							 "-AppLogo '" & sIcon & "'" & _
							 "-Button $Settings""", 0, True
		bWarnVeryLow 		= false
		bWarnLow 				= false
		bWarnAlmostFull = false
		bWarnFull 			= true
	elseif bCharging and (iPercent >= 95) and (not bWarnAlmostFull) then
		oShell.Run "powershell -Command ""Try {Import-Module BurntToast -ErrorAction Stop} Catch {} ; " & _
							 "new-BurntToastNotification -Text 'Battery Monitor', 'Battery is at " & Int(iPercent) & "%' " & _
							 "-AppLogo '" & sIcon & "'""", 0, True
	  bWarnVeryLow 		= false
		bWarnLow 				= false
		bWarnAlmostFull = true
		bWarnFull 			= false
	elseif (not bCharging) and (iPercent <= 25) and (not bWarnLow) then
		oShell.Run "powershell -Command ""Try {Import-Module BurntToast -ErrorAction Stop} Catch {} ; " & _
							 "new-BurntToastNotification -Text 'Battery Monitor', 'Battery is at " & Int(iPercent) & "%' " & _
							 "-AppLogo '" & sIcon & "'""", 0, True
		bWarnVeryLow 		= false
		bWarnLow 				= true
		bWarnAlmostFull = false
		bWarnFull 			= false
	elseif (not bCharging) and (iPercent <= 10) and (not bWarnVeryLow) then
		oShell.Run "powershell -Command ""Try {Import-Module BurntToast -ErrorAction Stop} Catch {} ; " & _
							 "$Settings = New-BTButton -Content 'Open Settings' -Arguments 'ms-settings:batterysaver' ; " & _
							 "new-BurntToastNotification -Text 'Battery Monitor', 'Batter is critacally low!', 'Hibernate your device to avoid complications.' " & _
							 "-AppLogo '" & sIcon & "'" & _
							 "-Button $Settings""", 0, True
		bWarnVeryLow 		= true
		bWarnLow 				= false
		bWarnAlmostFull = false
		bWarnFull 			= false
	end if
	wscript.sleep 180000 ' 3 minutes
wend