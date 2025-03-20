# Function to show loading animation while executing a command
function Show-LoadingAnimation {
    param ([string]$message)

    $dots = ""
    for ($i = 0; $i -lt 10; $i++) {
        $dots = "." * ($i % 4)  # Alterna tra "", ".", "..", "..."
        Write-Host "`r$message$dots" -NoNewline -ForegroundColor White
        Start-Sleep -Milliseconds 400
    }
    Write-Host "`r$message... Done!   " -ForegroundColor Green
}

# Display loading animation while importing the module
Write-Host "Initializing ESXi Tools..." -ForegroundColor White
Show-LoadingAnimation -message "Importing VMware PowerCLI"

# Silenzia solo i warning di PowerCLI, senza bloccare l'esecuzione
$ProgressPreference = 'SilentlyContinue'

# Import VMware PowerCLI module
if (-not (Get-Module -ListAvailable -Name VMware.PowerCLI)) {
    Install-Module -Name VMware.PowerCLI -Scope CurrentUser -Force
}
Import-Module VMware.PowerCLI -ErrorAction Stop

# Controlla se PowerCLI è stato importato correttamente
if (-not (Get-Module VMware.PowerCLI)) {
    Write-Host "ERROR: VMware PowerCLI failed to load. Please check your installation." -ForegroundColor Red
    Pause-And-Return
    exit
}

# Ripristina le impostazioni predefinite di PowerShell
$ProgressPreference = 'Continue'

# Conferma PowerCLI settings senza output
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null

# Get the script execution directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Function to select a CSV file with a GUI dialog
function Select-CSVFile {
    param ([string]$message, [string]$title)
    
    Write-Host "`n>>> $message" -ForegroundColor White
    Start-Sleep -Milliseconds 500
    
    Add-Type -AssemblyName System.Windows.Forms
    $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $fileDialog.InitialDirectory = $scriptDir
    $fileDialog.Filter = "CSV Files (*.csv)|*.csv"
    $fileDialog.Title = $title
    if ($fileDialog.ShowDialog() -eq "OK") { return $fileDialog.FileName }
    else { return $null }
}

# Function to pause and return to the main menu
function Pause-And-Return {
    Write-Host ""
    Write-Host "Press any key to return to the main menu..." -ForegroundColor White
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Function to change root password on ESXi hosts
function Change-RootPassword {
    $hostsCsvPath = Select-CSVFile -message "Select the Hosts CSV file (e.g., hosts.csv)" -title "Hosts CSV File"
    if (-Not $hostsCsvPath) { Write-Host "ERROR: Operation cancelled." -ForegroundColor Red; Pause-And-Return; return }

    $hosts = Import-Csv -Path $hostsCsvPath

    # Chiede la password attuale e quella nuova
    $currentPassword = Read-Host "Enter current root password"
    $newPassword = Read-Host "Enter NEW root password"

    $successList = @()

    foreach ($esxi in $hosts) {
        $esxiHost = $esxi.ESXiHost.Trim()
        if ([string]::IsNullOrEmpty($esxiHost)) { continue }

        Write-Host "Connecting to $esxiHost..." -ForegroundColor White
        
        try {
            # Autenticazione con la password attuale
            $cred = New-Object System.Management.Automation.PSCredential ("root", (ConvertTo-SecureString -String $currentPassword -AsPlainText -Force))
            $esxiConnection = Connect-VIServer -Server $esxiHost -Credential $cred -ErrorAction Stop

            if ($esxiConnection) {
                # Cambio password root
                Get-VMHostAccount -VMHost $esxiHost -Id root | Set-VMHostAccount -Password $newPassword -Confirm:$false
                Write-Host "SUCCESS: Password changed on $esxiHost" -ForegroundColor Green
                $successList += "$esxiHost -> $newPassword"
                
                # Disconnessione
                Disconnect-VIServer -Server $esxiHost -Confirm:$false -Force
            }
        }
        catch {
            Write-Host "ERROR: Failed to update password on $esxiHost" -ForegroundColor Red
        }
    }

    # Report finale
    Write-Host "`nPassword change summary:" -ForegroundColor White
    foreach ($entry in $successList) {
        Write-Host $entry -ForegroundColor Green
    }

    Pause-And-Return
}

# Main Menu
do {
    Clear-Host
    Write-Host "===================================" -ForegroundColor White
    Write-Host "            ESXi Tools             " -ForegroundColor White
    Write-Host "===================================" -ForegroundColor White
    Write-Host "1. Import vSwitches"
    Write-Host "2. Import Port Groups"
    Write-Host "3. Export vSwitch & Port Groups Config"
    Write-Host "4. Change ESXi Root Password"
    Write-Host "5. Exit"
    Write-Host "===================================" -ForegroundColor White

    $choice = Read-Host "Select an option"

    switch ($choice) {
        "1" { Write-Host "Function Import-vSwitches not implemented yet." -ForegroundColor Yellow }
        "2" { Write-Host "Function Import-PortGroups not implemented yet." -ForegroundColor Yellow }
        "3" { Write-Host "Function Export-Config not implemented yet." -ForegroundColor Yellow }
        "4" { Change-RootPassword }
        "5" { exit }
        default { Write-Host "ERROR: Invalid option. Please try again." -ForegroundColor Red }
    }
} while ($true)
