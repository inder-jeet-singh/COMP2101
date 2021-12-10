get-ciminstance win32_networkadapterconfiguration |
where-object {$_.ipenabled -eq $true} |
format-table Index , Description, DNSDomain, DNSServerSearchOrder,IPAddress -AutoSize