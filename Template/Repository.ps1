###################################################################
# Sofware repository info install/uninstall script for
# DeploymentTool
#
# Author: Andrew Levin
# Version: 1.0
#
# Last modification: 13.10.2011
#
###################################################################

$action = $args[0]
$hivename = $args[1]
$package = $args[2]
$productname = $args[3]
$manufacturer = $args[4]

$software = "HKLM:\Software\"
$instdate = Get-Date -Format "dd-MM-yyyy"
$insttime = Get-Date -Format "HH:mm:ss"
if($hivename -and $package){
	$hive = $software + $hivename + "\"
	$pkghive = $hive + $package + "\"
	if($action -eq "Install"){
		if(!(Test-Path $hive)){
			New-Item $hive -Force | Out-Null
		}
		if(!(Test-Path $pkghive)){
			New-Item $pkghive -Force | Out-Null
			New-ItemProperty -path $pkghive -name PkgCode -propertyType String -value $package | Out-Null
			New-ItemProperty -path $pkghive -name Product -propertyType String -value $productname | Out-Null
			New-ItemProperty -path $pkghive -name Manufacturer -propertyType String -value $manufacturer | Out-Null
			New-ItemProperty -path $pkghive -name Date -propertyType String -value $instdate | Out-Null
			New-ItemProperty -path $pkghive -name Time -propertyType String -value $insttime | Out-Null
		}
		else{
			Set-ItemProperty -path $pkghive -name PkgCode -propertyType String -value $package | Out-Null
			Set-ItemProperty -path $pkghive -name Product -propertyType String -value $productname | Out-Null
			Set-ItemProperty -path $pkghive -name Manufacturer -propertyType String -value $manufacturer | Out-Null
			Set-ItemProperty -path $pkghive -name Date -propertyType String -value $instdate | Out-Null
			Set-ItemProperty -path $pkghive -name Time -propertyType String -value $insttime | Out-Null
		}
	}
	elseif($action -eq "Uninstall"){
		if(Test-Path $pkghive){
			Remove-Item $pkghive -Recurse -Force | Out-Null
		}
		if(!(Get-ChildItem $hive)){
			Remove-Item $hive -Recurse -Force | Out-Null
		}
	}
}