. "$PSScriptRoot/charparser.ps1"

$PSDefaultParameterValues = @{'Out-File:Encoding' = 'utf8'}

Get-ChildItem "$PSScriptRoot/data" -Filter *.json | Foreach-Object {
    $accchar = $_.Name -replace ".json",""

    if ($accchar -ne "accountdb") {
        $DBName = "$PSScriptRoot/data/$accchar.json"
        $LogName = "$PSScriptRoot/logs/$accchar.log"
        $XMName = "$PSScriptRoot/pob/builds/$accchar.xml"
        If (Test-Path "$DBName") {
            $jsondata = Get-Content -Raw -Path "$DBName" | ConvertFrom-Json
            if (Test-Path "$LogName") {
                Remove-Item -Path $LogName
            }
            For ($e = 1;$e -lt $jsondata.length; $e++) {
                checkchanges $jsondata[$e-1] $jsondata[$e] | Tee-Object -FilePath $LogName -append
            }
            makexml $jsondata $XMName
        }
    }
}