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
sReportPath = oScriptPath & "\battery-report.html"
sIcon = oScriptPath & "\Power.ico"

function ConvertTime(dTime)
    if dTime = 0 then
        sTime = "null"
    elseif dTime < 1 then
        dTime = dTime * 60
        sTime = formatnumber(dTime, 0) & " minutes"
    else
        sTime = formatnumber(dTime, 2) & " hours"
    end if
    ConvertTime = sTime
end function

function ShowToast(arrLines)
	sPrompt = ""
	for i = 0 to ubound(arrLines)
		if i > 0 then sPrompt = sPrompt & ", "
		sPrompt = sPrompt & "'" & arrLines(i) & "'"
	next

	oShell.run "powershell -Command ""Try {Import-Module BurntToast -ErrorAct Stop} Catch {} ; " & _
	           "$Settings = New-BTButton -Content 'Settings' -Arguments 'ms-settings:batterysaver' ; " & _
	           "$Report = New-BTButton -Content 'Open Report' -Arguments '" & sReportPath & "' ; " & _
	           "new-BurntToastNotification -Text " & sPrompt & _
	           " -AppLogo '" & sIcon & "' -Button $Settings, $Report""", 0, true
end function

bWarnLow = false        ' Warning booleans - "to avoid constant pop-ups."
bWarnAlmostFull = false
bWarnFull = false
bWasCharging = false
while(true)
	oShell.Run "powershell -Command ""powercfg /batteryreport /output '" & sReportPath & "';""", 0, false
	set oResults = oServices.ExecQuery("select * from batterystatus")
	for each oResult in oResults
		iRemaining = oResult.RemainingCapacity
		bCharging = oResult.Charging
		bPowerOnline = oResult.PowerOnline
		iDischargeRate = oResult.DischargeRate
		iChargeRate = oResult.ChargeRate
	next

	if bCharging <> bWasCharging then ' Checks if the charging state changed.
		bWarnLow = false
		bWarnAlmostFull = false
		bWarnFull = false
		bWasCharging = bCharging
	end if

	dTimeRemain = 0
	if iDischargeRate <> 0 then dTimeRemain = iRemaining / iDischargeRate
	if iChargeRate <> 0 then dTimeRemain = (iFull - iRemaining) / iChargeRate
	sTimeRemain = converttime(dTimeRemain)

	iPercent = int((iRemaining / iFull) * 100)
	arrPrompts = empty
	if (not bCharging) and (iPercent <= 10) then
		arrPrompts = array("Battery Monitor", "Battery is critically low!", "Hibernate your device to avoid complications.")
	elseif (not bCharging) and (iPercent <= 25) and (not bWarnLow) then
		arrPrompts = array("Battery Monitor", "Battery is at " & iPercent & "%", dTimeRemain & " until full.")
		bWarnLow = true
	elseif (bCharging or bPowerOnline) and (iPercent >= 100) and (not bWarnFull) then
		arrPrompts = array("Battery Monitor", "Battery is at full capacity!", "Your device is now using AC power.")
		bWarnFull = true
	elseif bCharging and (iPercent >= 95) and (not bWarnAlmostFull) then
		arrPrompts = array("Battery Monitor", "Battery is at " & iPercent & "%", dTimeRemain & " remaining.")
		bWarnAlmostFull = true
	end if

	if isarray(arrPrompts) then
		showtoast arrPrompts
	end if
	wscript.sleep 180000 ' 3 minutes
wend