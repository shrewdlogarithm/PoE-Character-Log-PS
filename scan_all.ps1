. "$PSScriptRoot/charparser.ps1"

$getcookie = Invoke-WebRequest 'https://www.pathofexile.com/' -SessionVariable 'Session' 
[string]$BaseUri     = "https://api.pathofexile.com"
[string]$ContentType = "application/json"
$Headers=@{}

# these are default settings - run this script then edit settings.json file to customize
$settings = @{
    accounts = @("account1","account2")
    shortsleep = 1
    longsleep = 180
}

$settfile = "$PSScriptRoot/settings.json"
$accdbfile = "$PSScriptRoot/accountdb.json"

function wait ($time) {
    "Waiting " + $time + " seconds"
    sleep $time
}

$PSDefaultParameterValues = @{'Out-File:Encoding' = 'utf8'}

:forever while ($true) {    
    if (Test-Path $settfile) {
        $settings = Get-Content $settfile | Out-String | ConvertFrom-Json
    } else {
        $settings | ConvertTo-Json -Depth 10 | Set-Content "$settfile" -Encoding utf8
    }

    $accountdb = New-Object PSObject
    if (Test-Path $accdbfile) {
        $accountdb = Get-Content $accdbfile | Out-String | ConvertFrom-Json
    }

    $POEChars = @()

    ForEach ($account in $settings.accounts) {
        "Scanning Account $account"
        try {
            $apichars = Invoke-RestMethod -URI "$BaseURI/character-window/get-characters?accountName=$account&realm=pc" -Headers $Headers -ContentType $ContentType -Method Get -websession $session -ErrorVariable errVar 
            $newchars = New-Object PSObject 
            ForEach ($apichar in $apichars) {
                $newchars | Add-Member -NotePropertyName $apichar.name -NotePropertyValue $apichar
            }
            if(Get-Member -inputobject $accountdb -name "$account") {
                ForEach ($apichar in $apichars) {                
                    if (Get-Member -inputobject $accountdb.$account -name ($apichar.name)) {
                        if ($accountdb.$account.($apichar.name).experience -ne $apichar.experience) {
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
                $accountdb.$account = $newchars
            } else {
                $accountdb | Add-Member -NotePropertyName $account -NotePropertyValue $newchars
            }
        } catch {
            "PoE Site unavailable or Account/Character invalid"
        }

        wait($settings.shortsleep)
    }

    ForEach ($POEChar in $POEChars) {

        $scantime = Get-Date
        
        $POEAccount = $POEChar.account
        $POEName = $POEChar.char
        
        $DBName = "$PSScriptRoot/data/$POEaccount-$POEName.json"

        "Scanning $POEAccount-$POEName..."

        try {
            $Form = @{
                accountName=$POEaccount
                character=$POEName
            }
            $items = Invoke-RestMethod -URI "$BaseURI/character-window/get-items" -Headers $Headers -Body $Form -ContentType $ContentType -Method Get -websession $session -ErrorVariable errVar
    
            $passives = Invoke-RestMethod -URI "$BaseURI/character-window/get-passive-skills?reqData=0&accountName=$POEaccount&realm=pc&character=$POEName" -Headers $Headers -ContentType $ContentType -Method Get -websession $session -ErrorVariable errVar

            $chardata = @(
                @{
                    update=$scantime
                    character=@{}
                    items=@()
                    passives=@()
                }
            )

            If (Test-Path "$DBName") {
                $chardata = Get-Content "$DBName" | Out-String | ConvertFrom-Json
            }    

            $chardata += @{
                update = $scantime
                character = $items.character
                items = $items.items
                passives = $passives.hashes
            }
            
            $chardata | ConvertTo-Json -Depth 10 | Set-Content "$DBname"  -Encoding utf8 

            "Checking $POEAccount-$POEName..."
            if ($chardata.length -gt 1) {
                makelogs $chardata[$chardata.length-2] $chardata[$chardata.length-1] | Tee-Object -FilePath "$PSScriptRoot/logs/$POEaccount-$POEName.log" -append 
                makexml $chardata "$PSScriptRoot/pob/builds/$POEaccount-$POEName.xml"
            }
        
        } catch {
            "PoE Site unavailable or Account/Character invalid"
            wait($settings.longsleep)
        }

        wait($settings.shortsleep)
    }

    $accountdb | ConvertTo-Json -Depth 10 | Set-Content "$accdbfile" -Encoding utf8
    
    wait($settings.longsleep)
}