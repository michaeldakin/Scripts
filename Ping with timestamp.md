ping.exe -t <IP> | Foreach {"{0} - {1}" -f (Get-Date),$\_}
