program define suso_datetime, rclass

  version 16.0
  syntax , date(string) [time(string)]
  
  // assume date as YYYY-MM-DD
  // assume time as hh:mm:ss or hh:mm:ss.sss
  
  local d=date("`date'","YMD")
  if (missing(`d')) {
    display as error "Invalid date"
	error 117
  }
  local ds = string(`d', "%tdCCYY-NN-DD")

  if missing(`"`time'"') local time="00:00:00.000"
  local ts=string(clock(`"`ds' `time'"',"YMDhms"), "%tcCCYY-NN-DD!THH:MM:SS.sss!Z")
  
  if (`"`ts'"'==".") {
    display as error "Invalid time"
	error 117
  }

  return local ctimestamp = `"`ts'"'
end

// END OF FILE
