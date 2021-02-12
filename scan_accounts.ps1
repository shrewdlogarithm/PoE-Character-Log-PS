. "$PSScriptRoot/webapi.ps1"

$lastdb = "$PSScriptRoot/data/accountdb.json"
$lastchars = New-Object PSObject
if (Test-Path $lastdb) {
    $lastchars = Get-Content $lastdb | Out-String | ConvertFrom-Json
}

$POEChars = @()

ForEach ($account in $accounts) {
    try {
        $apichars = Invoke-RestMethod -URI "$BaseURI/character-window/get-characters?accountName=$account&realm=pc" -Headers $Headers -ContentType $ContentType -Method Get -websession $session -ErrorVariable errVar 
        try {
            $newchars = New-Object PSObject 
            ForEach ($apichar in $apichars) {
                $newchars | Add-Member -NotePropertyName $apichar.name -NotePropertyValue $apichar
            }
            if(Get-Member -inputobject $lastchars -name "$account") {
                ForEach ($apichar in $apichars) {                
                    if (Get-Member -inputobject $lastchars.$account -name ($apichar.name)) {
                        if ($lastchars.$account.($apichar.name).experience -ne $apichar.experience) {
                            $account + " - " + $apichar.name + " (" + $apichar.level + ") has gained experience"
                            $POEChars +=  @{
                                account = $account
                                char = $apichar.name
                            }
                        }
                    } else {
                        $account + " - " + $apichar.name + " (" + $apichar.level + ") is new"
                            $POEChars += @{
                                account = $account
                                char = $apichar.name
                            }
                    }
                } 
                $lastchars.$account = $newchars
           } else {
                $lastchars | Add-Member -NotePropertyName $account -NotePropertyValue $newchars
           }
        } catch {
            "Help?"
        }
    } catch {
        "PoE Site unavailable or Account/Character invalid"
    }
}

$lastchars | ConvertTo-Json -Depth 10 | Set-Content "$lastdb" -Encoding utf8