######################################################################
# Main script for installing/uninstalling/reinstalling packages
# This script is a part of deployment tool
#
# Author: Andrew Levin
# File name: sysupd.ps1
# Version: 1.0
# Last modification: 13.10.2011
#
######################################################################
$ver="1.0"
$ProgramName="DeploymentTool"

$executingScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$dt = Get-Date -Format "yyyy-MM-dd"
$softhive = "HKLM:\Software\"

#software update
function updateSoftware{
	if(!(Test-Path $cachefolder)){
		New-Item -ItemType directory $cachefolder -Force | out-null
	}
	#Share connect
	$instsrv = $xmlconfig.deploymenttool.repos.share.srvaddress
	$slocation = "\\" + $configsrv + "\" + $xmlconfig.deploymenttool.repos.share.srvlocation
	$slogin = $xmlconfig.deploymenttool.repos.share.login
	$spassword = $xmlconfig.deploymenttool.repos.share.password
	
	if(!(shareConnect $instsrv $slocation $slogin $spassword)){
		write-log "Program stopped."
		break
	}
	#End of share connect
	
	#Copying packages to local cache
	$packagelist = Get-ChildItem $slocation
	foreach($item in $installlistlocal){
		try{
			$itemval = $item.toString()
			foreach($pkg in $packagelist){
				if($pkg -like "*$itemval"){
					$pkgpath = $slocation + "\" + $pkg
					if(Test-Path $pkgpath){
						Copy-Item $pkgpath -Recurse -Destination $cachefolder -Force
					}
					else {
						$errmsg = "Error: " + $path + " - not found!"
						write-log $errmsg "error"
					}
				}
			}
		} catch {}
	}
	#End of copying
	
	$cachedpks = Get-ChildItem $cachefolder
	#Uninstallation
	foreach($item in $uninstalllist){
		try{
			$itemval = $item.toString()
			$done = $false
			if($cachedpks){
				foreach($pkg in $cachedpks){
					if($pkg -like "*$itemval"){
						$uncmd = $cachefolder + "\" + $pkg + "\Uninstall.cmd"
						executeCMD $uncmd
						if(($LASTEXITCODE -eq 0) -or ($LASTEXITCODE -eq 3010)){
							$done = $true
							$msg = "Uninstallation of $pkg completed succesfully.(Locally cached)"
							Write-log $msg
						}
						else {
							$errmsg = "Uninstallation of $pkg was not completed succesfully.(Locally cached)"
							Write-log $errmsg "warning"
						}
						Remove-Item $cachefolder\$pkg -Recurse -Force
					}
				}
			}
			if(!$done){
				foreach($pkg in $packagelist){
					if($pkg -like "*$itemval"){
						$uncmd = $slocation + "\" + $pkg + "\Uninstall.cmd"
						executeCMD $uncmd
						$done = $true
						if(($LASTEXITCODE -eq 0) -or ($LASTEXITCODE -eq 3010)){
							$msg = "Uninstallation of $pkg completed succesfully.(Remote)"
							Write-log $msg
						}
						else {
							$errmsg = "Uninstallation of $pkg was not completed succesfully.(Remote)"
							Write-log $errmsg "error"
						}
					}
				}
			}
			if(!$done){
				$errmsg = "Uninstallation of $item was not completed succesfully.(Package not found)"
				Write-log $errmsg "error"
			}
		}catch{}
	}
	#End of uninstallation
	
	#reinstallation
	foreach($item in $reinstalllist){
		try{
			$itemval = $item.toString()
			$done = $false
			if($cachedpks){
				foreach($pkg in $cachedpks){
					if($pkg -like "*$itemval"){
						$uncmd = $cachefolder + "\" + $pkg + "\Reinstall.cmd"
						executeCMD $uncmd
						if(($LASTEXITCODE -eq 0) -or ($LASTEXITCODE -eq 3010)){
							$done = $true
							$msg = "Reinstallation of $pkg completed succesfully.(Locally cached)"
							Write-log $msg
						}
						else {
							$errmsg = "Reinstallation of $pkg was not completed succesfully.(Locally cached)"
							Write-log $errmsg "warning"
						}
					}
				}
			}
			if(!$done){
				foreach($pkg in $packagelist){
					if($pkg -like "*$itemval"){
						$uncmd = $slocation + "\" + $pkg + "\Reinstall.cmd"
						executeCMD $uncmd
						$done = $true
						if(($LASTEXITCODE -eq 0) -or ($LASTEXITCODE -eq 3010)){
							$msg = "Reinstallation of $pkg completed succesfully.(Remotely)"
							Write-log $msg
						}
						else {
							$errmsg = "Reinstallation of $pkg was not completed succesfully.(Remotely)"
							Write-log $errmsg "error"
						}
					}
				}
			}
			if(!$done){
				$errmsg = "Reinstallation of $item was not completed succesfully.(Package not found)"
				Write-log $errmsg "error"
			}
		}catch{}
	}
	#end of reinstallation
	
	#Installation
	#local
	foreach($item in $installlistlocal){
		try{
			$itemval = $item.toString()
			$done = $false
			foreach($pkg in $cachedpks){
				if($pkg -like "*$itemval"){
					$uncmd = $cachefolder + "\" + $pkg + "\Install.cmd"
					executeCMD $uncmd
					$done = $true
					if(($LASTEXITCODE -eq 0) -or ($LASTEXITCODE -eq 3010)){
						$msg = "Installation of $pkg completed succesfully.(Local cache)"
						Write-log $msg
					}
					else {
						$errmsg = "Installation of $pkg was not completed succesfully.(Local cache)"
						Write-log $errmsg "error"
					}
				}
			}
			if(!$done){
				$errmsg = "Installation of $item was not completed succesfully.(Package not found in local cache)"
				Write-log $errmsg "error"
			}
		}catch{}
		#remote
		foreach($item in $installlistremote){
			try{
				$itemval = $item.toString()
				$done = $false
				foreach($pkg in $packagelist){
					if($pkg -like "*$itemval"){
						$uncmd = $slocation + "\" + $pkg + "\Install.cmd"
						executeCMD $uncmd
						$done = $true
						if(($LASTEXITCODE -eq 0) -or ($LASTEXITCODE -eq 3010)){
							$msg = "Installation of $pkg completed succesfully.(Remotely)"
							Write-log $msg
						}
						else {
							$errmsg = "Installation of $pkg was not completed succesfully.(Remotely)"
							Write-log $errmsg "error"
						}
					}
				}
				if(!$done){
					$errmsg = "Installation of $item was not completed succesfully.(Package not found remotely)"
					Write-log $errmsg "error"
				}
			}catch{}
		} 
	}
	#end of installation
#Get-LoggedOn
}
#end of software update

#Is single inscance?
$mutex = new-object -TypeName System.Threading.Mutex -ArgumentList $false, “DeploymentToolMutex”;

if(!$mutex.WaitOne(0, $false)){
	break
}
#End of single instance check

#initialize functions
try
{
	# Initialize logging
	$global:logpath = $executingScriptDirectory + "\logs\"
	$logfile = $dt + "_" +$ProgramName + ".log"
	$global:logfilename = $global:logpath + $logfile
	.$executingScriptDirectory/functions.ps1 #Initialize functions
	Write-log "$ProgramName (ver $ver) started."
}
catch 
{		
	return "Error loading functions.ps1"
}
#end of functions initialization

#load config
try
{
	[xml]$xmlconfig = Get-Content $executingScriptDirectory\config.xml
}
catch
{
	$errmsg = "Error parsing XML config. Program stopped." + $Error[0].toString()
	Write-log $errmsg "error"
	return 'Error parsing config.xml'
}

$localinventory += @($softhive + $xmlconfig.deploymenttool.mainconf.registry)
$configsrv = $xmlconfig.deploymenttool.mainconf.configsrv
$clocation = "\\" + $configsrv + "\" + $xmlconfig.deploymenttool.mainconf.configlocation
$clogin = $xmlconfig.deploymenttool.mainconf.clogin
$cpassword = $xmlconfig.deploymenttool.mainconf.cpassword
$cachefolder = $xmlconfig.deploymenttool.mainconf.localcache
#end of load config

#get list of installed packages
if($Env:PROCESSOR_ARCHITECTURE -ne 'x86'){
	$localinventory += @($softhive + 'Wow6432Node\' + $xmlconfig.deploymenttool.mainconf.registry)
}
foreach($inv in $localinventory){
	if(Test-Path $inv){
		$installed = Get-Item $inv
		$installedlist += $installed.GetSubKeyNames()
	}
}
#end of 'get list of installed packages'

#Parsing remote inventory
if(shareConnect $configsrv $clocation $clogin $cpassword){
	$remoteinventory = $clocation + "\" + $Env:COMPUTERNAME + ".xml"
	try
	{
		[xml]$inventoryxml = Get-Content $remoteinventory -ErrorAction SilentlyContinue
		if(!$inventoryxml){
			$errmsg = 'Error reading remote inventory XML, file doesn`t exist. Program stopped.' + $Error[0].toString()
			Write-log $errmsg "error"
			return 'Error reading remote inventory XML'	
		}
	}
	catch
	{
		$errmsg = 'Error parsing remote inventory XML. Program stopped.' + $Error[0].toString()
		Write-log $errmsg "error"
		return 'Error parsing remote inventory XML'
	}
}
else {
	write-log "Program stopped."
	break
}
#End of parsing remote inventory

#Create uninstall and reinstall lists
foreach($item in $installedlist){
	$temp = $item
	foreach($invitem in $inventoryxml.Packages.Package){
		if($temp -eq $invitem.name -and $invitem.reinstall -ne "true"){
			$temp = $null
			break
		}
		elseif($temp -eq $invitem.name -and $invitem.reinstall -eq "true"){
			$reinstalllist += @($temp)
			$temp = $null
			break
		}
	}
	if($temp){
		$uninstalllist += @($temp)
	}
}
#End of uninstall and reinstall lists creation

#Install list creation
foreach($invitem in $inventoryxml.Packages.Package){
	$temp = $invitem
	foreach($item in $installedlist){
		if($temp.name -eq $item){
			$temp = $null
			break
		}
	}
	if($temp){
		if($temp.cached -eq "true"){
			$installlistlocal += @($temp.name)
		}
		else {
			$installlistremote += @($temp.name)
		}
	}
}
#End of install list creation

disconnectShare $clocation

#Update?
if($installlistlocal -or $installlistremote -or $uninstalllist -or $reinstalllist){
	if($args[0] -eq "/FORCE"){
		Write-Log "Start update forcefully."
		#CAREFUL LOGOFF
		doLogoff
		updateSoftware
	}
	else{
		if(doUpdate){
			#CAREFUL LOGOFF
			doLogoff
			updateSoftware
		}
		else {
			Write-Log "Update cancelled by user. Program Stopped."
			break
		}
	}
}
#end of 'Update?'
$mutex.ReleaseMutex()

write-log "Program stopped."