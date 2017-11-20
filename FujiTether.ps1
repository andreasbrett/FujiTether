#	Mode		Total	transfer	display		comment
#	-------------------------------------------------------------
#	USB2.0		7.58s	2.93s		4.65s		Lightroom CC
#	USB3.0		6.76s	2.8s		3.8s		Lightroom CC
#	USB2.0		2.9s	2.6s		0.3s		FujiTether
#	USB3.0		2.7s	2.4s		0.3s		FujiTether


# ---------------------------------
# change these settings if you wish
# ---------------------------------
$FujiXAcquire = "C:\Program Files (x86)\FUJIFILM\XAcquire\XAcquire.exe"
$watchExtension = "*.jpg"
$moveExtension = "*.raf"
$watchIntervalInMsec = 250






# source code for keyboard send in C#
$source = @" 
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
using System.Windows.Forms;
namespace KeyboardSend {
    public class KeyboardSend { 
        [DllImport("user32.dll")] 
        public static extern void keybd_event(byte bVk, byte bScan, int dwFlags, int dwExtraInfo); 
        private const int KEYEVENTF_EXTENDEDKEY = 1; 
        private const int KEYEVENTF_KEYUP = 2; 
        public static void KeyDown(Keys vKey) {
            keybd_event((byte)vKey, 0, KEYEVENTF_EXTENDEDKEY, 0); 
        } 
        public static void KeyUp(Keys vKey) {
            keybd_event((byte)vKey, 0, KEYEVENTF_EXTENDEDKEY | KEYEVENTF_KEYUP, 0); 
        }
    }
}
"@

# type definition for C# source code
Add-Type -TypeDefinition $source -ReferencedAssemblies "System.Windows.Forms" 

# press Win+Shift+Enter to make app fullscreen
Function makeFullScreen() { 
    [KeyboardSend.KeyboardSend]::KeyDown("LWin") 
    [KeyboardSend.KeyboardSend]::KeyDown("LShiftKey") 
    [KeyboardSend.KeyboardSend]::KeyDown("Return") 
    [KeyboardSend.KeyboardSend]::KeyUp("LWin") 
    [KeyboardSend.KeyboardSend]::KeyUp("LShiftKey") 
    [KeyboardSend.KeyboardSend]::KeyUp("Return") 
}

# main process
Function startFujiTether() {
	Write-Host "FujiTether"
	Write-Host "-----------------------------------------------------------------"

	# retrieve Fuji X-Acquire destination folder from registry
	$watchFolder = (Get-ItemProperty -Path HKCU:\SOFTWARE\COM.FUJIFILM.DENJI\XAcquire\Preferences -Name Destination -ErrorAction SilentlyContinue).Destination
	$storeFolder = "$($watchFolder)\FujiTether"

	if (-Not $watchFolder) {
		Write-host "ERROR: Fuji X-Acquire destination folder could not be read! Did you download and install it?"

	} else {

		Write-Host " - watched folder: $($watchFolder)\$($watchExtension)"
		Write-Host " - destination:    $($storeFolder)"
		Write-Host " - interval:       $($watchIntervalInMsec)msec"
		Write-Host ""
		Write-Host " > Press Ctrl+C to stop"
		Write-Host ""

		# catch ctrl+c
		[console]::TreatControlCAsInput = $true

		# start Fuji X-Acquire upfront
		& $FujiXAcquire

		# create $storeFolder
		New-Item -ItemType Directory -Force -Path "$($storeFolder)" | Out-Null

		# move already existing pictures first
		Get-ChildItem $watchFolder -Filter $watchExtension | ForEach-Object {
			Move-Item $_.FullName -Destination $storeFolder
		}

		# infinite loop (ctrl+c to stop)
		while($true) {

			# ctrl+c pressed?!
			if($Host.UI.RawUI.KeyAvailable -and (3 -eq [int]$Host.UI.RawUI.ReadKey("AllowCtrlC,IncludeKeyUp,NoEcho").Character)) {		
				Write-Host " * Ctrl+C detected. Quitting."
				
				# stop Fuji X-Acquire
				Stop-Process -Name XAcquire -ErrorAction SilentlyContinue
			
				# break out of the loop
				break
			}
		
			# fetch all watched file types from watchFolder
			if ($files = Get-ChildItem $watchFolder -Filter $watchExtension) {
				Write-Host " * $($files[0].Name)"
			
				# move first file to subfolder
				Move-Item -Path $files[0].FullName -Destination $storeFolder
			
				# kill old viewer
				Stop-Process -Name Microsoft.Photos -ErrorAction SilentlyContinue
			
				# wait a tiny bit for the move operation to be completed
				Start-Sleep -Milliseconds 150
			
				# open viewer
				Invoke-Item -Path "$($storeFolder)\$($files[0].Name)"

				# send viewer to fullscreen (via keypress F11)
				Start-Sleep -Milliseconds 150
				makeFullScreen
			}
		
			# move files matching $moveExtension
			Get-ChildItem $watchFolder -Filter $moveExtension | ForEach-Object {
				Move-Item $_.FullName -Destination $storeFolder
			}

			# wait for next round
			Start-Sleep -Milliseconds $watchIntervalInMsec
		}
	}

	# wait for user to end program
	Write-Host ""
	Write-Host "-----------------------------------------------------------------"
	Write-Host "Press any key to close this window."
	$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
}



# run program
startFujiTether
