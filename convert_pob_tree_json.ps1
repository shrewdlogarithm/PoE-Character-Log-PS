# This converts POB's tree.lua into a workable JSON - it's a massive kludge but it works
# It assumes you've installed a full POB into the pob subdir - or at least the tree file!

$POBTREEVER = "3_14"

$POBFile = "$PSScriptRoot/pob/treedata/" + $POBTREEVER + "/tree.lua"

$luadata = Get-Content $POBFile -raw

$luadata = $luadata -replace "^return\w*" , ""
$luadata = $luadata -replace '\["*([^"]*)"*\]\w*=' , '"$1":'
$luadata = $luadata -replace '[^"]:' , ''
$luadata = $luadata -replace '(?ms){([^:]*?)}' , '[$1]'
$luadata = $luadata -replace '(?ms),[^"]*"groups":.*' , '}'

$luadata | Set-Content "$PSScriptRoot/passive-skill-tree.json"

# TEST $jsondata = Get-Content "$PSScriptRoot/passive-skill-tree.json" | Out-String | ConvertFrom-Json 
