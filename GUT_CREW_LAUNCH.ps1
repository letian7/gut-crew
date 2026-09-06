$Game='C:\Users\EDY\Desktop\GUT_CREW_V2\gut_crew_v2'
$Node='C:\Program Files\nodejs\node.exe'
$Url='http://127.0.0.1:8080/'
$Log='C:\Users\EDY\Desktop\GUT_CREW_launcher.log'
function Healthy { try { $r=Invoke-WebRequest -UseBasicParsing -TimeoutSec 1 $Url -ErrorAction Stop; return $r.StatusCode -eq 200 } catch { return $false } }
Add-Content $Log ((Get-Date -Format s)+' launcher start')
if(-not (Healthy)) {
  $listeners=@(Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue)
  $listeners | Select-Object -ExpandProperty OwningProcess -Unique | ForEach-Object { Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue }
  Start-Sleep -Milliseconds 150
  if((Test-Path $Node) -and (Test-Path $Game)){$p=Start-Process -FilePath $Node -ArgumentList 'server.js' -WorkingDirectory $Game -WindowStyle Hidden -PassThru;Add-Content $Log ((Get-Date -Format s)+' server pid='+$p.Id)}
  for($i=0;$i -lt 15 -and -not (Healthy);$i++){Start-Sleep -Milliseconds 200}
}
$ok=Healthy;Add-Content $Log ((Get-Date -Format s)+' healthy='+$ok)
if($ok){Start-Process 'http://localhost:8080/index3d.html?build=gameplay-lock'}
else{Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('GUT CREW 服务器启动失败，请查看桌面 GUT_CREW_launcher.log')|Out-Null}