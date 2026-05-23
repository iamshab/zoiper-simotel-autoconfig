# Zoiper4 Auto Config From Active Directory And [Simotel](https://simotel.com) PBX

This PowerShell script make Zoiper (version 4) softphone config automatic for Windows users.

It read current Windows username, find user phone number from Active Directory, then search this number in Simotel API. After that it create Zoiper config file and add SIP account information inside it.

This can help when you have many users and you don't want to configure Zoiper one by one manual and instead add it via GPO at log on.

## What this script do

- Get current Windows username
- Search user in Active Directory
- Read phone number from AD user attribute
- Search same phone number in Simotel API
- Get SIP name, number and secret from Simotel
- Create Zoiper config folders if not exist
- Write `zoiper.conf`
- Start Zoiper after config is ready

## Requirements

- Windows
- PowerShell
- Zoiper installed
- User must be joined to Active Directory domain
- User must have phone number in Active Directory
- Access to Simotel API
- Simotel API key and Basic Auth value
- gpmc.msc (in case of publish script as a log on script for bulk)

## Config

Before running the script, edit config part in top of script.

```powershell
$SimotelApiUrl = "https://simoteldomain.example.com/api/v4/pbx/users/search"
$SimotelBasicAuth = "Basic REPLACE_WITH_BASE64_BASIC_AUTH"
$SimotelApiKey = "REPLACE_WITH_SIMOTEL_API_KEY"
$SipDomain = "simotel.example.com"
$AdPhoneAttribute = "telephoneNumber"
```

## How to use

Clone or download this repo.

Edit the script and change config values:

```powershell
$SimotelApiUrl = "https://your-simotel-domain/api/v4/pbx/users/search"
$SimotelBasicAuth = "Basic YOUR_BASE64_AUTH"
$SimotelApiKey = "YOUR_API_KEY"
$SipDomain = "your-sip-domain"
$AdPhoneAttribute = "telephoneNumber"
```

Then run PowerShell and execute on target PC or add it as a log on GPO for bulk execution:

```powershell
.\Configure-Zoiper.ps1
```

If Windows block script execution, you can run:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Configure-Zoiper.ps1
```

## Notes

This script is just a template.

You may need to change some parts based on your own company infra, like:

- AD attribute name
- Simotel API URL
- SIP domain
- Zoiper install path
- Codec settings
- Transfer settings
- Voicemail prefix

Test it with one user first before using for many users.