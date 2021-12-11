param ( 

  [switch]$Disks, 
  [switch]$Network , 
  [switch]$System
  
)

if ($System -eq $true) {

  echoIt-hwdata
  echoIt-osData
  echoIt-cpuData
  echoIt-ramData
  echoIt-graphicData
  
}
if ($Disks -eq $true) {

  echoIt-diskData

}
if ($Network -eq $true) {

  echoIt-networkConfig

}
if ( !($System) -and !($Disks) -and !($Network)) {

  echoIt-hwdata
  echoIt-osData
  echoIt-cpuData
  echoIt-ramData
  echoIt-diskData
  echoIt-networkConfig
  echoIt-graphicData

}

