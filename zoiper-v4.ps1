####################################### User Config #######################################################
# Complete these values based on your own infrastructure before running the script.
$SimotelApiUrl = "https://simoteldomain.example.com/api/v4/pbx/users/search"
$SimotelBasicAuth = "Basic REPLACE_WITH_BASE64_BASIC_AUTH"
$SimotelApiKey = "REPLACE_WITH_SIMOTEL_API_KEY"
$SipDomain = "simotel.example.com"
$AdPhoneAttribute = "telephoneNumber"

####################################### Read Data From Active and Simotel ###################################################
#Read User Data from Active
$Searcher = New-Object System.DirectoryServices.DirectorySearcher "(&(objectCategory=person)(objectClass=user)(sAMAccountName=$env:USERNAME))"
$User = $Searcher.FindOne().GetDirectoryEntry()
$number = $user.$AdPhoneAttribute

#Read User Data from Sip APi
$headers = @{
    "Authorization" = $SimotelBasicAuth
    "X-APIKEY" = $SimotelApiKey
    "Content-Type" = "application/json"
}

$body = @{
    status = "all"
    alike = $true
    conditions = @{
        number = "$number"
    }
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri $SimotelApiUrl -Headers $headers -Method Post -Body $body
$responseContent = $response.Content | ConvertFrom-Json
$jsonOutput = $responseContent | ConvertTo-Json
$dataObject = ConvertFrom-Json $jsonOutput
$secret = $dataObject.data[0].secret
$name = $dataObject.data[0].name
$number = $dataObject.data[0].number

####################################### Close Zoiper #######################################################
taskkill /F /IM Zoiper.exe

####################################### Folders Creation ###################################################
$currentUserName = $env:USERNAME
$appDataPath = Join-Path -Path $env:USERPROFILE -ChildPath "AppData\Local"
$virtualStorePath = Join-Path -Path $appDataPath -ChildPath "VirtualStore"
$programFilesPath = Join-Path -Path $virtualStorePath -ChildPath "Program Files (x86)"
$attractelPath = Join-Path -Path $programFilesPath -ChildPath "Attractel"
$zoiperPath = Join-Path -Path $attractelPath -ChildPath "zoiper"
$zoiperConfPath = Join-Path -Path $zoiperPath -ChildPath "zoiper.conf"

# Create the VirtualStore folder if it doesn't exist
if (-not (Test-Path -Path $virtualStorePath)) {
    New-Item -ItemType Directory -Path $virtualStorePath -Force | Out-Null
    Write-Host "VirtualStore folder created successfully!"
} else {
    Write-Host "VirtualStore folder already exists."
}

# Create the Program Files (x86) folder if it doesn't exist
if (-not (Test-Path -Path $programFilesPath)) {
    New-Item -ItemType Directory -Path $programFilesPath -Force | Out-Null
    Write-Host "Program Files (x86) folder created successfully!"
} else {
    Write-Host "Program Files (x86) folder already exists."
}

# Create the Attractel folder if it doesn't exist
if (-not (Test-Path -Path $attractelPath)) {
    New-Item -ItemType Directory -Path $attractelPath -Force | Out-Null
    Write-Host "Attractel folder created successfully!"
} else {
    Write-Host "Attractel folder already exists."
}

# Create the zoiper folder if it doesn't exist
if (-not (Test-Path -Path $zoiperPath)) {
    New-Item -ItemType Directory -Path $zoiperPath -Force | Out-Null
    Write-Host "zoiper folder created successfully!"
} else {
    Write-Host "zoiper folder already exists."
}

# Create the zoiper.conf file if it doesn't exist
if (-not (Test-Path -Path $zoiperConfPath)) {
    $null | Out-File -FilePath $zoiperConfPath
    Write-Host "zoiper.conf file created successfully!"
} else {
    Write-Host "zoiper.conf file already exists."
}

####################################### Append XML Code On to Zoiper.conf ###################################################
$xmlCode = @"
<?xml version="1.0" encoding="UTF-8"?>
<options>
	<general>
		<always_on_top>0</always_on_top>
		<automatic_popup_on_incoming_call>1</automatic_popup_on_incoming_call>
		<popup_menu_on_incoming_call>1</popup_menu_on_incoming_call>
		<user_data_visible>1</user_data_visible>
		<volume_controls_visible>1</volume_controls_visible>
		<log_visible>0</log_visible>
		<default_account>accountname</default_account>
		<check_for_updates>0</check_for_updates>
		<start_with_windows>0</start_with_windows>
		<show_hints>0</show_hints>
		<start_minimized>0</start_minimized>
		<on_transfer_request_style>2</on_transfer_request_style>
		<language>English</language>
		<last_run_version>2.39</last_run_version>
	</general>
	<general_additional/>
	<sip_options>
		<port>5060</port>
	</sip_options>
	<iax_options>
		<port>4569</port>
	</iax_options>
	<rtp_options>
		<port>8000</port>
		<session_name>Zoiper_session</session_name>
		<user_name>Zoiper_user</user_name>
		<url>www.zoiper.com</url>
		<email>support@zoiper.com</email>
	</rtp_options>
	<stun_options>
		<enable_stun>1</enable_stun>
		<stun_host>stun.zoiper.com</stun_host>
		<stun_port>3478</stun_port>
		<stun_refresh_period>30</stun_refresh_period>
	</stun_options>
	<audio>
		<input_device></input_device>
		<output_device></output_device>
		<ringing_device></ringing_device>
		<use_echo_cancellation>1</use_echo_cancellation>
		<ring_tone_file></ring_tone_file>
		<mic_boost>0</mic_boost>
		<pc_speaker_ring>0</pc_speaker_ring>
		<mute_on_early_media>0</mute_on_early_media>
		<ring_when_talking>1</ring_when_talking>
		<disable_dtmf_sounds>0</disable_dtmf_sounds>
		<use_alternate_timing>0</use_alternate_timing>
		<use_external_devices>0</use_external_devices>
		<auto_mic_selection>1</auto_mic_selection>
		<use_agc>1</use_agc>
		<use_noise_suppression>1</use_noise_suppression>
	</audio>
	<transfer>
		<park_extension>700</park_extension>
		<voicemail_prefix>mail</voicemail_prefix>
	</transfer>
	<diagnostics>
		<enable_debug_log>0</enable_debug_log>
		<enable_debug_audio>0</enable_debug_audio>
	</diagnostics>
	<fax>
		<fax_enabled>1</fax_enabled>
		<destination_folder></destination_folder>
		<custom_command></custom_command>
		<automatic_display>1</automatic_display>
		<automatic_print>0</automatic_print>
	</fax>
	<network>
		<signal_dscp>-1</signal_dscp>
		<media_dscp>-1</media_dscp>
	</network>  <accounts>
    <account>
      <tech>0</tech>
      <use_outbound_proxy>0</use_outbound_proxy>
      <name>$name</name>
      <host></host>
      <username>$number</username>
      <authentication_username></authentication_username>
      <password>$secret</password>
      <context>$SipDomain</context>
      <callerid>$number</callerid>
      <number>$number</number>
      <register_on_startup>1</register_on_startup>
      <do_not_play_ringback_tones>0</do_not_play_ringback_tones>
      <use_stun>1</use_stun>
      <stun_host></stun_host>
      <stun_port>3478</stun_port>
      <stun_refresh_period>30</stun_refresh_period>
      <custom_codecs>0</custom_codecs>
      <dtmf_style>0</dtmf_style>
      <reregistration_time>3600</reregistration_time>
      <subscribe_time>3600</subscribe_time>
      <use_rport>0</use_rport>
      <use_rport_media>0</use_rport_media>
      <mwi_subscribe_usage>3</mwi_subscribe_usage>
      <force_rfc3264>0</force_rfc3264>
    </account>
  </accounts>
  <codecs>
    <codec>
      <name>GSM</name>
      <codec_id>1</codec_id>
      <priority>1</priority>
      <selected>1</selected>
    </codec>
    <codec>
      <name>u-law</name>
      <codec_id>0</codec_id>
      <priority>2</priority>
      <selected>1</selected>
    </codec>
    <codec>
      <name>a-law</name>
      <codec_id>6</codec_id>
      <priority>3</priority>
      <selected>1</selected>
    </codec>
    <codec>
      <name>Speex</name>
      <codec_id>24</codec_id>
      <priority>4</priority>
      <selected>1</selected>
    </codec>
    <codec>
      <name>iLBC 30</name>
      <codec_id>27</codec_id>
      <priority>5</priority>
      <selected>1</selected>
    </codec>
    <codec>
      <name>iLBC 20</name>
      <codec_id>28</codec_id>
      <priority>6</priority>
      <selected>0</selected>
    </codec>
    <use_default_speex_settings>1</use_default_speex_settings>
    <enhance_decoding>1</enhance_decoding>
    <quality>4</quality>
    <bitrate>8</bitrate>
    <variable_bit_rate>0</variable_bit_rate>
    <average_bit_rate>0</average_bit_rate>
    <complexity>3</complexity>
  </codecs>
</options>
"@

# Append the XML code to zoiper.conf
$xmlCodeBytes = [System.Text.Encoding]::UTF8.GetBytes($xmlCode)
Set-Content -Path $zoiperConfPath -Value $xmlCodeBytes -Encoding Byte -Force
#write-Host $xmlCode
Write-Host "XML code appended to zoiper.conf file."

####################################### Open Zoiper #######################################################
Start-Sleep -Seconds 30
Start-Process "C:\Program Files (x86)\Attractel\Zoiper\Zoiper.exe"