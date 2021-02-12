$accounts = @(
    "mathil","zizaran","bigducks","lighty","cutedog_","yojimoji","steelmage","raizqt","ghazzy","thisisbadger","notscarytime","donthecrown"
)    

:forever while ($true) {
    . "$PSScriptRoot/scan_accounts.ps1"
    . "$PSScriptRoot/scan_chars.ps1"
    sleep 60
}