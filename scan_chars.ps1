. "$PSScriptRoot/webapi.ps1"
. "$PSScriptRoot/charparser.ps1"

$PSDefaultParameterValues = @{'Out-File:Encoding' = 'utf8'}

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
                items=@{}
                passives=@{}
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
            checkchanges $chardata[$chardata.length-2] $chardata[$chardata.length-1] | Tee-Object -FilePath "$PSScriptRoot/data/$POEaccount-$POEName.log" -append 
            makexml $chardata "$PSScriptRoot/data/$POEaccount-$POEName.xml"
        }
    
    } catch {
        "PoE Site unavailable or Account/Character invalid"
    }

}
