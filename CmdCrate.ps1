#Requires -Version 5.1
<#
.SYNOPSIS
    CmdCrate - reinstall your Windows apps with winget, choosing them from a GUI.

.DESCRIPTION
    Shows a list of apps grouped by category (from apps.json). Tick the ones you want and
    press Install: each app is installed with the official winget source, one at a time.

    Privacy: CmdCrate collects no personal data and sends nothing anywhere. The only network
    traffic is done by winget itself (Microsoft) and by the app installers it downloads.
    A local log is written to %LOCALAPPDATA%\CmdCrate\logs and deleted after 30 days.

.PARAMETER CatalogPath
    Path to the app catalog (apps.json). Defaults to apps.json next to this script.

.PARAMETER Apps
    Command-line mode: install these winget IDs without opening the GUI.

.PARAMETER Import
    Command-line mode: install every app listed in a winget export file or a CmdCrate selection file.

.PARAMETER Language
    UI language: auto (default, follows Windows), it, en.

.PARAMETER NoGui
    Do not open the GUI. Used together with -Apps or -Import.

.PARAMETER NoLog
    Do not write a log file to disk.

.EXAMPLE
    .\CmdCrate.ps1
    Opens the GUI.

.EXAMPLE
    .\CmdCrate.ps1 -Apps 7zip.7zip,VideoLAN.VLC -WhatIf
    Shows what would be installed, without installing anything.

.LINK
    https://github.com/makaDv/CmdCrate
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$CatalogPath,
    [string[]]$Apps,
    [string]$Import,
    [ValidateSet('auto', 'it', 'en')]
    [string]$Language = 'auto',
    [switch]$NoGui,
    [switch]$NoLog
)

$ErrorActionPreference = 'Stop'
$script:Version = '1.0.0'

# ---------------------------------------------------------------------------
# Strings (IT / EN)
# ---------------------------------------------------------------------------
$script:Strings = @{
    en = @{
        Subtitle         = 'Pick the apps you want and install them all with winget.'
        Privacy          = 'Privacy: no data is collected or sent. Everything stays on your PC.'
        Search           = 'Search:'
        SelectAll        = 'Select all'
        SelectNone       = 'Select none'
        SelectDefaults   = 'Recommended'
        Import           = 'Import list...'
        SaveSel          = 'Save selection...'
        Export           = 'Export installed apps...'
        Install          = 'Install selected'
        Cancel           = 'Stop after current'
        OpenLogs         = 'Open log folder'
        DeleteData       = 'Delete local data'
        RunAdmin         = 'Restart as administrator'
        All              = 'all'
        None             = 'none'
        Selected         = '{0} selected'
        Installed        = 'installed'
        Ready            = 'Ready.'
        CheckingInstalled = 'Checking which apps are already installed...'
        CheckedInstalled = '{0} catalog apps are already installed.'
        NothingSelected  = 'No app selected.'
        Installing       = 'Installing {0} ({1}/{2})...'
        ResOk            = 'installed'
        ResAlready       = 'already installed / up to date'
        ResReboot        = 'installed, restart required'
        ResNotFound      = 'not found in winget'
        ResFail          = 'failed (code {0})'
        Done             = 'Finished: {0} installed, {1} already present, {2} failed.'
        ConfirmInstall   = "Install {0} apps?`n`nEach app has its own license (EULA). By continuing you accept them through winget."
        ExportDone       = 'Installed apps exported to: {0}'
        ExportFail       = 'Export failed (code {0}).'
        ImportDone       = '{0} apps selected from file ({1} not in catalog, added to "Imported").'
        ImportFail       = 'Cannot read the file: {0}'
        SaveDone         = 'Selection saved to: {0}'
        ConfirmDelete    = "Delete all CmdCrate local data (logs) from this PC?`n`n{0}"
        DeleteDone       = 'Local data deleted. File logging is off for this session.'
        BusyClose        = "An installation is running. Close anyway?`n`nThe app being installed right now will finish in the background."
        CancelRequested  = 'Stopping after the current app...'
        ImportedCategory = 'Imported'
        ImportedDesc     = 'Imported from file'
        NoWinget         = "winget (App Installer) is not available.`n`nThe Microsoft Store page of App Installer will open: install it and run CmdCrate again."
        OldWindows       = 'CmdCrate needs Windows 10 version 1809 (build 17763) or newer.'
        InvalidId        = 'Skipped invalid package ID: {0}'
        Homepage         = 'website'
        AdminNote        = 'Some installers ask for administrator rights (UAC) on their own.'
    }
    it = @{
        Subtitle         = 'Scegli le app che vuoi e installale tutte con winget.'
        Privacy          = 'Privacy: nessun dato viene raccolto o inviato. Tutto resta sul tuo PC.'
        Search           = 'Cerca:'
        SelectAll        = 'Seleziona tutto'
        SelectNone       = 'Deseleziona tutto'
        SelectDefaults   = 'Consigliate'
        Import           = 'Importa lista...'
        SaveSel          = 'Salva selezione...'
        Export           = 'Esporta app installate...'
        Install          = 'Installa selezionate'
        Cancel           = 'Ferma dopo la corrente'
        OpenLogs         = 'Apri cartella log'
        DeleteData       = 'Elimina dati locali'
        RunAdmin         = 'Riavvia come amministratore'
        All              = 'tutte'
        None             = 'nessuna'
        Selected         = '{0} selezionate'
        Installed        = 'installata'
        Ready            = 'Pronto.'
        CheckingInstalled = 'Controllo delle app già installate...'
        CheckedInstalled = '{0} app del catalogo sono già installate.'
        NothingSelected  = 'Nessuna app selezionata.'
        Installing       = 'Installazione di {0} ({1}/{2})...'
        ResOk            = 'installata'
        ResAlready       = 'già installata / aggiornata'
        ResReboot        = 'installata, serve un riavvio'
        ResNotFound      = 'non trovata in winget'
        ResFail          = 'errore (codice {0})'
        Done             = 'Completato: {0} installate, {1} già presenti, {2} errori.'
        ConfirmInstall   = "Installare {0} app?`n`nOgni app ha la propria licenza (EULA). Continuando la accetti tramite winget."
        ExportDone       = 'App installate esportate in: {0}'
        ExportFail       = 'Esportazione fallita (codice {0}).'
        ImportDone       = '{0} app selezionate dal file ({1} non presenti nel catalogo, aggiunte in "Importate").'
        ImportFail       = 'Impossibile leggere il file: {0}'
        SaveDone         = 'Selezione salvata in: {0}'
        ConfirmDelete    = "Eliminare tutti i dati locali di CmdCrate (log) da questo PC?`n`n{0}"
        DeleteDone       = 'Dati locali eliminati. Il log su file è disattivato per questa sessione.'
        BusyClose        = "C'è un'installazione in corso. Chiudere comunque?`n`nL'app in installazione proseguirà in background."
        CancelRequested  = "Arresto dopo l'app corrente..."
        ImportedCategory = 'Importate'
        ImportedDesc     = 'Importata da file'
        NoWinget         = "winget (Programma di installazione app) non è disponibile.`n`nSi aprirà la pagina del Microsoft Store: installalo e riavvia CmdCrate."
        OldWindows       = 'CmdCrate richiede Windows 10 versione 1809 (build 17763) o successiva.'
        InvalidId        = 'ID pacchetto non valido ignorato: {0}'
        Homepage         = 'sito'
        AdminNote        = 'Alcuni installer chiedono da soli i permessi di amministratore (UAC).'
    }
}

if ($Language -eq 'auto') {
    $Language = if ((Get-UICulture).TwoLetterISOLanguageName -eq 'it') { 'it' } else { 'en' }
}
$script:T = $script:Strings[$Language]

# ---------------------------------------------------------------------------
# Helpers: validation, privacy-safe logging
# ---------------------------------------------------------------------------
# winget package IDs: letters, digits, dot, dash, underscore, plus. No spaces or quotes,
# so an ID can never break out of the winget argument string.
$script:IdPattern = '^[A-Za-z0-9][A-Za-z0-9._+\-]{0,127}$'

function Test-PackageId {
    param([string]$Id)
    return ($Id -and ($Id -match $script:IdPattern))
}

$script:DataDir = Join-Path $env:LOCALAPPDATA 'CmdCrate'
$script:LogDir = Join-Path $script:DataDir 'logs'
$script:FileLogging = -not $NoLog
$script:LogFile = Join-Path $script:LogDir ('cmdcrate-{0}.log' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
$script:LogBox = $null

function Protect-Text {
    # Removes user name, computer name and profile path from text before it is logged.
    param([string]$Text)
    if (-not $Text) { return $Text }
    $pairs = @(
        @($env:USERPROFILE, '%USERPROFILE%'),
        @($env:LOCALAPPDATA, '%LOCALAPPDATA%'),
        @($env:COMPUTERNAME, '<pc>'),
        @($env:USERNAME, '<user>')
    )
    foreach ($p in $pairs) {
        if ($p[0] -and $p[0].Length -ge 3) {
            $Text = [regex]::Replace($Text, [regex]::Escape($p[0]), $p[1], 'IgnoreCase')
        }
    }
    return $Text
}

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $line = '{0} [{1}] {2}' -f (Get-Date -Format 'HH:mm:ss'), $Level, (Protect-Text $Message)
    if ($script:LogBox) {
        $script:LogBox.AppendText($line + "`r`n")
        $script:LogBox.ScrollToEnd()
    }
    else {
        Write-Information $line -InformationAction Continue
    }
    if ($script:FileLogging) {
        try {
            if (-not (Test-Path -LiteralPath $script:LogDir)) {
                New-Item -ItemType Directory -Path $script:LogDir -Force | Out-Null
            }
            Add-Content -LiteralPath $script:LogFile -Value $line -Encoding UTF8
        }
        catch {
            $script:FileLogging = $false
        }
    }
}

function Remove-OldLog {
    # Storage limitation (GDPR art. 5): logs older than 30 days are deleted.
    if (-not (Test-Path -LiteralPath $script:LogDir)) { return }
    $limit = (Get-Date).AddDays(-30)
    Get-ChildItem -LiteralPath $script:LogDir -Filter 'cmdcrate-*.log' -File -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -lt $limit } |
        Remove-Item -Force -ErrorAction SilentlyContinue
}

function Get-ResultText {
    param([int]$Code)
    switch ($Code) {
        0 { return @('ok', $script:T.ResOk) }
        -1978335189 { return @('already', $script:T.ResAlready) }   # 0x8A15002B update not applicable
        -1978335135 { return @('already', $script:T.ResAlready) }   # 0x8A150061 already installed
        -1978334967 { return @('ok', $script:T.ResReboot) }         # 0x8A150109 reboot required
        -1978335212 { return @('fail', $script:T.ResNotFound) }     # 0x8A150014 no package found
        default { return @('fail', ($script:T.ResFail -f ('0x{0:X8}' -f $Code))) }
    }
}

function Get-InstallArgument {
    param([string]$Id)
    if (-not (Test-PackageId $Id)) { throw ($script:T.InvalidId -f $Id) }
    return @('install', '--id', $Id, '--exact', '--source', 'winget',
        '--accept-package-agreements', '--accept-source-agreements',
        '--silent', '--disable-interactivity')
}

function Get-IdFromFile {
    # Reads a winget export file (Sources[].Packages[].PackageIdentifier)
    # or a CmdCrate selection file ({ "apps": [ ... ] }). Returns valid IDs only.
    param([string]$Path)
    $item = Get-Item -LiteralPath $Path
    if ($item.Length -gt 5MB) { throw 'File too large (max 5 MB).' }
    $json = Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
    $ids = New-Object System.Collections.Generic.List[string]
    if ($json.PSObject.Properties.Name -contains 'Sources') {
        foreach ($s in $json.Sources) {
            foreach ($p in $s.Packages) { $ids.Add([string]$p.PackageIdentifier) }
        }
    }
    elseif ($json.PSObject.Properties.Name -contains 'apps') {
        foreach ($a in $json.apps) { $ids.Add([string]$a) }
    }
    $valid = New-Object System.Collections.Generic.List[string]
    foreach ($id in $ids) {
        if (Test-PackageId $id) {
            if (-not $valid.Contains($id)) { $valid.Add($id) }
        }
        else { Write-Log ($script:T.InvalidId -f $id) 'WARN' }
    }
    return , $valid.ToArray()
}

function Read-Catalog {
    param([string]$Path)
    $raw = Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
    $cats = @()
    foreach ($c in $raw.categories) {
        $list = @()
        foreach ($a in $c.apps) {
            if (-not (Test-PackageId $a.id)) { Write-Log ($script:T.InvalidId -f $a.id) 'WARN'; continue }
            $homepage = [string]$a.homepage
            if ($homepage -notmatch '^https://[^\s"]+$') { $homepage = '' }
            $list += [pscustomobject]@{
                Id          = [string]$a.id
                Name        = [string]$a.name
                Description = [string]$a.description
                Homepage    = $homepage
                Default     = [bool]$a.default
            }
        }
        $cats += [pscustomobject]@{ Name = [string]$c.name; Apps = $list }
    }
    return $cats
}

function Test-IsAdmin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    return (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ---------------------------------------------------------------------------
# Prerequisites
# ---------------------------------------------------------------------------
if ([Environment]::OSVersion.Version.Build -lt 17763) {
    Write-Error $script:T.OldWindows
    exit 1
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Warning $script:T.NoWinget
    Start-Process 'ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1'
    exit 1
}

if (-not $CatalogPath) {
    $base = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
    $CatalogPath = Join-Path $base 'apps.json'
}

$cliMode = $NoGui -or $Apps -or $Import
Remove-OldLog
Write-Log ("CmdCrate {0} - PowerShell {1}" -f $script:Version, $PSVersionTable.PSVersion)

# ---------------------------------------------------------------------------
# Command-line mode
# ---------------------------------------------------------------------------
if ($cliMode) {
    $targets = New-Object System.Collections.Generic.List[string]
    foreach ($a in @($Apps)) {
        foreach ($part in ([string]$a -split ',')) {
            $id = $part.Trim()
            if (-not $id) { continue }
            if (Test-PackageId $id) { $targets.Add($id) } else { Write-Log ($script:T.InvalidId -f $id) 'WARN' }
        }
    }
    if ($Import) { foreach ($id in (Get-IdFromFile $Import)) { $targets.Add($id) } }
    $targets = @($targets | Select-Object -Unique)
    if ($targets.Count -eq 0) { Write-Log $script:T.NothingSelected 'WARN'; exit 0 }

    $count = @{ ok = 0; already = 0; fail = 0 }
    $i = 0
    foreach ($id in $targets) {
        $i++
        if (-not $PSCmdlet.ShouldProcess($id, 'winget install')) { continue }
        Write-Log ($script:T.Installing -f $id, $i, $targets.Count)
        $wingetArgs = Get-InstallArgument $id
        & winget @wingetArgs
        $res = Get-ResultText $LASTEXITCODE
        $count[$res[0]]++
        Write-Log ('{0}: {1}' -f $id, $res[1]) $(if ($res[0] -eq 'fail') { 'ERROR' } else { 'INFO' })
    }
    Write-Log ($script:T.Done -f $count.ok, $count.already, $count.fail)
    exit $(if ($count.fail -gt 0) { 1 } else { 0 })
}

# ---------------------------------------------------------------------------
# GUI mode (WPF needs an STA thread)
# ---------------------------------------------------------------------------
if ([Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') {
    if (-not $PSCommandPath) { throw 'The GUI needs an STA thread. Run: powershell -STA -File CmdCrate.ps1' }
    $hostExe = (Get-Process -Id $PID).Path
    $relaunch = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-STA', '-File', "`"$PSCommandPath`"",
        '-CatalogPath', "`"$CatalogPath`"", '-Language', $Language)
    if ($NoLog) { $relaunch += '-NoLog' }
    Start-Process -FilePath $hostExe -ArgumentList $relaunch
    exit 0
}

if (-not (Test-Path -LiteralPath $CatalogPath)) { throw "Catalog not found: $CatalogPath" }

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="CmdCrate" Width="1000" Height="760" MinWidth="780" MinHeight="560"
        WindowStartupLocation="CenterScreen" Background="#F4F5F7"
        FontFamily="Segoe UI" FontSize="13">
  <Window.Resources>
    <Style TargetType="Button">
      <Setter Property="Padding" Value="12,6"/>
      <Setter Property="Margin" Value="0,0,8,0"/>
      <Setter Property="Background" Value="White"/>
      <Setter Property="BorderBrush" Value="#C9CDD4"/>
      <Setter Property="Cursor" Value="Hand"/>
    </Style>
    <Style x:Key="Primary" TargetType="Button" BasedOn="{StaticResource {x:Type Button}}">
      <Setter Property="Background" Value="#2563EB"/>
      <Setter Property="Foreground" Value="White"/>
      <Setter Property="BorderBrush" Value="#1D4ED8"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Padding" Value="18,8"/>
    </Style>
  </Window.Resources>
  <Grid Margin="18">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="150"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <StackPanel Grid.Row="0" Margin="0,0,0,12">
      <TextBlock Text="CmdCrate" FontSize="26" FontWeight="Bold" Foreground="#111827"/>
      <TextBlock x:Name="SubtitleText" Foreground="#374151" Margin="0,2,0,0"/>
      <TextBlock x:Name="PrivacyText" Foreground="#047857" Margin="0,4,0,0"/>
    </StackPanel>

    <DockPanel Grid.Row="1" Margin="0,0,0,10" LastChildFill="True">
      <TextBlock x:Name="SearchLabel" DockPanel.Dock="Left" VerticalAlignment="Center" Margin="0,0,6,0"/>
      <TextBox x:Name="SearchBox" DockPanel.Dock="Left" Width="220" Padding="4" Margin="0,0,12,0" VerticalContentAlignment="Center"/>
      <WrapPanel DockPanel.Dock="Left">
        <Button x:Name="SelectAllButton"/>
        <Button x:Name="SelectNoneButton"/>
        <Button x:Name="SelectDefaultsButton"/>
        <Button x:Name="ImportButton"/>
        <Button x:Name="SaveSelButton"/>
        <Button x:Name="ExportButton"/>
      </WrapPanel>
    </DockPanel>

    <Border Grid.Row="2" Background="White" BorderBrush="#E5E7EB" BorderThickness="1" CornerRadius="6">
      <ScrollViewer VerticalScrollBarVisibility="Auto">
        <StackPanel x:Name="CategoryPanel" Margin="10"/>
      </ScrollViewer>
    </Border>

    <Grid Grid.Row="3" Margin="0,10,0,6">
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="*"/>
        <ColumnDefinition Width="Auto"/>
      </Grid.ColumnDefinitions>
      <StackPanel>
        <TextBlock x:Name="StatusText" Foreground="#111827" Margin="0,0,0,4"/>
        <ProgressBar x:Name="Progress" Height="8" Minimum="0" Maximum="1" Value="0"/>
      </StackPanel>
      <TextBlock x:Name="CountText" Grid.Column="1" VerticalAlignment="Bottom" Margin="12,0,0,0" FontWeight="SemiBold"/>
    </Grid>

    <TextBox x:Name="LogBox" Grid.Row="4" IsReadOnly="True" FontFamily="Consolas" FontSize="12"
             VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto"
             Background="#111827" Foreground="#E5E7EB" BorderThickness="0" Padding="8" TextWrapping="NoWrap"/>

    <DockPanel Grid.Row="5" Margin="0,12,0,0" LastChildFill="False">
      <Button x:Name="OpenLogsButton" DockPanel.Dock="Left"/>
      <Button x:Name="DeleteDataButton" DockPanel.Dock="Left"/>
      <Button x:Name="AdminButton" DockPanel.Dock="Left"/>
      <Button x:Name="InstallButton" DockPanel.Dock="Right" Style="{StaticResource Primary}" Margin="0"/>
      <Button x:Name="CancelButton" DockPanel.Dock="Right" IsEnabled="False"/>
    </DockPanel>
  </Grid>
</Window>
'@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$script:Window = [Windows.Markup.XamlReader]::Load($reader)
$ui = @{}
foreach ($node in $xaml.SelectNodes('//*[@*[local-name()="Name"]]')) {
    $name = $node.Attributes | Where-Object { $_.LocalName -eq 'Name' } | Select-Object -First 1 -ExpandProperty Value
    $ui[$name] = $script:Window.FindName($name)
}
$script:UI = $ui
$script:LogBox = $ui.LogBox

$ui.SubtitleText.Text = $script:T.Subtitle
$ui.PrivacyText.Text = $script:T.Privacy
$ui.SearchLabel.Text = $script:T.Search
$ui.SelectAllButton.Content = $script:T.SelectAll
$ui.SelectNoneButton.Content = $script:T.SelectNone
$ui.SelectDefaultsButton.Content = $script:T.SelectDefaults
$ui.ImportButton.Content = $script:T.Import
$ui.SaveSelButton.Content = $script:T.SaveSel
$ui.ExportButton.Content = $script:T.Export
$ui.InstallButton.Content = $script:T.Install
$ui.CancelButton.Content = $script:T.Cancel
$ui.OpenLogsButton.Content = $script:T.OpenLogs
$ui.DeleteDataButton.Content = $script:T.DeleteData
$ui.AdminButton.Content = $script:T.RunAdmin
$ui.StatusText.Text = $script:T.Ready
$script:Window.Title = "CmdCrate $script:Version"
if (Test-IsAdmin) { $ui.AdminButton.Visibility = 'Collapsed' }

# ---------------------------------------------------------------------------
# Catalog -> UI
# ---------------------------------------------------------------------------
$script:Items = New-Object System.Collections.Generic.List[object]
$script:Categories = @{}
$script:InstalledIds = @{}

function New-Brush { param([string]$Hex) return [Windows.Media.BrushConverter]::new().ConvertFromString($Hex) }

function Add-CategoryBlock {
    param([string]$Name)
    $expander = New-Object Windows.Controls.Expander
    $expander.IsExpanded = $true
    $expander.Margin = '0,0,0,10'

    $header = New-Object Windows.Controls.StackPanel
    $header.Orientation = 'Horizontal'
    $title = New-Object Windows.Controls.TextBlock
    $title.Text = $Name
    $title.FontSize = 15
    $title.FontWeight = 'SemiBold'
    $title.VerticalAlignment = 'Center'
    $title.Margin = '0,0,12,0'
    [void]$header.Children.Add($title)
    foreach ($pair in @(@($script:T.All, $true), @($script:T.None, $false))) {
        $b = New-Object Windows.Controls.Button
        $b.Content = $pair[0]
        $b.Padding = '8,1'
        $b.Margin = '0,0,6,0'
        $b.FontSize = 11
        $b.Tag = @{ Category = $Name; Value = $pair[1] }
        $b.Add_Click({
                foreach ($it in $script:Items) {
                    if ($it.Category -eq $this.Tag.Category -and $it.Row.Visibility -eq 'Visible') {
                        $it.CheckBox.IsChecked = $this.Tag.Value
                    }
                }
                Update-Count
            })
        [void]$header.Children.Add($b)
    }
    $expander.Header = $header

    $panel = New-Object Windows.Controls.StackPanel
    $panel.Margin = '22,6,0,0'
    $expander.Content = $panel
    [void]$script:UI.CategoryPanel.Children.Add($expander)
    $script:Categories[$Name] = @{ Expander = $expander; Panel = $panel }
}

function Add-AppRow {
    param([string]$Category, $App)
    if (-not $script:Categories.ContainsKey($Category)) { Add-CategoryBlock $Category }
    $panel = $script:Categories[$Category].Panel

    $row = New-Object Windows.Controls.DockPanel
    $row.Margin = '0,3,0,3'
    $row.LastChildFill = $true

    $cb = New-Object Windows.Controls.CheckBox
    $cb.Content = $App.Name
    $cb.FontWeight = 'SemiBold'
    $cb.MinWidth = 200
    $cb.VerticalAlignment = 'Center'
    $cb.IsChecked = $App.Default
    $cb.ToolTip = '{0}  ({1})' -f $App.Description, $App.Id
    $cb.Add_Click({ Update-Count })
    [Windows.Controls.DockPanel]::SetDock($cb, 'Left')
    [void]$row.Children.Add($cb)

    $status = New-Object Windows.Controls.TextBlock
    $status.Margin = '8,0,0,0'
    $status.VerticalAlignment = 'Center'
    $status.Foreground = New-Brush '#047857'
    [Windows.Controls.DockPanel]::SetDock($status, 'Right')

    if ($App.Homepage) {
        $link = New-Object Windows.Controls.TextBlock
        $hl = New-Object Windows.Documents.Hyperlink
        [void]$hl.Inlines.Add($script:T.Homepage)
        $hl.NavigateUri = [uri]$App.Homepage
        $hl.ToolTip = $App.Homepage
        $hl.Add_RequestNavigate({
                param($s, $e)
                $u = $e.Uri.AbsoluteUri
                if ($u -match '^https://') { Start-Process $u }
                $e.Handled = $true
            })
        [void]$link.Inlines.Add($hl)
        $link.Margin = '8,0,0,0'
        $link.VerticalAlignment = 'Center'
        [Windows.Controls.DockPanel]::SetDock($link, 'Right')
        [void]$row.Children.Add($link)
    }
    [void]$row.Children.Add($status)

    $desc = New-Object Windows.Controls.TextBlock
    $desc.Text = '{0}  -  {1}' -f $App.Description, $App.Id
    $desc.Foreground = New-Brush '#6B7280'
    $desc.VerticalAlignment = 'Center'
    $desc.TextTrimming = 'CharacterEllipsis'
    $desc.Margin = '6,0,0,0'
    [void]$row.Children.Add($desc)

    [void]$panel.Children.Add($row)
    $item = [pscustomobject]@{
        Id = $App.Id; Name = $App.Name; Description = $App.Description; Category = $Category
        Default = $App.Default; CheckBox = $cb; Row = $row; Status = $status
    }
    $script:Items.Add($item)
    return $item
}

function Update-Count {
    $n = @($script:Items | Where-Object { $_.CheckBox.IsChecked }).Count
    $script:UI.CountText.Text = $script:T.Selected -f $n
}

function Update-Filter {
    $q = $script:UI.SearchBox.Text.Trim()
    foreach ($it in $script:Items) {
        $match = (-not $q) -or ($it.Name -like "*$q*") -or ($it.Id -like "*$q*") -or ($it.Description -like "*$q*")
        $it.Row.Visibility = if ($match) { 'Visible' } else { 'Collapsed' }
    }
    foreach ($name in $script:Categories.Keys) {
        $any = @($script:Items | Where-Object { $_.Category -eq $name -and $_.Row.Visibility -eq 'Visible' }).Count -gt 0
        $exp = $script:Categories[$name].Expander
        $exp.Visibility = if ($any) { 'Visible' } else { 'Collapsed' }
        if ($q -and $any) { $exp.IsExpanded = $true }
    }
}

function Set-Selection {
    param([scriptblock]$Predicate)
    foreach ($it in $script:Items) { $it.CheckBox.IsChecked = [bool](& $Predicate $it) }
    Update-Count
}

function Set-Busy {
    param([bool]$Busy)
    foreach ($n in 'InstallButton', 'ImportButton', 'ExportButton', 'SelectAllButton', 'SelectNoneButton',
        'SelectDefaultsButton', 'DeleteDataButton', 'AdminButton', 'SaveSelButton') {
        $script:UI[$n].IsEnabled = -not $Busy
    }
    $script:UI.CancelButton.IsEnabled = $Busy
    $script:UI.CategoryPanel.IsEnabled = -not $Busy
}

function Set-InstalledMark {
    foreach ($it in $script:Items) {
        if ($script:InstalledIds.ContainsKey($it.Id.ToLowerInvariant())) {
            $it.Status.Text = [char]0x2713 + ' ' + $script:T.Installed
        }
    }
}

try {
    $catalog = Read-Catalog $CatalogPath
}
catch {
    [Windows.MessageBox]::Show("apps.json: $($_.Exception.Message)", 'CmdCrate', 'OK', 'Error') | Out-Null
    exit 1
}
foreach ($c in $catalog) { foreach ($a in $c.Apps) { [void](Add-AppRow $c.Name $a) } }
Update-Count

# ---------------------------------------------------------------------------
# Background winget processes (polled by a DispatcherTimer, UI never freezes)
# ---------------------------------------------------------------------------
$script:Jobs = New-Object System.Collections.Generic.List[object]

function Start-WingetJob {
    param([string[]]$Arguments, [scriptblock]$OnDone, $Context)
    $psi = New-Object Diagnostics.ProcessStartInfo
    $psi.FileName = 'winget'
    $psi.Arguments = ($Arguments | ForEach-Object { if ($_ -match '\s') { '"' + $_ + '"' } else { $_ } }) -join ' '
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.StandardOutputEncoding = [Text.Encoding]::UTF8
    $proc = [Diagnostics.Process]::Start($psi)
    $job = [pscustomobject]@{
        Process = $proc
        Out     = $proc.StandardOutput.ReadToEndAsync()
        Err     = $proc.StandardError.ReadToEndAsync()
        OnDone  = $OnDone
        Context = $Context
    }
    $script:Jobs.Add($job)
    return $job
}

function Get-CleanOutput {
    # Drops winget spinner / progress-bar lines, keeps readable messages.
    param([string]$Text)
    if (-not $Text) { return @() }
    $lines = $Text -split "[`r`n]+" | ForEach-Object { $_.Trim() } | Where-Object {
        $_ -and ($_ -notmatch '^[\s\-\\|/]+$') -and ($_ -notmatch '[▀-▟]') -and ($_ -notmatch '^\d+(\.\d+)?\s*(KB|MB|GB)\s*/')
    }
    return @($lines | Select-Object -Unique)
}

$timer = New-Object Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromMilliseconds(400)
$timer.Add_Tick({
        foreach ($job in $script:Jobs.ToArray()) {
            if (-not $job.Process.HasExited) { continue }
            [void]$script:Jobs.Remove($job)
            try {
                $job.Process.WaitForExit()
                $out = if ($job.Out.IsCompleted) { $job.Out.Result } else { '' }
                & $job.OnDone $job $job.Process.ExitCode $out
            }
            catch { Write-Log $_.Exception.Message 'ERROR' }
            finally { $job.Process.Dispose() }
        }
    })
$timer.Start()

# ---- Installed-apps detection (winget export to a temp file, then deleted) ----
function Start-InstalledCheck {
    $tmp = Join-Path $env:TEMP ('cmdcrate-{0}.json' -f [guid]::NewGuid().ToString('N'))
    $script:UI.StatusText.Text = $script:T.CheckingInstalled
    [void](Start-WingetJob -Arguments @('export', '-o', $tmp, '--source', 'winget', '--accept-source-agreements', '--disable-interactivity') -Context $tmp -OnDone {
            param($job, $code, $out)
            $file = $job.Context
            try {
                if (Test-Path -LiteralPath $file) {
                    foreach ($id in (Get-IdFromFile $file)) { $script:InstalledIds[$id.ToLowerInvariant()] = $true }
                    Set-InstalledMark
                    $n = @($script:Items | Where-Object { $script:InstalledIds.ContainsKey($_.Id.ToLowerInvariant()) }).Count
                    Write-Log ($script:T.CheckedInstalled -f $n)
                }
            }
            finally {
                Remove-Item -LiteralPath $file -Force -ErrorAction SilentlyContinue
                if (-not $script:Installing) { $script:UI.StatusText.Text = $script:T.Ready }
            }
        })
}

# ---- Install queue ----
$script:Queue = New-Object System.Collections.Generic.Queue[object]
$script:Installing = $false
$script:CancelRequested = $false
$script:Stats = @{ ok = 0; already = 0; fail = 0 }
$script:Total = 0
$script:Done = 0

function Start-NextInstall {
    if ($script:CancelRequested) { $script:Queue.Clear() }
    if ($script:Queue.Count -eq 0) {
        $script:Installing = $false
        Set-Busy $false
        $msg = $script:T.Done -f $script:Stats.ok, $script:Stats.already, $script:Stats.fail
        $script:UI.StatusText.Text = $msg
        Write-Log $msg
        return
    }
    $item = $script:Queue.Dequeue()
    $msg = $script:T.Installing -f $item.Name, ($script:Done + 1), $script:Total
    $script:UI.StatusText.Text = $msg
    $item.Status.Foreground = New-Brush '#2563EB'
    $item.Status.Text = '...'
    Write-Log $msg
    [void](Start-WingetJob -Arguments (Get-InstallArgument $item.Id) -Context $item -OnDone {
            param($job, $code, $out)
            $it = $job.Context
            foreach ($l in (Get-CleanOutput $out | Select-Object -Last 6)) { Write-Log ('  ' + $l) }
            $res = Get-ResultText $code
            $script:Stats[$res[0]]++
            $script:Done++
            $script:UI.Progress.Value = $script:Done
            $it.Status.Text = $res[1]
            $it.Status.Foreground = New-Brush $(if ($res[0] -eq 'fail') { '#B91C1C' } else { '#047857' })
            if ($res[0] -ne 'fail') { $it.CheckBox.IsChecked = $false; $script:InstalledIds[$it.Id.ToLowerInvariant()] = $true }
            Write-Log ('{0}: {1}' -f $it.Id, $res[1]) $(if ($res[0] -eq 'fail') { 'ERROR' } else { 'INFO' })
            Update-Count
            Start-NextInstall
        })
}

# ---------------------------------------------------------------------------
# Event handlers
# ---------------------------------------------------------------------------
$ui.SearchBox.Add_TextChanged({ Update-Filter })
$ui.SelectAllButton.Add_Click({ Set-Selection { param($i) $i.Row.Visibility -eq 'Visible' -or $i.CheckBox.IsChecked } })
$ui.SelectNoneButton.Add_Click({ Set-Selection { param($i) $false } })
$ui.SelectDefaultsButton.Add_Click({ Set-Selection { param($i) $i.Default } })

$ui.InstallButton.Add_Click({
        $selected = @($script:Items | Where-Object { $_.CheckBox.IsChecked })
        if ($selected.Count -eq 0) { $script:UI.StatusText.Text = $script:T.NothingSelected; return }
        $answer = [Windows.MessageBox]::Show(($script:T.ConfirmInstall -f $selected.Count), 'CmdCrate', 'YesNo', 'Question')
        if ($answer -ne 'Yes') { return }
        $script:Queue.Clear()
        foreach ($s in $selected) { $script:Queue.Enqueue($s) }
        $script:Total = $selected.Count
        $script:Done = 0
        $script:Stats = @{ ok = 0; already = 0; fail = 0 }
        $script:CancelRequested = $false
        $script:Installing = $true
        $script:UI.Progress.Maximum = $script:Total
        $script:UI.Progress.Value = 0
        Set-Busy $true
        Write-Log $script:T.AdminNote
        Start-NextInstall
    })

$ui.CancelButton.Add_Click({
        $script:CancelRequested = $true
        $script:UI.CancelButton.IsEnabled = $false
        $script:UI.StatusText.Text = $script:T.CancelRequested
        Write-Log $script:T.CancelRequested 'WARN'
    })

$ui.ExportButton.Add_Click({
        $dlg = New-Object Microsoft.Win32.SaveFileDialog
        $dlg.Filter = 'JSON (*.json)|*.json'
        $dlg.FileName = 'cmdcrate-apps.export.json'
        if (-not $dlg.ShowDialog($script:Window)) { return }
        $path = $dlg.FileName
        Set-Busy $true
        $script:UI.CancelButton.IsEnabled = $false
        [void](Start-WingetJob -Arguments @('export', '-o', $path, '--source', 'winget', '--accept-source-agreements', '--disable-interactivity') -Context $path -OnDone {
                param($job, $code, $out)
                Set-Busy $false
                if (Test-Path -LiteralPath $job.Context) {
                    $script:UI.StatusText.Text = $script:T.ExportDone -f $job.Context
                    Write-Log ($script:T.ExportDone -f $job.Context)
                }
                else {
                    Write-Log ($script:T.ExportFail -f $code) 'ERROR'
                }
            })
    })

$ui.ImportButton.Add_Click({
        $dlg = New-Object Microsoft.Win32.OpenFileDialog
        $dlg.Filter = 'JSON (*.json)|*.json|All files (*.*)|*.*'
        if (-not $dlg.ShowDialog($script:Window)) { return }
        try {
            $ids = Get-IdFromFile $dlg.FileName
        }
        catch {
            Write-Log ($script:T.ImportFail -f $_.Exception.Message) 'ERROR'
            return
        }
        foreach ($it in $script:Items) { $it.CheckBox.IsChecked = $false }
        $added = 0
        foreach ($id in $ids) {
            $existing = $script:Items | Where-Object { $_.Id -eq $id } | Select-Object -First 1
            if (-not $existing) {
                $app = [pscustomobject]@{ Id = $id; Name = $id; Description = $script:T.ImportedDesc; Homepage = ''; Default = $false }
                $existing = Add-AppRow $script:T.ImportedCategory $app
                $added++
            }
            $existing.CheckBox.IsChecked = $true
        }
        Set-InstalledMark
        Update-Filter
        Update-Count
        $msg = $script:T.ImportDone -f $ids.Count, $added
        $script:UI.StatusText.Text = $msg
        Write-Log $msg
    })

$ui.SaveSelButton.Add_Click({
        $dlg = New-Object Microsoft.Win32.SaveFileDialog
        $dlg.Filter = 'JSON (*.json)|*.json'
        $dlg.FileName = 'cmdcrate-selection.json'
        if (-not $dlg.ShowDialog($script:Window)) { return }
        $ids = @($script:Items | Where-Object { $_.CheckBox.IsChecked } | ForEach-Object { $_.Id })
        $obj = [ordered]@{ tool = 'CmdCrate'; version = $script:Version; apps = $ids }
        $obj | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath $dlg.FileName -Encoding UTF8
        $script:UI.StatusText.Text = $script:T.SaveDone -f $dlg.FileName
        Write-Log ($script:T.SaveDone -f $dlg.FileName)
    })

$ui.OpenLogsButton.Add_Click({
        if (-not (Test-Path -LiteralPath $script:LogDir)) { New-Item -ItemType Directory -Path $script:LogDir -Force | Out-Null }
        Start-Process explorer.exe -ArgumentList "`"$script:LogDir`""
    })

$ui.DeleteDataButton.Add_Click({
        $answer = [Windows.MessageBox]::Show(($script:T.ConfirmDelete -f $script:DataDir), 'CmdCrate', 'YesNo', 'Warning')
        if ($answer -ne 'Yes') { return }
        $script:FileLogging = $false
        if (Test-Path -LiteralPath $script:DataDir) { Remove-Item -LiteralPath $script:DataDir -Recurse -Force -ErrorAction SilentlyContinue }
        Write-Log $script:T.DeleteDone
    })

$ui.AdminButton.Add_Click({
        if (-not $PSCommandPath) { return }
        $hostExe = (Get-Process -Id $PID).Path
        $relaunchArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-STA', '-File', "`"$PSCommandPath`"",
            '-CatalogPath', "`"$CatalogPath`"", '-Language', $Language)
        if (-not $script:FileLogging) { $relaunchArgs += '-NoLog' }
        try {
            Start-Process -FilePath $hostExe -ArgumentList $relaunchArgs -Verb RunAs
            $script:Window.Close()
        }
        catch { Write-Log $_.Exception.Message 'WARN' }
    })

$script:Window.Add_Closing({
        param($s, $e)
        if ($script:Installing) {
            $answer = [Windows.MessageBox]::Show($script:T.BusyClose, 'CmdCrate', 'YesNo', 'Warning')
            if ($answer -ne 'Yes') { $e.Cancel = $true; return }
        }
        $timer.Stop()
    })

$script:Window.Add_ContentRendered({ Start-InstalledCheck })

Write-Log $script:T.Privacy
[void]$script:Window.ShowDialog()
