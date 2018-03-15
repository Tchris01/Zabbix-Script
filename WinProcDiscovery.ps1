# Name getprocWin.ps1
# This will output specific details for Win Process
$i = 0

$process = Get-process

write-host "{"
write-host " `"data`":["
write-host 

if ($process -eq $null) {write-host "]}" }

foreach ( $proc in $process )
 {
 if (($i -eq $process.Count - 1) -or ( $process.Count -eq $null )) 
  {
   $line =  " { `"{#PROCNAME}`":`"" + $proc.ProcessName + "`" }]}"
  }
 else
  {
   $line =  " { `"{#PROCNAME}`":`"" + $proc.ProcessName + "`" },"
  }
 write-host $line
 $i = $i + 1
 }
