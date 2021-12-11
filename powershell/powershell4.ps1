# Functoin to show hardware data
function echoIt-hwdata {
    write "---- Hardware ---- "
    
    $hardware = gcim win32_computersystem
    $hardware | fl name, model, Manufacturer, Description
  }
  # Function to show OS data
  function echoIt-osData {
    write " OS DATA "
  
    $osInformation = gcim win32_operatingsystem | select Name, Version 
    $osInformation |  fl
  }
  
  # Function to show processor data
  function echoIt-cpuData {
    write "---- Processor ----"
  
    $processor = gcim win32_processor | 
    select name, currentclockSpeed, maxclockspeed, numberofcores, 
    @{  n = "L1CacheSize"; e = { 
        switch ($_.L1CacheSize) {
          $null { $valueData = "Data Unavailable" }
          Default { $valueData = $_.L1CacheSize }
        };
        $valueData }
    },
    L2CacheSize, L3CacheSize  
    $processor | fl
  }
  
  # Function to show ram data
  function echoIt-ramData {
    write "---- Primary Memory ----"
  
    $totalram = 0
    $ramObject = Get-WmiObject win32_physicalmemory |
    ForEach-Object {
      $ramStick = $_ ;
      New-Object -TypeName psObject -Property @{
        Manufacturer = $ramStick.Manufacturer
        Slot         = $ramStick.devicelocator
        "Size(GB)"   = $ramStick.Capacity / 1gb
        Bank         = $ramStick.banklabel
        Description  = $ramStick.Description
      }
      $totalram += $ramStick.Capacity
    }
    $ramObject | ft manufacturer, description, "Size(GB)", Bank, Slot -AutoSize
    write "Total RAM Capacity = $($totalram/1gb) GB"
  }
  # Function to show disk data
  function echoIt-diskData {
    write "---- Disk Drives ----"
  
    $disks = gcim CIM_diskdrive | Where-Object DeviceID -ne $null
    foreach ($thisdisk in $disks) {
      $everyPartitions = $thisdisk | Get-CIMAssociatedInstance -resultclassname CIM_diskpartition
      foreach ($partition in $everyPartitions) {
        $everyLogicalDisk = $partition | Get-CIMAssociatedInstance -resultclassname CIM_logicaldisk
        foreach ($logicalDisk in $everyLogicalDisk) {
          new-object -typename psobject -property @{
            Model                   = $thisdisk.Model
            Drive                   = $logicalDisk.deviceid
            Location                = $partition.deviceid
            Manufacturer            = $thisdisk.Manufacturer
            "Size(GB)"              = [string]($logicalDisk.size / 1gb -as [int]) + 'GB'
            FreeSpace               = [string]($logicalDisk.FreeSpace / 1gb -as [int]) + 'GB'
            "FreeSpace(Percentage)" = ([string]((($logicalDisk.FreeSpace / $logicalDisk.Size) * 100) -as [int]) + '%')
          } | ft -AutoSize
        } 
      }
    }   
  }
  # Function to show network data
  function echoIt-networkConfig {
    write "---- Network Configuration ----"
  
    $networkInfo = gcim win32_networkadapterconfiguration | Where-Object { $_.ipenabled -eq 'True' } | 
    select Index, Description, 
    @{  n = 'Subnet'; e = {
        switch ($_.Subnet) {
          $null { $valueData = 'Data Unavailable' }
          Default { $valueData = $_.Subnet }
        };
        $valueData
      }
    },
    @{  n = 'DNSDomain'; e = {
        switch ($_.DNSDomain) {
          $null { $valueData = 'Data Unavailable' }
          Default { $valueData = $_.DNSDomain }
        };
        $valueData
      }
    }, 
    DNSServerSearchOrder, IPAddress
    $networkInfo | ft Index, Description, Subnet, DNSDomain, DNSserversearchorder, IPaddress
  }
  # Function to show graphics data
  function echoIt-graphicData {
    write "---- Graphics ----"
  
    $graphixData = Get-WmiObject win32_videocontroller
    $graphixData = New-Object -TypeName psObject -Property @{
      Name        = $graphixData.Name
      Description = $graphixData.Description
      Resolution  = [string]($graphixData.CurrentHorizontalResolution) + 'px * ' + [string]($graphixData.CurrentVerticalResolution) + 'px'
    } 
    
    $graphixData | fl Name, Description, Resolution
  }
    
    
  echoIt-hwdata
  echoIt-osData
  echoIt-cpuData
  echoIt-ramData
  echoIt-diskData
  echoIt-networkConfig
  echoIt-graphicData