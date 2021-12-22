
program define download_transcripts

    version 16.0
    
    syntax , qguid(string) [qversion(integer 1)] folder(string) susoapi(string)
    
    quietly pwf
    local cf=r(currentframe)
    
    tempname fff
    .`susoapi'.qx_interviews , qguid("`qguid'") qversion (`qversion') frame(`fff')
    frame change `fff'

    display as text " {break}"
    display as text "Processing " as result `=_N' as text " interviews.{break}"
    forval i=1/`=_N' {
        local guid = `'"`=interview__id[`i']'"'
        display as text "Downloading[`i']: {result:`guid'}"
        
        capture mkdir "`folder'/`qguid'"
        capture mkdir "`folder'/`qguid'/`qversion'"
        .`susoapi'.interviews_getpdf "`guid'" "`folder'/`qguid'/`qversion'/`guid'.pdf"
    }
    display as text " {break}"    
    display as text "Done!{break}"
    
    frame change `cf'
    frame drop `fff'
end

