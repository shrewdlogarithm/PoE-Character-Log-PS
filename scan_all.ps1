. "$PSScriptRoot/charparser.ps1"

$getcookie = Invoke-WebRequest 'https://www.pathofexile.com/' -SessionVariable 'Session' 
[string]$BaseUri     = "https://www.pathofexile.com"
[string]$ContentType = "application/json"
$Headers=@{}

# these are default settings - run this script then edit settings.json file to customize
$settings = @{
    accounts = @("account1","account2")
    shortsleep = 5
    longsleep = 90
}

$settfile = "$PSScriptRoot/settings.json"
$accdbfile = "$PSScriptRoot/accountdb.json"

function wait ($time) {
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


    ForEach ($account in $settings.accounts) {

        "Scanning Account $account"
        $POEChars = @()
    
        try {
            $apichars = Invoke-RestMethod -URI "$BaseURI/character-window/get-characters?accountName=$account&realm=pc" -Headers $Headers -ContentType $ContentType -Method Get -websession $session -ErrorVariable errVar 
            if(Get-Member -inputobject $accountdb -name "$account") {
            } else {
                $accountdb | Add-Member -NotePropertyName $account -NotePropertyValue (New-Object PSObject) 
            }
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
                    $accountdb.$account | Add-Member -NotePropertyName $apichar.name -NotePropertyValue $apichar
                    $account + " - " + $apichar.name + " (" + $apichar.level + ") is new"
                    $POEChars += @{
                        account = $account
                        char = $apichar.name
                    }
                }
            } 

            ForEach ($POEChar in $POEChars) {

                $scantime = Get-Date
                
                $POEAccount = $POEChar.account
                $POEName = $POEChar.char
                
                $DBName = "$PSScriptRoot/data/$POEaccount-$POEName.json"

                "Scanning $POEAccount-$POEName..."

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

                wait($settings.shortsleep)
                
            }

            $accountdb | ConvertTo-Json -Depth 10 | Set-Content "$accdbfile" -Encoding utf8
    
        } catch {
            "PoE Site unavailable or Account/Character invalid"
            wait($settings.longsleep)
        }

        wait($settings.shortsleep)
    }

    wait($settings.longsleep)
}