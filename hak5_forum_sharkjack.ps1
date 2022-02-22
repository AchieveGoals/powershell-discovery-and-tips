# Title:         SharkJack Helper Script (PowerShell)
# Author:        Hak5 (rewritten for Windows by REDD)
# Version:       1.2
######################################################################
# URL: https://forums.hak5.org/topic/51075-tool-sharkjackps1-powershell-version-of-sharkjacksh/
######################################################################
# Usage on Windows:
# Open Notepad, Paste and Save
#  ## @echo off
#  ## cls
#  ## PowerShell.exe -ExecutionPolicy Bypass -File %~dp0sharkjack.ps1
#  ## exit /b
# save as launcher.cmd in same directory as sharkjack.ps1 file, then double-click on launcher.cmd
# to run
######################################################################
# Note: after ssh, run clearssh to wipe known hosts in .ssh
######################################################################
#
# 1 - download payload lib from github
# 2 - Install sharklib to sharkjack
# 3 - remove sharklib from sharkjack
# 4 - copy payload to SharkJack (interactive)
#
# 5 - connect to sharkjack (ssh)
# 6 - connect to sharkjack (web ui)
#
# 7 - update shark jack
#
# 9 - remove all downloaded files
#
# 0 - Exit
#
# Please select a # and press ENTER:
#
######################################################################

# Remove for Debugging purposes.
$ErrorActionPreference = "SilentlyContinue"

# Base Script Variables - DO NOT CHANGE
Write-Host "Initializing... One Moment Please..."
$console = $host.ui.rawui
$console.backgroundcolor = "Black"
$console.foregroundcolor = "Green"
$colors = $host.privatedata
$colors.verbosebackgroundcolor = "Yellow"
$colors.verboseforegroundcolor = "Black"
$colors.warningbackgroundcolor = "Red"
$colors.warningforegroundcolor = "white"
$colors.ErrorBackgroundColor = "DarkCyan"
$colors.ErrorForegroundColor = "Yellow"
$DIR = Convert-Path .


# Script Variables
$SHARKJACK_IP = "172.16.24.1"
$REMOTE_PAYLOAD = "root@$SHARKJACK_IP`:/root/payload/payload.sh"
$UPGRADE_FILE = 'https://downloads.hak5.org/api/devices/sharkjack/firmwares/1.1.0'
$BASEFILENAME = "upgrade-1.1.0.bin"
$FIRMWARE_SHA = "03638c7937a1718b6535116eac8b0a75f2a79054e61dc401af56b51da2044386"
$PAYLOADDIR = $DIR+'\library'

$MENU_SELECTION = 0
$CIRCLE = ([char]8226)
Function Header_Ascii {
Write-Host ""
Write-Host " ########################################################"
Write-Host ""
Write-Host ""
Write-Host "     \_____)\_____      Shark Jack      _____/(_____/"
Write-Host "     /--v____ __$CIRCLE<       by Hak5        >$($CIRCLE)__ ____v--\"
Write-Host "            )/                              \("
Write-Host ""
Write-Host ""
Write-Host " ########################################################"
Write-Host "                 Windows Version by REDD"
Write-Host ""
}
Function Initialize {
	$CONN_SUCC = 0
	$LOOP = 0
	while ($CONN_SUCC -eq 0) {
		$connection = Test-Connection "$SHARKJACK_IP" -Count 1 -Quiet
		If ($connection -eq $true) {
			Write-Host "SharkJack detected.."
			Start-Sleep -s 2
			$CONN_SUCC = 1;
		} ElseIf ($connection -eq $false) {
			If ($LOOP -eq 0) {
				Write-Host -NoNewline "Please Connect the SharkJack in Arming Mode.."
				Start-Sleep -s 2
				$LOOP = 1;
			} Else {
				Write-Host -NoNewline "."
				Start-Sleep -s 2
			}
		}
	}
}
Function Download_Repo {
	Write-Host "Checking if Connection to Internet is possible with SharkJack connected."
	Write-Host ""
	Write-Host "Please Wait.."
	Write-Host ""
	$HTTP_Request = [System.Net.WebRequest]::Create('http://google.com')
	$HTTP_Response = $HTTP_Request.GetResponse()
	$HTTP_Status = [int]$HTTP_Response.StatusCode
	If ($HTTP_Status -eq 200) {
		Write-Host " -> Connection established!"
		$Connection_Check = 1
	}
	Else {
		Write-Host " -> Connection Failed!"
		$Connection_Check = 0
	}
	If ($HTTP_Response -eq $null) { 
	} 
	Else { 
		$HTTP_Response.Close() 
	}
	Write-Host ""
	if ( $Connection_Check -eq 1 ) {
		if (!(Test-Path $PAYLOADDIR)) {
			Write-Host "Downloading Payload Library from GitHub.. Please Wait."
			$WebClient = New-Object System.Net.WebClient
			$WebClient.DownloadFile("https://github.com/hak5/sharkjack-payloads/archive/master.zip","$DIR\master.zip")
			Write-Host "Extracting Payload Library.."
			Expand-Archive -LiteralPath $DIR\master.zip -DestinationPath $DIR
			Get-ChildItem -Path "$DIR\sharkjack-payloads-master" | Copy-Item -Force -Destination "$DIR" -Recurse -Container
			Get-ChildItem -Path "$DIR\sharkjack-payloads-master\payloads" | Copy-Item -Force -Destination "$DIR" -Recurse -Container
			Remove-Item $DIR\sharkjack-payloads-master -Force -Recurse -ErrorAction SilentlyContinue
			Remove-Item $DIR\payloads -Force -Recurse -ErrorAction SilentlyContinue
			Write-Host "Cleaning up Repo Files.."
			Remove-Item -path $DIR\master.zip -force
			Remove-Item -path $DIR\README.md -force
			Remove-Item -path $DIR\sharkjack.sh -force
			Write-Host "Finished."
			Start-Sleep -s 2
		} Else {
			Write-Host "Payload Directory is already present in current Folder."
			Start-Sleep -s 2
		}
	} Else {
		Write-Host "  Disconnect the SharkJack from the PC OR Set your Internet to"
		Write-Host "  the correct configurations, and try again."
		Start-Sleep -s 15
	}
}

Function Copy_Payload {
	if (!(Test-Path $PAYLOADDIR)) {
		Write-Host "No Payload Library downloaded. Starting Downloading Process."
		Start-Sleep -s 2
		Download_Repo
	}
	Initialize
	$MAINFOLDERS = @(Get-ChildItem $PAYLOADDIR | Select Name | Sort @{Expression={$_.name.length}} -Descending | Out-GridView -Title 'Choose a Directory' -PassThru | Select -ExpandProperty "Name")
	if (!($MAINFOLDERS)) { Write-Host "ERROR: Please Select a Folder."; Start-Sleep -s 2; Menu-Function }
	$PAYLOADSELECTDIR = @(Get-ChildItem $PAYLOADDIR\$MAINFOLDERS | Select Name | Sort @{Expression={$_.name.length}} -Descending | Out-GridView -Title 'Choose a Payload' -PassThru | Select -ExpandProperty "Name")
	if (!($PAYLOADSELECTDIR)) { Write-Host "ERROR: Please Select a Payload."; Start-Sleep -s 2; Menu-Function }
	$SELECTED_PAYLOAD = $PAYLOADDIR+'\'+$MAINFOLDERS+'\'+$PAYLOADSELECTDIR+'\payload.sh'
	Write-Host "Copying ->"
	Write-Host "Source Payload: $SELECTED_PAYLOAD"
	Write-Host "Destin Payload: $DIR\payload.sh"
	Write-Host "Remote Payload: $REMOTE_PAYLOAD"
	Write-Host ""
	Copy-Item "$SELECTED_PAYLOAD" -Destination "$DIR\payload.sh"
	Write-Host "Attempting to Push Payload to SharkJack.."
	scp "$DIR\payload.sh" "$REMOTE_PAYLOAD"
	Write-Host "Finished."
	Start-Sleep -s 2
	Menu-Function
}

Function Copy_Dir_Payload {
	$Current_Payload = $DIR+'\payload.sh'
	if (!(Test-Path "$Current_Payload" -PathType Leaf)) {
		Write-Host "No $Current_Payload exists."
		Start-Sleep -s 7
	} Else {
		Initialize
		Write-Host "Attempting to Push Payload to SharkJack.."
		scp "$DIR\payload.sh" "$REMOTE_PAYLOAD"
		Write-Host "Finished."
		Start-Sleep -s 2
		Menu-Function
	}
}
	
Function Connect_SharkJack {
	Initialize
	Write-Host "Attempting to Connect (SSH) to the SharkJack.."
	ssh "root`@$SHARKJACK_IP"
	Write-Host "Done."
	Start-Sleep -s 2
	Menu-Function
}
Function Clean_Known_Hosts {
	Write-Host "Clearing old SSH Keys for SharkJack. Please Wait.."
	Get-Content $env:userprofile\.ssh\known_hosts | select-string -pattern "$SHARKJACK_IP" -notmatch | Out-File $env:userprofile\.ssh\known_hosts.new
	Copy-Item "$env:userprofile\.ssh\known_hosts" -Destination "$env:userprofile\.ssh\known_hosts.bk"
	Remove-Item -path $env:userprofile\.ssh\known_hosts -force
	Copy-Item "$env:userprofile\.ssh\known_hosts.new" -Destination "$env:userprofile\.ssh\known_hosts"
	Remove-Item -path $env:userprofile\.ssh\known_hosts.new -force
	Write-Host "Removed old SSH Keys for SharkJack. Try to connect again via SSH."
	Start-Sleep -s 3
	Menu-Function
}
Function Connect_SharkJack_Web {
	Initialize
	Write-Host "Attempting to Launch Browser to connect to SharkJack.."
	start "http://$SHARKJACK_IP/cgi-bin/status.sh"
	Menu-Function
}
Function Update_SharkJack {
	Write-Host "Checking if Connection to Internet is possible with SharkJack connected."
	Write-Host ""
	Write-Host "Please Wait.."
	Write-Host ""
	$HTTP_Request = [System.Net.WebRequest]::Create('http://google.com')
	$HTTP_Response = $HTTP_Request.GetResponse()
	$HTTP_Status = [int]$HTTP_Response.StatusCode
	If ($HTTP_Status -eq 200) {
		Write-Host " -> Connection established!"
		$Connection_Check = 1
	}
	Else {
		Write-Host " -> Connection Failed!"
		$Connection_Check = 0
	}
	If ($HTTP_Response -eq $null) { 
	} 
	Else { 
		$HTTP_Response.Close() 
	}
	If ( $Connection_Check -eq 1 ) {
		$FIRMWARE_FILE = $DIR+'\'+$BASEFILENAME
		Write-Host "Downloading Firmware from $UPGRADE_FILE"
		$WebClient = New-Object System.Net.WebClient
		$WebClient.DownloadFile("$UPGRADE_FILE","$FIRMWARE_FILE")
		Write-Host "Checking SHA256 of $FIRMWARE_FILE"
		$CHK_DOWNLOAD = (Get-FileHash -Path $FIRMWARE_FILE -Algorithm "SHA256" -ErrorAction Stop).Hash
		If ($CHK_DOWNLOAD -ne $FIRMWARE_SHA) {
			Write-Host "SHA265 DOES NOT MATCH! Deleting $BASEFILENAME"
			del "$FIRMWARE_FILE"
			Write-Host "Done. Please Retry again."
			Start-Sleep -s 5
			Menu-Function
		} Else {
			Write-Host "SHA256 Matches! Continuing Upgrade.."
			Write-Host ""
			Write-Host "Attempting to start the Upgrade Process.."
			Write-Host "------------------------------------------------------"
			Write-Host "PLEASE ONLY DO THIS IF YOU KNOW WHAT VERSION YOUR"
			Write-Host "SHARKJACK IS ON."
			Write-Host ""
			$Confirm_Update = Read-Host "THIS WILL ERASE EVERYTHING ON THE SHARKJACK! ARE YOU SURE? (y/[N])" 
			Switch ($Confirm_Update) 
			{ 
				Y {Write-host "Confirmed!"; $Update_Confirm_Status = 1} 
				N {Write-Host "Not Confirmed!"; $Update_Confirm_Status = 0} 
				Default {Write-Host "No Input detected. Defaulting to NO."; $Update_Confirm_Status = 0} 
			}
			If ( $Update_Confirm_Status -eq 1 ) {
				Initialize
				Write-Host "Wait 5-10 minutes as the Shark Jack flashes the firmware and reboots."
				Write-Host "DO NOT unplug the device from USB power during this process as doing so will render the device inoperable."
				Write-Host ""
				Write-Host "Pushing $BASEFILENAME to SharkJack."
				scp "$FIRMWARE_FILE" "root`@$SHARKJACK_IP`:/tmp/$BASEFILENAME"
				Write-Host "Initializing Upgrade.."
				ssh "root`@$SHARKJACK_IP" "sysupgrade -n /tmp/$BASEFILENAME"
				Write-Host "Upgrade started.. Waiting 30s.."
				Start-Sleep -s 30
				Write-Host "Wait for SharkJack to start in Arming Mode.."
				Write-Host ""
				Write-Host "Once SharkJack has shut itself down.. It will reboot."
				Start-Sleep -s 2;
				Initialize
			} Else {
				Write-Host "Returning to Menu."
				Start-Sleep -s 2
				Menu-Function
			}
		}
	} Else {
		Write-Host "  Disconnect the SharkJack from the PC OR Set your Internet to"
		Write-Host "  the correct configurations, and try again."
		Start-Sleep -s 15
	}
}

Function Cleanup {
	if (Test-Path $PAYLOADDIR) {
		Write-Host "Found $PAYLOADDIR.. Removing.."
		Remove-Item $PAYLOADDIR -Force -Recurse -ErrorAction SilentlyContinue
	}
	if (Test-Path $DIR\sharkjack.sh) {
		Write-Host "Found sharkjack.sh.. Removing.."
		Remove-Item $DIR\sharkjack.sh -Force
	}
	if (Test-Path $DIR\$BASEFILENAME) {
		Write-Host "Found $BASEFILENAME.. Removing.."
		Remove-Item $DIR\$BASEFILENAME -Force
	}
	if (Test-Path $DIR\payload.sh) {
		Write-Host "Found payload.sh.. Removing.."
		Remove-Item $DIR\payload.sh -Force
	}
	Write-Host "Everything cleaned up."
	Start-Sleep -s 2
	Menu-Function
}
Function Disabled_Func {
	Write-Host ""
	Write-Host "ERROR: Sorry the Selection you made has been disabled."
	Write-Host "ERROR: Please contact REDD or Hak5 regarding this message."
	Write-Host ""
	Start-Sleep -s 5
	Menu-Function
}
Function Menu-Function {
	$MENU_SELECTION = 0
	clear
	Header_Ascii
    $type=Read-Host "
    1 - [D]ownload Payload Library from GitHub
    2 - Install SharkLib to Shark[J]ack
    3 - Remove Shark[L]ib from SharkJack
    4 - [C]opy Payload to SharkJack (Interactive)
    5 - Copy [P]ayload from SharkJack.ps1 Directory

    6 - Connect to SharkJack [S]SH
    7 - Connect to SharkJack [W]eb UI (1.0.1+)

    8 - [U]pdate SharkJack
	
    9 - [R]emove ALL Downloaded Files

    0 - [E]xit
	
	
  Please select a # OR [L]etter and press ENTER"
    Switch ($type){
        1 {$MENU_SELECTION = 1; Download_Repo}
		D {$MENU_SELECTION = 1; Download_Repo}
        2 {$MENU_SELECTION = 1; Disabled_Func}
        3 {$MENU_SELECTION = 1; Disabled_Func}
        4 {$MENU_SELECTION = 1; Copy_Payload}
		C {$MENU_SELECTION = 1; Copy_Payload}
		5 {$MENU_SELECTION = 1; Copy_Dir_Payload}
		P {$MENU_SELECTION = 1; Copy_Dir_Payload}
        6 {$MENU_SELECTION = 1; Connect_SharkJack}
		S {$MENU_SELECTION = 1; Connect_SharkJack}
        7 {$MENU_SELECTION = 1; Connect_SharkJack_Web}
		W {$MENU_SELECTION = 1; Connect_SharkJack_Web}
        8 {$MENU_SELECTION = 1; Update_SharkJack}
		U {$MENU_SELECTION = 1; Update_SharkJack}
        9 {$MENU_SELECTION = 1; Cleanup}
		R {$MENU_SELECTION = 1; Cleanup}
        clearssh { $MENU_SELECTION = 1; Clean_Known_Hosts}
		E { Write-Host "Exiting.. Please Wait."; Exit }
        0 { Write-Host "Exiting.. Please Wait."; Exit }
    }
}
Initialize
while ($MENU_SELECTION -eq 0) {
	Menu-Function
}
