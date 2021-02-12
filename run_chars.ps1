$POEChars = @( 
    @{
        account = "ohnpeat"
        char = "ohnonotspin"
    }    
)

:forever while ($true) {
    . "$PSScriptRoot/scan_chars.ps1"
    sleep 60
}