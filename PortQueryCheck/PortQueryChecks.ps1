#
# PortQueryChecks.ps1
#
#Required Ports:
<#
active-directory: tcp/1025-5000, tcp/135,138,139,389,445,464,636, tcp/49152-65535, tcp/5722,9389, udp/88,123,137,138,389,445,464,253      
dns: tcp/53, udp/53,5353
kerberos: tcp/88,464,749,750, udp/88,464,749,750
ldap: tcp/389,3268,3269,636, udp/389,3268
netbios-dg: udp/138
netbios-ns: tcp/137, udp/137
ntp: tcp/123, udp/123
#>

#Port Definitions:
#Add XML is separate file
[xml]$myxml = @"
<DefinePorts>
 <item Name="ADPortsTCP" Ports="135,136,138,139,389,445,464,636,5722,9389">
  <info>TCP</info>
 </item>
 <item Name="ADPortsUDP" Ports="88,123,137,138,389,445,464,253">
  <info>UDP</info>
 </item>
 <item Name="DNSPortsTCP" Ports="53">
  <info>TCP</info>
 </item>
 <item Name="DNSPortsUDP" Ports="53,5353">
  <info>UDP</info>
 </item>
 <item Name="KerberosPortsTCP" Ports="88,464,749,750">
  <info>TCP</info>
 </item>
 <item Name="KerberosPortsUDP" Ports="88,464,749,750">
  <info>UDP</info>
 </item>
 <item Name="NetBiosPortsTCP" Ports="137">
  <info>TCP</info>
 </item>
 <item Name="NetBiosPortsUDP" Ports="137,138">
  <info>UDP</info>
 </item> 
 <item Name="NTPPortsTCP" Ports="123">
  <info>TCP</info>
 </item>
 <item Name="NTPPortsUDP" Ports="123">
  <info>UDP</info>
 </item> 
</DefinePorts>
"@

$Error.Clear()

$ServerListFileName = "Servers.txt"
$LogsDirName = "Logs"
$PortQryExePath = "C:\OneDrive\OneDrive - DXC Production\Work\_Scripts\PortQuery\PortQueryAD_Old_cmd"


$Date = get-date -format yyyy-MM-dd
$Time = get-date -format HH-mm
$EOL = "--------=====-------------"
$CurentPath = Get-Location
$LogsFullDirPath = $CurentPath.Path + "\" + $LogsDirName
$InputFileFullPath = $CurentPath.Path + "\" + $ServerListFileName
Write-Host $CurentPath

If(Test-Path $InputFileFullPath)
{
	$Servers = Get-Content $InputFileFullPath
	if (!($Servers.Length -gt 0))
	{
		Write-Host "Input file empty"
		exit -1
	}
} else {
	Write-Host "Unable to read Input file"
	exit -1
}

if (!(Test-Path $LogsFullDirPath))
{
	Write-Host "Creating Logs Directory:" $LogsDirName " in " $CurentPath
	New-Item -ItemType Directory -Name $LogsDirName -Path $CurentPath
}


[array]$myitems = $myxml.DefinePorts.Item
#Write-Host $CurentPath


ForEach ($server in $Servers)
{
	

	ForEach ($ItemToCheck in $myitems)
	{
		$OutPutFile = $CurentPath.Path + "\" + $LogsDirName + "\" + $server + $ItemToCheck.Name + $Date + ".txt"
		#Add Function to delete OutPutFile
		If (Test-Path $OutPutFile) 
		{
			Remove-Item $OutPutFile
		}
		$Ports = $ItemToCheck.Ports.Split(",")

		ForEach ($Port in $Ports)
		{
			Write-Host "working on: " $server " - Item: " $ItemToCheck.Name " - Port: " $Port
			$cmdToRun = $PortQryExePath + "\portqry.exe" + " -n " + $Server + " -e " + $Port + " -p " + $ItemToCheck.info
			$cmdOutPut = Invoke-Expression -Command $cmdToRun
			$cmdToRun | Add-Content $OutPutFile
			$cmdOutput | Add-Content $OutPutFile
		}

		
	}

}