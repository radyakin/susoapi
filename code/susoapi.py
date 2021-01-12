import requests
import time
from sfi import Macro
from sfi import SFIToolkit


def checkurl(url):
  try:
    r = requests.get(url)
  except requests.ConnectionError as e:
    # Handle exception here
    Macro.setLocal("downloaded",str(-631))
    return -631
  return 0

def checkserver(server):
  try:
    r = requests.get(server + "/.hc")
    if (r.status_code==404):
      Macro.setLocal("downloaded",str(-10404))
      return -10404
  except requests.ConnectionError as e:
    # Handle exception here
    Macro.setLocal("downloaded",str(-631))
    return -631
  return 0
  
def checkapi(server,apiname,apipass):
  headers = {'Content-type': 'application/json'}
  credentials=(apiname,apipass)
  print(server)
  y=requests.get(
      server+"/api/v1/settings/globalnotice/",
      headers=headers, 
      data={},
      auth=credentials)
  print(y.json()['Message'])
  return 0
  
def check(server, apiname, apipass):
  if (checkurl(server) < 0):
    return -1
  if (checkserver(server) < 0):
    return -1
  if (checkapi(server,apiname,apipass) < 0):
    return -1
  print("Server OK")
  return 0

def export(server,apiname,apipass):
  # returns number of bytes in the saved file or a negative code if failed

  if (check(server, apiname, apipass) < 0):
    return
  
  const_delay=0.2
  const_maxcycles=180

  qry=Macro.getLocal("qry")
  saveto=Macro.getLocal("saveto")
  URL=server+'/api/v2/export/'
  headers = {'Content-type': 'application/json'}
  credentials=(apiname,apipass)

  x = requests.post(
    URL,
    data=qry,
    headers=headers,
    auth=credentials)
  
  if (x.ok):
    code=x.status_code
    jobid=x.json()['JobId']
    print('Set up new export job with ID:', jobid)
    y=requests.get(
      URL+str(jobid),
      headers=headers, 
      data={},
      auth=credentials)
    if (y.ok):
      c=1
      exportStatus=y.json()['ExportStatus']
      while((exportStatus!='Completed') and (c<const_maxcycles)):
        c=c+1
        print(exportStatus, y.json()['Progress'],"%")
        time.sleep(const_delay)
        y=requests.get(
          URL+str(jobid),
          headers=headers, 
          data={},
          auth=credentials)
        exportStatus=y.json()['ExportStatus']

    if (not y.json()['HasExportFile']):
      print("Something went wrong! The export job has been completed, but the export file was not produced by the server.")
      Macro.setLocal("downloaded",str(-1))
      return

    links=y.json()['Links']
    file=links['Download']
    
    filedata = requests.get(file, auth=credentials, allow_redirects=True)
    with open(saveto, 'wb') as file:
      file.write(filedata.content)
    Macro.setLocal("downloaded",str(len(filedata.content)))
  else:
    print(x.status_code)
    if (x.status_code==401):
      SFIToolkit.errprint("Server responded: 401 Unauthorized.")
      SFIToolkit.errprintln("Please check that the API user name and password are valid for this server.")
      Macro.setLocal("downloaded",str(-401))
      return
    if (x.status_code==404):
      SFIToolkit.errprint("Server responded: 404 Not found.")
      SFIToolkit.errprintln("Please check that the requested survey questionnaire was imported to this server.")
      Macro.setLocal("downloaded",str(-404))
      return
    Macro.setLocal("downloaded",str(-1))

# END OF FILE