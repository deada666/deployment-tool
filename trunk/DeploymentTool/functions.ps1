######################################################################
# Script that contains functions for
# installing/uninstalling/reinstalling packages
# This script is a part of deployment tool
#
# Author: Andrew Levin
# File name: functions.ps1
# Version: 1.0
# Last modification: 13.10.2011
#
######################################################################
[reflection.assembly]::LoadWithPartialName("System.Windows.Forms") | out-null

$dt=Get-Date -Format "dd-MM-yyyy"
New-Item -ItemType directory $global:logpath -Force | out-null

[int]$global:errorcount=0
[int]$global:warningcount=0

function global:Write-log($message,[string]$type="info",[string]$logfile=$global:logfilename,[switch]$silent){
	$dt=Get-Date -Format "dd.MM.yyyy HH:mm:ss"	
	$msg=$dt + "`t" + $type + "`t" + $message
	Out-File -FilePath $logfile -InputObject $msg -Append -encoding unicode
	if (-not $silent.IsPresent) 
	{
		switch ( $type.toLower() )
		{
			"error"
			{			
				$global:errorcount++
				write-host $msg -ForegroundColor red			
			}
			"warning"
			{			
				$global:warningcount++
				write-host $msg -ForegroundColor yellow
			}
			"completed"
			{			
				write-host $msg -ForegroundColor green
			}
			"info"
			{			
				write-host $msg
			}			
			default 
			{ 
				write-host $msg
			}
		}
	}
}

function global:doUpdate{
	$message = "Do you want install software updates(logout for long time may be required)?"
	$title = "Update"
	$buttons = [Windows.Forms.MessageBoxButtons]::YesNo
	$icons = [Windows.Forms.MessageBoxIcon]::Question
	$defaultButton = "Button2"
	$obj = [Windows.Forms.MessageBox]::Show($message, $title, $buttons, $icons, $defaultButton)
	switch ([int]$obj)
	{
		{$obj -eq 6} { return $true }
		{$obj -eq 7} { return $false }
	}
}

function global:disconnectShare($slocation){
	net use $slocation /DELETE
}

function global:shareConnect($srv, $location, $login, $password){
	try {
		if(Test-Connection $srv){
			disconnectShare $location
			net use $location /user:$login $password
			if(Test-Path $location){
				return $true
			}
			else {
				write-log "Wrong inventory share location: $location. Program stopped." "error"
				return $false	
			}
		}
		else{
			$errmsg = "Can't connect to server: $srv. Program stopped." + $Error[0].toString()
			write-log $errmsg "error"
			return $false
			}
		}
	catch{
		$errmsg = "Error in config.xml." + $Error[0].toString()
		write-log $errmsg "error"
		return $false
	}
}

function executeCMD($path){
	if(Test-Path $path){
		.$path | Out-Null
	}
	else{
		$errmsg = "Error: " + $path + " - not found!"
		write-log $errmsg "error"
	}
}