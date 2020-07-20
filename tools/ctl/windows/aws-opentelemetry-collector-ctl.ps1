# Copyright 2017 Amazon.com, Inc. and its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#   http://aws.amazon.com/asl/
#
# or in the "license" file accompanying this file. This file is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied. See the License for the specific language governing
# permissions and limitations under the License.

Param (
    [Parameter(Mandatory = $false)]
    [string]$Action,
    [Parameter(Mandatory = $false)]
    [switch]$Help,
    [Parameter(Mandatory = $false)]
    [string]$ConfigLocation = 'default',
    [Parameter(Mandatory = $false)]
    [switch]$Start = $false,
    [Parameter(Mandatory = $false)]
    [string]$Mode = 'ec2',
    [parameter(ValueFromRemainingArguments=$true)]
    $unsupportedVars
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$UsageString = @"


        usage: aws-opentelemetry-collector-ctl.ps1 -a stop|start|status

        e.g.
        1. apply a SSM parameter store config on EC2 instance and restart the agent afterwards:
            aws-opentelemetry-collector-ctl.ps1 -a fetch-config -m ec2 -c ssm:AmazonCloudWatch-Config.json -s
        2. append a local json config file on onPremise host and restart the agent afterwards:
            aws-opentelemetry-collector-ctl.ps1 -a append-config -m onPremise -c file:c:\config.json -s
        3. query agent status:
            aws-opentelemetry-collector-ctl.ps1 -a status

        -a: action
            stop:                                   stop the agent process.
            start:                                  start the agent process.
            status:                                 get the status of the agent process.
            fetch-config:                           use this json config as the agent's only configuration.
            append-config:                          append json config with the existing json configs if any.
            remove-config:                          remove json config based on the location (ssm parameter store name, file name)

        -m: mode
            ec2:                                    indicate this is on ec2 host.
            onPremise:                              indicate this is on onPremise host.
            auto:                                   use ec2 metadata to determine the environment, may not be accurate if ec2 metadata is not available for some reason on EC2.

        -c: configuration
            default:                                default configuration for quick trial.
            ssm:<parameter-store-name>:             ssm parameter store name
            file:<file-path>:                       file path on the host

        -s: optionally restart after configuring the agent configuration
            this parameter is used for 'fetch-config', 'append-config', 'remove-config' action only.

"@

$AOCServiceName = 'AOCAgent'
$AOCServiceDisplayName = 'Aoc Agent'
$AOCDirectory = 'Amazon\AOCAgent'

$AOCProgramFiles = "${Env:ProgramFiles}\${AOCDirectory}"
if ($Env:ProgramData) {
    $AOCProgramData = "${Env:ProgramData}\${AOCDirectory}"
} else {
    # Windows 2003
    $AOCProgramData = "${Env:ALLUSERSPROFILE}\Application Data\${AOCDirectory}"
}

$AOCLogDirectory = "${AOCProgramData}\Logs"
$VersionFile ="${AOCProgramFiles}\VERSION"

# The windows service registration assumes exactly this .toml file path and name
$YAML="${AOCProgramData}\config.yaml"

Function AOCStart() {
    if (!(Test-Path -LiteralPath "${YAML}")) {
        Write-Output "AOC-agent is not configured. Applying default configuration before starting it."
    }
    $svc = Get-Service -Name "${AOCServiceName}" -ErrorAction SilentlyContinue
    if (!$svc) {
        New-Service -Name "${AOCServiceName}" -DisplayName "${AOCServiceDisplayName}" -Description "${AOCServiceDisplayName}" -DependsOn LanmanServer -BinaryPathName "`"${AOCProgramFiles}\start-amazon-cloudwatch-agent.exe`"" | Out-Null
        # object returned by New-Service gives errors so retrieve it again
        $svc = Get-Service -Name "${AOCServiceName}"
        # Configure the service to restart on crashes. It's unclear how to do this through WMI or CIM interface so using sc.exe
        # Restarts immediately on the first two crashes then gives a 2 second sleep after any subsequent crash.
        & sc.exe failure "${AOCServiceName}" reset= 86400 actions= restart/0/restart/0/restart/2000 | Out-Null
        if ($CIM) {
            & sc.exe failureflag "${AOCServiceName}" 1 | Out-Null
        }
    }
    $svc | Start-Service
}

Function AOCStop() {
    $svc = Get-Service -Name "${AOCServiceName}" -ErrorAction SilentlyContinue
    if ($svc) {
        $svc | Stop-Service
    }
}


Function AOCStatus() {

    $timefmt=''

    if ($CIM) {
        $svc = Get-CimInstance -ClassName Win32_Service -Filter "name='${AOCServiceName}'"
    } else {
        $svc = Get-WmiObject -Class Win32_Service -Filter "name='${AOCServiceName}'"
    }

    if ($svc) {
        $cwapid = $svc.ProcessId
        $process = Get-Process -Id "${cwapid}"
        $processStart = $process.StartTime
        if ($processStart) {
            $timefmt = Get-Date -Date ${processStart} -Format "s"
        }
    }
    
    $status = AOCRunstatus
    $version = ([IO.File]::ReadAllText("${VersionFile}")).Trim()
    
    Write-Output "{"
    Write-Output "  `"status`": `"${status}`","
    Write-Output "  `"starttime`": `"${timefmt}`","
    Write-Output "  `"version`": `"${version}`""
    Write-Output "}"
}

# Translate platform status names to those used across all AOCgent's platforms
Function AOCRunstatus() {
    $running = $false
    $svc = Get-Service -Name "${AOCServiceName}" -ErrorAction SilentlyContinue
    if ($svc -and ($svc.Status -eq 'running')) {
        $running = $true
    }
    if ($running) {
        return 'running'
    } else {
        return 'stopped'
    }
}



# TODO Occasionally metadata service isn't available and this gives a false negative - might
# be a better way to probe
# http://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/identify_ec2_instances.html
# Ultimately though an optional 'ec2-override' flag seems necessary for easier testing
Function AOCTestEC2() {
    $error.clear()
    $request = [System.Net.WebRequest]::Create('http://169.254.169.254/')
    $request.Timeout = 5
    try {
        $response = $request.GetResponse()
        $response.Close()
    } catch {
        return $false
    }
    return !$error
}

Function main() {

    if (Get-Command 'Get-CimInstance' -CommandType Cmdlet -ErrorAction SilentlyContinue) {
        $CIM = $true
    }

    if ($unsupportedVars) {
        Write-Output "Ignore unsupported params: $unsupportedVars`n${UsageString}"
    }

    if ($Help) {
        Write-Output "${UsageString}"
        exit 0
    }


    switch -exact ($Action) {
        stop { AOCStop }
        start { AOCStart }
        status { AOCStatus }
        default {
           Write-Output "Invalid action: ${Action}`n${UsageString}"
           Exit 1
        }
    }
}

main
