Get-WmiObject Win32_Printer  | where{ $_.Network -eq "true" } | foreach-object{ $_.delete() }
