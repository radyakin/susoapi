// Test suso_datetime() function

clear all

suso_datetime, date("20210720")
ret list
assert r(ctimestamp)=="2021-07-20T00:00:00.000Z"

suso_datetime, date("20211102")
ret list
assert r(ctimestamp)=="2021-11-02T00:00:00.000Z"

suso_datetime, date("2021feb20") time("13:05:59")
assert r(ctimestamp)=="2021-02-20T13:05:59.000Z"

suso_datetime, date("2023dec25") time("01:02:03.456")
assert r(ctimestamp)=="2023-12-25T01:02:03.456Z"

capture noisily suso_datetime, date("2023dec35") time("01:02:03.456")
assert _rc==117
capture noisily suso_datetime, date("2023ddd01") time("01:02:03.456")
assert _rc==117
capture noisily suso_datetime, date("20.23dec31") time("01:02:03.456")
assert _rc==117

capture noisily suso_datetime, date("2023dec31") time("31:02:03.456")
assert _rc==117
capture noisily suso_datetime, date("2023dec31") time("01:72:03.456")
assert _rc==117
capture noisily suso_datetime, date("2023dec31") time("01:02:73.456")
assert _rc==117

display "OK: All tests have passed!"

// END OF FILE