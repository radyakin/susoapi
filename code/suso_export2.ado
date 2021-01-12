// # Get export using Survey Solutions V2 API
// # Sergiy Radyakin, 2020-2021
// # Note: as per API specification in 
// #       Survey Solutions v20.12 (build 29959)

// # Handles the following erroneous situations:
// # - server address misspecified: (631 host not found)
// # - invalid credentials (unauthorized access);
// # - incorrect specification of the target (survey questionnaire, translation)
// # - mutually exclusive options specified together.


program define suso_export2

  version 16.0

  syntax , server(string) qid(string) ///
           apiname(string) apipass(string) ///
           saveto(string) [replace] ///
           [ translationid(string) includemeta ///
           status(string) exporttype(string) ///
           from(string) to(string) ]

           // # timestamp is expected in the following format:
           // # "2021-01-02T19:23:43.375Z"

  capture confirm new file `"`saveto'"'
  if _rc {
    // check if can delete the existing file
    if (`"`replace'"'!="") {
      erase `"`saveto'"'
      capture noisily confirm new file `"`saveto'"'
    }
    if (_rc) {
      display as error "Error! Cannot save to `saveto' !"
      error 691
    }
  }
  
  if (`"`server'"'=="") {
    display as error "Error! Server name may not be empty!"
    error 101
  }

  if (`"`qid'"'=="") {
    display as error "Error! Questionnaire identity may not be empty!"
    error 101
  }

  local t=strpos(`"`macval(qid)'"',`"`=char(36)'"')

  if (`t'==0 | `t'==strlen(`"`macval(qid)'"')) {
    display as error "Error! Questionnaire identity must include the version!"
    error 101
  }

  if (`"`translationid'"'=="") {
    display as result ///
	"Warning! Translation ID not specified.{break}Downloading in the default language!"
  }

  local includemeta=cond(`"`includemeta'"'=="","false","true") 

  if missing(`"`status'"') local status="All"
  if (!inlist(`"`status'"', ///
    "All", "InterviewerAssigned", "Completed", ///
	"ApprovedBySupervisor", "ApprovedByHeadquarters")) {
    display as error `"Error! Invalid filter by status: `status'"'
    error 101
  }

  if missing(`"`exporttype'"') local exporttype="STATA"
  if (!inlist(`"`exporttype'"', ///
    "Tabular", "STATA", "SPSS", "Binary", "DDI", "Paradata")) {
    display as error `"Error! Invalid data export type: `exporttype'"'
    error 101
  }
  
  if (`"`includemeta'"'=="true" & inlist("`exporttype'", "Binary", "DDI", "Paradata")) {
    display as error `"Error! Questionnaire metadata is not available in this format: `exporttype'"'
    error 198
  }
  
  if ((missing(`"`from'"') & !missing(`"`to'"')) | ///
     (!missing(`"`from'"') & missing(`"`to'"'))) {
    display as error ///
	`"Error! Either both or none of the options from() and to() must be specified!"'
    error 198
  }
  else {
    local datefilter=`", "From": "`from'", "To": "`to'" "'
    // # must start with a comma, must not end with a comma
  }

  local qry = `" { "ExportType": "`exporttype'", "QuestionnaireId": "`qid'", "TranslationId": "`translationid'", "InterviewStatus": "`status'" `datefilter', "IncludeMeta":"`includemeta'" } "'
  
  local downloaded=0
  
  capture noisily python : doexportdata("`server'","`apiname'","`apipass'")
  
  if (_rc==7102) {
    display as error ///
    `"Error! Could not place an export job. Most likely incorrect address of the server: `server'"'
    error 601
  }
  
  if (`downloaded'==22) {
    display as result "Warning! Empty downloaded an empty file."
  }
  
  if (`downloaded'==-401) {
    error 673
  }
  
  if (`downloaded'==-631) {
    error 631
  }
  
  if (`downloaded'==-10404) {
    display as error "Not a Survey Solutions server!"
    error 601
  }
  
  if (`downloaded'<0) {
    display as error "Error! Could not export data!"
    error 601
  }
  
  display as text `"file `saveto' saved (`=string(`downloaded',"%20.0gc")' bytes)"'
end


version 16
python:

import susoapi

def doexportdata(server, apiname, apipass):
   susoapi.export(server, apiname, apipass)
end

// END OF FILE