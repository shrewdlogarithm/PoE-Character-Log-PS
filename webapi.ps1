$getcookie = Invoke-WebRequest 'https://www.pathofexile.com/' -SessionVariable 'Session' 
[string]$BaseUri     = "https://api.pathofexile.com"
[string]$ContentType = "application/json"
$Headers=@{}
