{smcl}
{* *! version 1.0.0  28jun2021}{...}
{cmd:help download_transcripts}
{hline}

{title:Title}

{phang}
{bf:download_transcripts} {hline 2} Downloads all transcripts of interviews in a Survey Solutions survey


{title:Syntax}

	{cmd:download_transcripts ,} {opt qguid(string) [qversion(integer)] folder(string) susoapi(string)}


{title:Description}

{pstd}
{cmd:download_transcripts} downloads transcripts in PDF format corresponding to individual interviews in a Survey Solutions survey.
{p_end}

{pstd}
{cmd:download_transcripts} uses -susoapi- for API queries to obtain the list of existing interviews and iterate over the list, sequentially downloading each interview.
{p_end}


{title:Options}

{phang}
{opt qguid()} specifies the GUID of the survey questionnaire. You can find this GUID in the Survey Solutions Designer tool, or in the details of the questionnaire imported to the Survey Solutions data server, or by querieng the list of all imported questionnaires to the data server using the API client.
{p_end}

{phang}
{opt qversion()} specifies the version of the survey questionnaire. This is optional, and if not specified, value 1 is assumed. Note that the numbering of questionnaires in the  Survey Solutions data server may have occasional gaps if the corresponding versions are omitted. Thus version 1 may not necessarily exist for any given questionnaire.
{p_end}

{phang}
{opt folder()} specifies the folder where the transcripts will be saved. Within this specified folder a subfolder will be created with the GUID of the questionnaire and within it with the version. The individual transcript files will be named with a GUID corresponding to the interview number being transcripted.
{p_end}

{phang}
{opt susoapi()} specifies the name of the Survey Solutions client that will be used for the API calls.
{p_end}

{pstd}
Note: downloading all interview transcripts in PDF format imposes a considerable load on the server for a large survey. It is not recommended to be a daily operation, but an action at the end of the survey.
{p_end}

{title:Example}

******************************************************************
  clear all
  local out="C:/temp/transcripts"
  .client = .SuSo.new "https://your.server.address" "LoginAPI" "PasswordAPI"
  download_transcripts, susoapi(client) folder("`out'") qguid("55d7deda-24e1-48cc-85a0-47b895c8bf40") qversion(4)
******************************************************************

{pstd}
Downloads transcripts of all interviews in version 4 of the survey with questionnaire ID "55d7deda-24e1-48cc-85a0-47b895c8bf40" from server "https://your.server.address" using the API user account "LoginAPI" and password "PasswordAPI". The downloaded files are saved as *.PDF documents into the folder "C:/temp/transcripts/55d7deda-24e1-48cc-85a0-47b895c8bf40/4". The files are named with the GUIDs of the individual interviews.
{p_end}

{title:Author}

{pstd}Sergiy Radyakin{p_end}
{pstd}sradyakin(a)worldbank.org{p_end}
