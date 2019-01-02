#You need to temporarily set the Powershell execution policy to remotesigned for it to run. after set it back to its original state
#Get Execution Policy command
$Get-ExecutionPolicy
#Set Execution Policy command
#Set-ExecutionPolicy remotesigned

# MSI file location
$msiPath = {kaltura_classroom_install_msi}
# Create Directories
$recordingPath = 'T:\Kaltura\Recordings'
$logPath = 'T:\Kaltura\Logs'
New-Item -Path $recordingPath -ItemType directory -Force
New-Item -Path $logPath -ItemType directory -Force

# Install Parameters
$appToken = {app_token}
$appTokenId = {app_token_id}
$partnerId = {partner_id}
$defaultUserId = {kaltura_user_id}

# Start msi install in process so we can retrieve the ExitCode to determine if we can then make the changes to the localSettings.json file
# Silent install, currently not working...
# $proc = Start-Process msiexec -Wait -PassThru -ArgumentList "/i",$msiPath,"ADDLOCAL=UploadServiceFeature,LaunchOnLoginFeature,CaptureAppFeature","KALTURA_RECORDINGS_DIR=$recordingPath","KALTURA_APPTOKEN=$appToken","KALTURA_APPTOKEN_ID=$appTokenId","KALTURA_PARTNER_ID=$partnerId","KALTURA_DEFAULT_USER_ID=$defaultUserId","/L*V","T:\Kaltura\Logs\install.log","/qn"

# Mostly silent install, currently the one that works
$proc = Start-Process msiexec -Wait -PassThru -ArgumentList "/i",$msiPath,"ADDLOCAL=UploadServiceFeature,LaunchOnLoginFeature,CaptureAppFeature","KALTURA_RECORDINGS_DIR=$recordingPath","KALTURA_APPTOKEN=$appToken","KALTURA_APPTOKEN_ID=$appTokenId","KALTURA_PARTNER_ID=$partnerId","KALTURA_DEFAULT_USER_ID=$defaultUserId","/L*V","T:\Kaltura\Logs\install.log","/qn"
if ($proc.ExitCode -eq 0) {
    $localSettingsFile = Get-Content -Raw -Path "C:\Program Files\Kaltura\Classroom\Settings\localSettings.json" | ConvertFrom-Json
    # Set logsDir
    $newLogsDir = 'T:\Kaltura\Logs'
    $localSettingsFile.config.shared.logsDir = $newLogsDir
    # Turn on silentStart
    $newSilentStart = $true
    $localSettingsFile.config.captureApp.silentStart = $newSilentStart
    # Turn on captureSystemAudio
    $newcaptureSystemAudio = $true
    $localSettingsFile.config.captureEngine.captureSystemAudio = $newcaptureSystemAudio
    # Write changes to localSettings.json file
    $localSettingsFile | ConvertTo-Json -Depth 10 | Set-Content 'C:\Program Files\Kaltura\Classroom\Settings\localSettings.json'
    'Install successful, new values written to localSettings.json file'
} else {
    'Install failed, check settings and try again.'
