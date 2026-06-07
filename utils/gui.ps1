try {
    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore
    Add-Type -AssemblyName WindowsBase
    Add-Type -AssemblyName System.Xaml
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
} catch {
    Write-Host "[ERROR] Ошибка загрузки WPF/WinForms/Drawing: $($_.Exception.Message)" -ForegroundColor Red
    Start-Sleep -Seconds 5
    exit 1
}

$rootDir  = Split-Path $PSScriptRoot
$listsDir = Join-Path $rootDir "lists"
$utilsDir = Join-Path $rootDir "utils"

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    try {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs
        exit 0
    } catch {
        [System.Windows.MessageBox]::Show(
            "Для работы GUI требуются права Администратора.`nНе удалось запустить с повышенными привилегиями.",
            "Требуются права Администратора",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Error)
        exit 1
    }
}

$xamlString = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="ZAPRET Service Manager" Height="620" Width="850"
        Background="#121214" Foreground="#E2E2E6"
        WindowStartupLocation="CenterScreen" ResizeMode="CanMinimize"
        FontFamily="Segoe UI, Arial">

    <Window.Resources>
        <Style TargetType="Border">
            <Setter Property="CornerRadius" Value="6"/>
        </Style>

        <Style TargetType="Button" x:Key="ModernButton">
            <Setter Property="Background" Value="#1E1E24"/>
            <Setter Property="Foreground" Value="#E2E2E6"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="BorderBrush" Value="#2E2E38"/>
            <Setter Property="Padding" Value="10,6"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="6"
                                Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#282830"/>
                    <Setter Property="BorderBrush" Value="#00F0FF"/>
                </Trigger>
                <Trigger Property="IsPressed" Value="True">
                    <Setter Property="Background" Value="#15151B"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <Style TargetType="Button" x:Key="AccentButton" BasedOn="{StaticResource ModernButton}">
            <Setter Property="Background" Value="#003545"/>
            <Setter Property="BorderBrush" Value="#008EA6"/>
            <Setter Property="Foreground" Value="#00F0FF"/>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#004C63"/>
                    <Setter Property="BorderBrush" Value="#00F0FF"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <Style TargetType="Button" x:Key="DangerButton" BasedOn="{StaticResource ModernButton}">
            <Setter Property="Background" Value="#45001A"/>
            <Setter Property="BorderBrush" Value="#A6003E"/>
            <Setter Property="Foreground" Value="#FF3366"/>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#630026"/>
                    <Setter Property="BorderBrush" Value="#FF3366"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <Style TargetType="ComboBox">
            <Setter Property="Background" Value="#1E1E24"/>
            <Setter Property="Foreground" Value="#E2E2E6"/>
            <Setter Property="BorderBrush" Value="#2E2E38"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="10,6"/>
            <Setter Property="SnapsToDevicePixels" Value="True"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ComboBox">
                        <Grid>
                            <ToggleButton x:Name="ToggleButton"
                                          BorderBrush="{TemplateBinding BorderBrush}"
                                          Background="{TemplateBinding Background}"
                                          Foreground="{TemplateBinding Foreground}"
                                          BorderThickness="{TemplateBinding BorderThickness}"
                                          IsChecked="{Binding IsDropDownOpen, Mode=TwoWay, RelativeSource={RelativeSource TemplatedParent}}"
                                          Focusable="false" ClickMode="Press" Cursor="Hand">
                                <ToggleButton.Template>
                                    <ControlTemplate TargetType="ToggleButton">
                                        <Border x:Name="Border"
                                                Background="{TemplateBinding Background}"
                                                BorderBrush="{TemplateBinding BorderBrush}"
                                                BorderThickness="{TemplateBinding BorderThickness}"
                                                CornerRadius="6">
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition />
                                                    <ColumnDefinition Width="30" />
                                                </Grid.ColumnDefinitions>
                                                <Path Grid.Column="1" x:Name="Arrow"
                                                      Data="M 0 0 L 4 4 L 8 0"
                                                      Stroke="#E2E2E6" StrokeThickness="2"
                                                      HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                            </Grid>
                                        </Border>
                                        <ControlTemplate.Triggers>
                                            <Trigger Property="IsMouseOver" Value="true">
                                                <Setter TargetName="Border" Property="Background" Value="#282830"/>
                                                <Setter TargetName="Border" Property="BorderBrush" Value="#00F0FF"/>
                                            </Trigger>
                                            <Trigger Property="IsChecked" Value="true">
                                                <Setter TargetName="Border" Property="Background" Value="#15151B"/>
                                                <Setter TargetName="Border" Property="BorderBrush" Value="#00F0FF"/>
                                            </Trigger>
                                        </ControlTemplate.Triggers>
                                    </ControlTemplate>
                                </ToggleButton.Template>
                            </ToggleButton>

                            <ContentPresenter x:Name="ContentSite"
                                              IsHitTestVisible="False"
                                              Content="{TemplateBinding SelectionBoxItem}"
                                              ContentTemplate="{TemplateBinding SelectionBoxItemTemplate}"
                                              ContentTemplateSelector="{TemplateBinding ItemTemplateSelector}"
                                              Margin="10,6,30,6"
                                              VerticalAlignment="Center" HorizontalAlignment="Left"/>

                            <Popup x:Name="Popup" Placement="Bottom"
                                   IsOpen="{TemplateBinding IsDropDownOpen}"
                                   AllowsTransparency="True" Focusable="False"
                                   PopupAnimation="Slide">
                                <Grid x:Name="DropDown" SnapsToDevicePixels="True"
                                      MinWidth="{TemplateBinding ActualWidth}"
                                      MaxHeight="{TemplateBinding MaxDropDownHeight}">
                                    <Border x:Name="DropDownBorder"
                                            Background="#1E1E24" BorderBrush="#2E2E38"
                                            BorderThickness="1" CornerRadius="6" Margin="0,2,0,0">
                                        <ScrollViewer SnapsToDevicePixels="True">
                                            <StackPanel IsItemsHost="True" KeyboardNavigation.DirectionalNavigation="Contained"/>
                                        </ScrollViewer>
                                    </Border>
                                </Grid>
                            </Popup>
                        </Grid>
                        <ControlTemplate.Triggers>
                            <Trigger Property="HasItems" Value="false">
                                <Setter TargetName="DropDownBorder" Property="Height" Value="95"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="ComboBoxItem">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="#E2E2E6"/>
            <Setter Property="Padding" Value="10,8"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ComboBoxItem">
                        <Border x:Name="ItemBorder"
                                Background="{TemplateBinding Background}"
                                BorderBrush="Transparent" BorderThickness="0"
                                CornerRadius="4" SnapsToDevicePixels="true" Margin="4,2">
                            <ContentPresenter HorizontalAlignment="Left" VerticalAlignment="Center"
                                              Margin="{TemplateBinding Padding}"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="true">
                                <Setter TargetName="ItemBorder" Property="Background" Value="#2E2E38"/>
                                <Setter Property="Foreground" Value="#00F0FF"/>
                            </Trigger>
                            <Trigger Property="IsSelected" Value="true">
                                <Setter TargetName="ItemBorder" Property="Background" Value="#003545"/>
                                <Setter Property="Foreground" Value="#00F0FF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid Margin="20">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
        </Grid.RowDefinitions>

        <Border Grid.Row="0" Background="#1A1A1E" CornerRadius="8" Padding="15"
                Margin="0,0,0,15" BorderThickness="1" BorderBrush="#26262E">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <StackPanel Grid.Column="0">
                    <TextBlock Text="ZAPRET SERVICE MANAGER" FontWeight="SemiBold" FontSize="20" Foreground="#00F0FF"/>
                    <TextBlock x:Name="txtCurrentStrategy" Text="Текущая стратегия: загрузка..."
                               FontSize="12" Foreground="#8A8A96" Margin="0,3,0,0"/>
                </StackPanel>
                <Border Grid.Column="1" x:Name="statusBadge" CornerRadius="15" Padding="15,6"
                        Background="#261A1C" VerticalAlignment="Center">
                    <StackPanel Orientation="Horizontal">
                        <Ellipse x:Name="statusLed" Width="8" Height="8" Fill="#FF3366"
                                 VerticalAlignment="Center" Margin="0,0,8,0"/>
                        <TextBlock x:Name="txtStatus" Text="НЕ РАБОТАЕТ" FontWeight="Bold"
                                   FontSize="11" Foreground="#FF3366" VerticalAlignment="Center"/>
                    </StackPanel>
                </Border>
            </Grid>
        </Border>

        <Grid Grid.Row="2">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="1.2*"/>
                <ColumnDefinition Width="1.8*"/>
            </Grid.ColumnDefinitions>

            <StackPanel Grid.Column="0" Margin="0,0,10,0">
                <GroupBox Header=" Управление службой " Foreground="#8A8A96"
                          BorderBrush="#26262E" BorderThickness="1" Margin="0,0,0,15">
                    <StackPanel Margin="10">
                        <TextBlock Text="Выберите файл конфигурации:" Margin="0,0,0,5" FontSize="11"/>
                        <ComboBox x:Name="comboConfigs" Margin="0,0,0,12"/>
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>
                            <Button Grid.Column="0" x:Name="btnStart" Content="Запустить"
                                    Style="{StaticResource AccentButton}" Margin="0,0,5,0"/>
                            <Button Grid.Column="1" x:Name="btnStop" Content="Остановить"
                                    Style="{StaticResource DangerButton}" Margin="5,0,0,0"/>
                        </Grid>
                    </StackPanel>
                </GroupBox>

                <GroupBox Header=" Параметры обхода " Foreground="#8A8A96"
                          BorderBrush="#26262E" BorderThickness="1">
                    <StackPanel Margin="10">
                        <TextBlock Text="Игровой фильтр (порты):" FontSize="11" Margin="0,0,0,3"/>
                        <ComboBox x:Name="comboGameFilter" Margin="0,0,0,12">
                            <ComboBoxItem Content="Отключен"/>
                            <ComboBoxItem Content="Включен (TCP и UDP)"/>
                            <ComboBoxItem Content="Включен (только TCP)"/>
                            <ComboBoxItem Content="Включен (только UDP)"/>
                        </ComboBox>

                        <TextBlock Text="Режим IPSet фильтра:" FontSize="11" Margin="0,0,0,3"/>
                        <ComboBox x:Name="comboIpset" Margin="0,0,0,12">
                            <ComboBoxItem Content="loaded (по спискам ipset-all)"/>
                            <ComboBoxItem Content="any (обходить все сайты)"/>
                            <ComboBoxItem Content="none (выключен)"/>
                        </ComboBox>

                        <CheckBox x:Name="chkAutoUpdate" Content="Автопроверка обновлений"
                                  Foreground="#E2E2E6" Margin="0,5,0,5" Cursor="Hand"/>
                    </StackPanel>
                </GroupBox>
            </StackPanel>

            <Grid Grid.Column="1" Margin="10,0,0,0">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>

                <GroupBox Grid.Row="0" Header=" Инструменты оптимизации " Foreground="#8A8A96"
                          BorderBrush="#26262E" BorderThickness="1" Margin="0,0,0,15">
                    <UniformGrid Columns="2" Margin="5">
                        <Button x:Name="btnAutotune"   Content="⚡ Запустить Autotune"     Style="{StaticResource ModernButton}" Margin="5" Padding="8"/>
                        <Button x:Name="btnEditLists"  Content="📝 Редактировать списки"   Style="{StaticResource ModernButton}" Margin="5" Padding="8"/>
                        <Button x:Name="btnDNS"        Content="🔒 Настроить DNS/DoH"      Style="{StaticResource ModernButton}" Margin="5" Padding="8"/>
                        <Button x:Name="btnOptimize"   Content="🌐 Отключить QUIC/Kyber"   Style="{StaticResource ModernButton}" Margin="5" Padding="8"/>
                        <Button x:Name="btnHosts"      Content="📋 Управление обходами" Style="{StaticResource ModernButton}" Margin="5" Padding="8"/>
                        <Button x:Name="btnShortcut"   Content="🔗 Создать ярлык" Style="{StaticResource ModernButton}" Margin="5" Padding="8"/>
                    </UniformGrid>
                </GroupBox>

                <GroupBox Grid.Row="1" Header=" Журнал событий / Логи " Foreground="#8A8A96"
                          BorderBrush="#26262E" BorderThickness="1">
                    <TextBox x:Name="txtLog" Background="#0C0C0E" Foreground="#A9A9B3"
                             BorderThickness="0" FontFamily="Consolas" FontSize="11"
                             AcceptsReturn="True" IsReadOnly="True"
                             VerticalScrollBarVisibility="Auto" Padding="10"/>
                </GroupBox>
            </Grid>
        </Grid>
    </Grid>
</Window>
"@

$stringReader = New-Object System.IO.StringReader($xamlString)
$xmlReader    = [System.Xml.XmlReader]::Create($stringReader)
$window       = [Windows.Markup.XamlReader]::Load($xmlReader)

function Find-Control {
    param([string]$name)
    $ctrl = $window.FindName($name)
    if ($ctrl) { return $ctrl }

    try {
        $ctrl = [System.Windows.LogicalTreeHelper]::FindLogicalNode($window, $name)
        if ($ctrl) { return $ctrl }
    } catch {}

    $recurse = {
        param($parent, $targetName)
        if ($parent.Name -eq $targetName -or
            $parent.GetValue([System.Windows.FrameworkElement]::NameProperty) -eq $targetName) {
            return $parent
        }
        if ($parent -is [System.Windows.Controls.ContentControl] -and
            $parent.Content -is [System.Windows.DependencyObject]) {
            $r = & $recurse $parent.Content $targetName
            if ($r) { return $r }
        }
        if ($parent -is [System.Windows.Controls.Panel]) {
            foreach ($child in $parent.Children) {
                $r = & $recurse $child $targetName
                if ($r) { return $r }
            }
        }
        if ($parent -is [System.Windows.Controls.Decorator] -and
            $parent.Child -is [System.Windows.DependencyObject]) {
            $r = & $recurse $parent.Child $targetName
            if ($r) { return $r }
        }
        return $null
    }
    return & $recurse $window $name
}

$script:isLoading = $false

$txtCurrentStrategy = Find-Control "txtCurrentStrategy"
$statusBadge        = Find-Control "statusBadge"
$statusLed          = Find-Control "statusLed"
$txtStatus          = Find-Control "txtStatus"
$comboConfigs       = Find-Control "comboConfigs"
$btnStart           = Find-Control "btnStart"
$btnStop            = Find-Control "btnStop"
$comboGameFilter    = Find-Control "comboGameFilter"
$comboIpset         = Find-Control "comboIpset"
$chkAutoUpdate      = Find-Control "chkAutoUpdate"
$btnAutotune        = Find-Control "btnAutotune"
$btnEditLists       = Find-Control "btnEditLists"
$btnDNS             = Find-Control "btnDNS"
$btnOptimize        = Find-Control "btnOptimize"
$btnHosts           = Find-Control "btnHosts"
$btnShortcut        = Find-Control "btnShortcut"
$txtLog             = Find-Control "txtLog"

function Write-Log {
    param([string]$message, [string]$type = "info")
    $ts     = Get-Date -Format "HH:mm:ss"
    $prefix = switch ($type) {
        "error" { "[ОШИБКА]" }
        "warn"  { "[ВНИМАНИЕ]" }
        "ok"    { "[УСПЕШНО]" }
        default { "[ИНФО]" }
    }
    $window.Dispatcher.Invoke([Action]{
        $txtLog.AppendText("$ts $prefix $message`r`n")
        $txtLog.ScrollToEnd()
    })
}

function Get-ConfigFiles {
    Get-ChildItem -LiteralPath $rootDir -Filter "*.bat" |
        Where-Object { $_.Name -notlike "service*" -and $_.Name -notlike "Run*" } |
        Sort-Object { [Regex]::Replace($_.Name, '(\d+)', { $args[0].Value.PadLeft(8, '0') }) }
}

function Refresh-Configs {
    $oldIsLoading = $script:isLoading
    $script:isLoading = $true
    $comboConfigs.Items.Clear()
    foreach ($f in Get-ConfigFiles) {
        $comboConfigs.Items.Add($f.BaseName) | Out-Null
    }
    if ($comboConfigs.Items.Count -gt 0) { $comboConfigs.SelectedIndex = 0 }
    $script:isLoading = $oldIsLoading
}

function Invoke-ServiceBat {
    param([string]$inputSequence)
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName          = "cmd.exe"
    $pinfo.Arguments         = "/c `"($inputSequence) | `"$rootDir\service.bat`"`""
    $pinfo.WorkingDirectory  = $rootDir
    $pinfo.RedirectStandardOutput = $true
    $pinfo.RedirectStandardError  = $true
    $pinfo.UseShellExecute   = $false
    $pinfo.CreateNoWindow    = $true
    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $pinfo
    $proc.Start() | Out-Null
    $proc.WaitForExit()
}

function Start-WatchedProcess {
    param([string]$scriptPath, [scriptblock]$onComplete)

    $proc = Start-Process powershell.exe `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" `
        -WorkingDirectory $rootDir -PassThru

    $job = Start-Job -ScriptBlock {
        param($id)
        $p = Get-Process -Id $id -ErrorAction SilentlyContinue
        if ($p) { $p.WaitForExit() }
    } -ArgumentList $proc.Id

    $jobId = $job.Id
    $t     = New-Object System.Windows.Threading.DispatcherTimer
    $t.Interval = [TimeSpan]::FromSeconds(2)
    $t.Add_Tick({
        $j = Get-Job -Id $jobId -ErrorAction SilentlyContinue
        if ($j -and $j.State -ne "Running") {
            Remove-Job $j
            $t.Stop()
            & $onComplete
        }
    })
    $t.Start()
}

function Get-BatArguments {
    param([string]$batPath)
    $lines = Get-Content $batPath
    
    $joinedLines = @()
    $currentLine = ""
    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        if ($trimmed.EndsWith("^")) {
            $currentLine += $trimmed.Substring(0, $trimmed.Length - 1) + " "
        } else {
            $currentLine += $trimmed
            $joinedLines += $currentLine
            $currentLine = ""
        }
    }
    if ($currentLine) { $joinedLines += $currentLine }

    $winwsLine = ""
    foreach ($line in $joinedLines) {
        if ($line -match "winws\.exe") {
            $winwsLine = $line
            break
        }
    }

    if (-not $winwsLine) { return $null }

    $argsStr = ""
    if ($winwsLine -match 'winws\.exe"\s+(.*)') {
        $argsStr = $Matches[1]
    } elseif ($winwsLine -match 'winws\.exe\s+(.*)') {
        $argsStr = $Matches[1]
    } else {
        return $null
    }

    $binPath = (Join-Path $rootDir "bin") + "\"
    $listsPath = (Join-Path $rootDir "lists") + "\"
    
    $gfTCP = "12"
    $gfUDP = "12"
    $gameFlagFile = Join-Path $utilsDir "game_filter.enabled"
    if (Test-Path $gameFlagFile) {
        $mode = (Get-Content $gameFlagFile -TotalCount 1).Trim().ToLower()
        if ($mode -eq "all") { $gfTCP = "1024-65535"; $gfUDP = "1024-65535" }
        elseif ($mode -eq "tcp") { $gfTCP = "1024-65535"; $gfUDP = "12" }
        elseif ($mode -eq "udp") { $gfTCP = "12"; $gfUDP = "1024-65535" }
    }

    $argsStr = [System.Text.RegularExpressions.Regex]::Replace($argsStr, "%BIN%", $binPath, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    $argsStr = [System.Text.RegularExpressions.Regex]::Replace($argsStr, "%%BIN%%", $binPath, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    $argsStr = [System.Text.RegularExpressions.Regex]::Replace($argsStr, "%LISTS%", $listsPath, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    $argsStr = [System.Text.RegularExpressions.Regex]::Replace($argsStr, "%%LISTS%%", $listsPath, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    $argsStr = [System.Text.RegularExpressions.Regex]::Replace($argsStr, "%~dp0", ($rootDir + "\"), [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    
    $argsStr = [System.Text.RegularExpressions.Regex]::Replace($argsStr, "%GameFilterTCP%", $gfTCP, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    $argsStr = [System.Text.RegularExpressions.Regex]::Replace($argsStr, "%GameFilterUDP%", $gfUDP, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    $argsStr = [System.Text.RegularExpressions.Regex]::Replace($argsStr, "%GameFilter%", $gfTCP, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

    return $argsStr.Trim()
}

function Load-CurrentSettings {
    $script:isLoading = $true
    $activeStrategy = ""
    $stateFile = Join-Path $utilsDir "active_strategy.txt"
    if (Test-Path $stateFile) {
        $activeStrategy = (Get-Content $stateFile -TotalCount 1).Trim()
    }
    if (-not $activeStrategy) {
        $regPath  = "HKLM\System\CurrentControlSet\Services\zapret"
        $regVal   = "zapret-discord-youtube"
        try { $activeStrategy = (Get-ItemProperty -Path "Registry::$regPath" -ErrorAction SilentlyContinue).$regVal } catch {}
    }

    $selectedStrategy = $activeStrategy
    if (-not $selectedStrategy) {
        $lastSelectedFile = Join-Path $utilsDir "last_strategy.txt"
        if (Test-Path $lastSelectedFile) {
            $selectedStrategy = (Get-Content $lastSelectedFile -TotalCount 1).Trim()
        }
    }

    if ($activeStrategy) {
        $txtCurrentStrategy.Text = "Текущая стратегия: $activeStrategy"
    } else {
        $txtCurrentStrategy.Text = "Обход не запущен или стратегия не выбрана"
    }

    if ($selectedStrategy) {
        for ($i = 0; $i -lt $comboConfigs.Items.Count; $i++) {
            if ($comboConfigs.Items[$i] -eq $selectedStrategy) { $comboConfigs.SelectedIndex = $i; break }
        }
    }

    $gameFlagFile = Join-Path $utilsDir "game_filter.enabled"
    if (Test-Path $gameFlagFile) {
        $mode = (Get-Content $gameFlagFile -TotalCount 1).Trim().ToLower()
        $comboGameFilter.SelectedIndex = switch ($mode) { "all" { 1 } "tcp" { 2 } "udp" { 3 } default { 0 } }
    } else {
        $comboGameFilter.SelectedIndex = 0
    }

    $listFile = Join-Path $listsDir "ipset-all.txt"
    if (Test-Path $listFile) {
        $content = Get-Content $listFile -Raw
        if ($null -eq $content -or [string]::IsNullOrWhiteSpace($content) -or $content.Trim() -eq "") {
            $comboIpset.SelectedIndex = 1
        } else {
            $first = [System.IO.File]::ReadLines($listFile) | Select-Object -First 1
            $comboIpset.SelectedIndex = if ($first -and $first.Trim() -eq "203.0.113.113/32") { 2 } else { 0 }
        }
    } else {
        $comboIpset.SelectedIndex = 2
    }

    $chkAutoUpdate.IsChecked = (Test-Path (Join-Path $utilsDir "check_updates.enabled"))
    $script:isLoading = $false
}

$brushGreen      = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromRgb(0,   255, 135))
$brushRed        = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromRgb(255, 51,  102))
$brushBgGreen    = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromRgb(26,  46,  32))
$brushBgRed      = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromRgb(38,  26,  28))

$timer          = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(1.5)
$timer.Add_Tick({
    if (Get-Process -Name "winws" -ErrorAction SilentlyContinue) {
        $statusBadge.Background = $brushBgGreen
        $statusLed.Fill         = $brushGreen
        $txtStatus.Text         = "РАБОТАЕТ"
        $txtStatus.Foreground   = $brushGreen
    } else {
        $statusBadge.Background = $brushBgRed
        $statusLed.Fill         = $brushRed
        $txtStatus.Text         = "НЕ РАБОТАЕТ"
        $txtStatus.Foreground   = $brushRed
    }
})

$btnStart.Add_Click({
    $selected = $comboConfigs.SelectedItem
    if (-not $selected) { Write-Log "Сначала выберите конфигурацию." "warn"; return }

    $batPath = Join-Path $rootDir "${selected}.bat"
    if (-not (Test-Path $batPath)) { Write-Log "Файл конфигурации не найден!" "error"; return }

    $argsStr = Get-BatArguments $batPath
    if (-not $argsStr) { Write-Log "Не удалось извлечь параметры запуска из файла!" "error"; return }

    $service = Get-Service -Name "zapret" -ErrorAction SilentlyContinue
    if ($service -and $service.Status -eq "Running") {
        Write-Log "Остановка службы для исключения конфликтов..."
        Stop-Service "zapret" -Force -ErrorAction SilentlyContinue
    }

    $winwsProc = Get-Process -Name "winws" -ErrorAction SilentlyContinue
    if ($winwsProc) {
        Write-Log "Завершение работающих процессов winws..."
        Stop-Process -Name "winws" -Force -ErrorAction SilentlyContinue
    }

    Write-Log "Запуск процесса winws со стратегией: $selected..."
    try {
        $stateFile = Join-Path $utilsDir "active_strategy.txt"
        $selected | Out-File $stateFile -Encoding ASCII -Force

        Start-Process -FilePath "$rootDir\bin\winws.exe" -ArgumentList $argsStr -WorkingDirectory "$rootDir\bin" -WindowStyle Hidden
        Write-Log "Обход успешно запущен!" "ok"
    } catch {
        Write-Log "Ошибка при запуске: $($_.Exception.Message)" "error"
    }
    Load-CurrentSettings
})

function Stop-Bypass {
    $service = Get-Service -Name "zapret" -ErrorAction SilentlyContinue
    if ($service -and $service.Status -eq "Running") {
        Stop-Service "zapret" -Force -ErrorAction SilentlyContinue
    }
    $winwsProc = Get-Process -Name "winws" -ErrorAction SilentlyContinue
    if ($winwsProc) {
        Stop-Process -Name "winws" -Force -ErrorAction SilentlyContinue
    }
    $divert = Get-Service -Name "WinDivert" -ErrorAction SilentlyContinue
    if ($divert -and $divert.Status -eq "Running") {
        Stop-Service "WinDivert" -Force -ErrorAction SilentlyContinue
    }
    $divert14 = Get-Service -Name "WinDivert14" -ErrorAction SilentlyContinue
    if ($divert14 -and $divert14.Status -eq "Running") {
        Stop-Service "WinDivert14" -Force -ErrorAction SilentlyContinue
    }
    $stateFile = Join-Path $utilsDir "active_strategy.txt"
    if (Test-Path $stateFile) {
        Remove-Item $stateFile -Force -ErrorAction SilentlyContinue
    }
}

$btnStop.Add_Click({
    Write-Log "Остановка обхода..."
    Stop-Bypass
    Write-Log "Обход успешно остановлен!" "ok"
    Load-CurrentSettings
})

$comboConfigs.Add_SelectionChanged({
    if ($script:isLoading) { return }
    $selected = $comboConfigs.SelectedItem
    if ($selected) {
        $lastSelectedFile = Join-Path $utilsDir "last_strategy.txt"
        $selected | Out-File $lastSelectedFile -Encoding ASCII -Force
    }
})

$comboGameFilter.Add_SelectionChanged({
    $index = $comboGameFilter.SelectedIndex
    if ($index -eq -1 -or $script:isLoading) { return }

    $gameFlagFile = Join-Path $utilsDir "game_filter.enabled"
    if ($index -eq 0) {
        if (Test-Path $gameFlagFile) { Remove-Item $gameFlagFile -Force }
        Write-Log "Игровой фильтр отключен."
    } else {
        $mode = switch ($index) { 1 { "all" } 2 { "tcp" } 3 { "udp" } }
        $mode | Out-File $gameFlagFile -Encoding ASCII -Force
        Write-Log "Игровой фильтр: режим '$mode'."
    }
    Write-Log "Перезапустите службу zapret для применения!" "warn"
})

$comboIpset.Add_SelectionChanged({
    $index    = $comboIpset.SelectedIndex
    if ($index -eq -1 -or $script:isLoading) { return }

    $listFile   = Join-Path $listsDir "ipset-all.txt"
    $backupFile = "$listFile.backup"

    $backupIfNeeded = {
        if ((Test-Path $listFile) -and -not (Test-Path $backupFile)) {
            Rename-Item $listFile "ipset-all.txt.backup" -Force
        }
    }

    try {
        switch ($index) {
            0 {
                if (Test-Path $backupFile) {
                    if (Test-Path $listFile) { Remove-Item $listFile -Force -ErrorAction Stop }
                    Rename-Item $backupFile "ipset-all.txt" -Force -ErrorAction Stop
                    Write-Log "Режим IPSet: 'loaded' (только сайты из списков)."
                } else {
                    Write-Log "Файл резервной копии не найден. Обновите список." "warn"
                }
            }
            1 {
                & $backupIfNeeded
                [System.IO.File]::WriteAllText($listFile, "")
                Write-Log "Режим IPSet: 'any' (обходить все сайты)."
            }
            2 {
                & $backupIfNeeded
                [System.IO.File]::WriteAllText($listFile, "203.0.113.113/32`r`n")
                Write-Log "Режим IPSet: 'none' (обход отключен)."
            }
        }
    } catch {
        Write-Log "Ошибка при изменении IPSet: $($_.Exception.Message)" "error"
    }
    Write-Log "Перезапустите службу zapret для применения!" "warn"
})

$chkAutoUpdate.Add_Click({
    $flag = Join-Path $utilsDir "check_updates.enabled"
    if ($chkAutoUpdate.IsChecked) {
        "ENABLED" | Out-File $flag -Encoding ASCII -Force
        Write-Log "Автопроверка обновлений включена."
    } else {
        if (Test-Path $flag) { Remove-Item $flag -Force }
        Write-Log "Автопроверка обновлений отключена."
    }
})

$btnAutotune.Add_Click({
    Write-Log "Запуск Autotune. Пожалуйста, подождите..."
    $btnAutotune.IsEnabled = $false
    $btnAutotune.Content = "⏳ Выполняется Autotune..."

    $bestConfigTmp = Join-Path $utilsDir "best_strategy.tmp"
    if (Test-Path $bestConfigTmp) { Remove-Item $bestConfigTmp -Force }

    $testScript = Join-Path $utilsDir "test zapret.ps1"
    $proc = Start-Process powershell.exe `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$testScript`" -TestType standard -Mode all -Silent" `
        -PassThru

    $job = Start-Job -ScriptBlock {
        param($procId, $tmp)
        $p = Get-Process -Id $procId -ErrorAction SilentlyContinue
        if ($p) { $p.WaitForExit() }
        if (Test-Path $tmp) { return (Get-Content $tmp -TotalCount 1).Trim() }
        return $null
    } -ArgumentList $proc.Id, $bestConfigTmp

    $jobId = $job.Id
    $t     = New-Object System.Windows.Threading.DispatcherTimer
    $t.Interval = [TimeSpan]::FromSeconds(2)
    $t.Add_Tick({
        $j = Get-Job -Id $jobId -ErrorAction SilentlyContinue
        if ($j -and $j.State -ne "Running") {
            $best = Receive-Job $j
            Remove-Job $j
            $t.Stop()

            $btnAutotune.IsEnabled = $true
            $btnAutotune.Content = "⚡ Запустить Autotune"

            if ($best) {
                Write-Log "Autotune завершен! Выбрана лучшая стратегия: $best" "ok"
                Refresh-Configs
                
                $found = $false
                for ($i = 0; $i -lt $comboConfigs.Items.Count; $i++) {
                    if ($comboConfigs.Items[$i] -eq $best) {
                        $comboConfigs.SelectedIndex = $i
                        $found = $true
                        break
                    }
                }
                if (-not $found) {
                    Write-Log "Ошибка: найденная стратегия $best не найдена в списке файлов!" "error"
                }
            } else {
                Write-Log "Autotune завершился без результата." "warn"
            }
        }
    })
    $t.Start()
})

$btnEditLists.Add_Click({
    Write-Log "Открытие редактора списков..."
    Start-Process powershell.exe `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$(Join-Path $utilsDir 'edit_lists.ps1')`"" `
        -WorkingDirectory $rootDir
})

$btnDNS.Add_Click({
    Write-Log "Запуск конфигуратора DNS..."
    Start-WatchedProcess -scriptPath (Join-Path $utilsDir "configure_dns.ps1") -onComplete {
        Write-Log "Настройка DNS завершена." "ok"
        Load-CurrentSettings
    }
})

$btnOptimize.Add_Click({
    Write-Log "Запуск оптимизатора браузеров..."
    Start-WatchedProcess -scriptPath (Join-Path $utilsDir "optimize_browsers.ps1") -onComplete {
        Write-Log "Настройка групповых политик браузеров завершена." "ok"
        Load-CurrentSettings
    }
})

$btnShortcut.Add_Click({
    try {
        $desktopPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "ZAPRET GUI.lnk")
        $startMenuPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Programs"), "ZAPRET GUI.lnk")
        $iconLocation = Join-Path $rootDir "bin\winws.exe"
        $guiScriptPath = Join-Path $utilsDir "gui.ps1"
        
        $wshShell = New-Object -ComObject WScript.Shell
        
        $shortcutDesktop = $wshShell.CreateShortcut($desktopPath)
        $shortcutDesktop.TargetPath = "powershell.exe"
        $shortcutDesktop.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$guiScriptPath`""
        $shortcutDesktop.WorkingDirectory = $rootDir
        if (Test-Path $iconLocation) {
            $shortcutDesktop.IconLocation = "$iconLocation,0"
        }
        $shortcutDesktop.Save()

        $shortcutStartMenu = $wshShell.CreateShortcut($startMenuPath)
        $shortcutStartMenu.TargetPath = "powershell.exe"
        $shortcutStartMenu.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$guiScriptPath`""
        $shortcutStartMenu.WorkingDirectory = $rootDir
        if (Test-Path $iconLocation) {
            $shortcutStartMenu.IconLocation = "$iconLocation,0"
        }
        $shortcutStartMenu.Save()
        
        Write-Log "Ярлыки на рабочем столе и в меню Пуск успешно созданы." "ok"
    } catch {
        [System.Windows.MessageBox]::Show(
            "Не удалось создать ярлык: $($_.Exception.Message)",
            "Ошибка",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Error)
        Write-Log "Ошибка создания ярлыка: $($_.Exception.Message)" "error"
    }
})

$btnHosts.Add_Click({
    $hostsXamlString = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Управление обходами" Height="550" Width="780"
        Background="#121214" Foreground="#E2E2E6"
        WindowStartupLocation="CenterOwner" ResizeMode="CanResize"
        FontFamily="Segoe UI, Arial">
    <Window.Resources>
        <Style TargetType="Button" x:Key="HostsBtn">
            <Setter Property="Background" Value="#1E1E24"/>
            <Setter Property="Foreground" Value="#E2E2E6"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="BorderBrush" Value="#2E2E38"/>
            <Setter Property="Padding" Value="10,6"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Margin" Value="0,0,0,8"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="6"
                                Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#282830"/>
                    <Setter Property="BorderBrush" Value="#00F0FF"/>
                </Trigger>
                <Trigger Property="IsPressed" Value="True">
                    <Setter Property="Background" Value="#15151B"/>
                </Trigger>
            </Style.Triggers>
        </Style>
        <Style TargetType="Button" x:Key="HostsAccentBtn" BasedOn="{StaticResource HostsBtn}">
            <Setter Property="Background" Value="#003545"/>
            <Setter Property="BorderBrush" Value="#008EA6"/>
            <Setter Property="Foreground" Value="#00F0FF"/>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#004C63"/>
                    <Setter Property="BorderBrush" Value="#00F0FF"/>
                </Trigger>
            </Style.Triggers>
        </Style>
        <Style TargetType="Button" x:Key="HostsDangerBtn" BasedOn="{StaticResource HostsBtn}">
            <Setter Property="Background" Value="#45001A"/>
            <Setter Property="BorderBrush" Value="#A6003E"/>
            <Setter Property="Foreground" Value="#FF3366"/>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#630026"/>
                    <Setter Property="BorderBrush" Value="#FF3366"/>
                </Trigger>
            </Style.Triggers>
        </Style>
    </Window.Resources>
    <Grid Margin="15">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <StackPanel Grid.Row="0" Margin="0,0,0,10">
            <TextBlock Text="УПРАВЛЕНИЕ ОБХОДАМИ (HOSTS)" FontWeight="SemiBold" FontSize="16" Foreground="#00F0FF"/>
            <TextBlock Text="Файл: C:\Windows\System32\drivers\etc\hosts" FontSize="11" Foreground="#8A8A96" Margin="0,2,0,0"/>
        </StackPanel>
        <Grid Grid.Row="1" Margin="0,0,0,10">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="220"/>
            </Grid.ColumnDefinitions>
            <TextBox Grid.Column="0" x:Name="txtHostsContent" Background="#0C0C0E" Foreground="#A9A9B3"
                     BorderBrush="#2E2E38" BorderThickness="1" FontFamily="Consolas" FontSize="12"
                     AcceptsReturn="True" AcceptsTab="True" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto" Padding="10"/>
            <StackPanel Grid.Column="1" Margin="10,0,0,0">
                <TextBlock Text="Быстрые действия:" FontWeight="Bold" FontSize="12" Foreground="#8A8A96" Margin="0,0,0,8"/>
                <Button x:Name="btnHostsSave" Content="💾 Сохранить изменения" Style="{StaticResource HostsAccentBtn}" Padding="8"/>
                <Button x:Name="btnHostsTwitch" Content="🎮 Добавить обход Twitch" Style="{StaticResource HostsBtn}" Padding="8"/>
                <Button x:Name="btnHostsTelegram" Content="✈️ Добавить обход Telegram" Style="{StaticResource HostsBtn}" Padding="8"/>
                <Button x:Name="btnHostsClearZapret" Content="🧹 Очистить блоки обхода" Style="{StaticResource HostsBtn}" Padding="8"/>
                <Button x:Name="btnHostsRestore" Content="🔄 Восстановить бэкап" Style="{StaticResource HostsDangerBtn}" Padding="8"/>
            </StackPanel>
        </Grid>
        <Grid Grid.Row="2">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <TextBlock x:Name="txtHostsStatus" Text="Готово" Foreground="#8A8A96" VerticalAlignment="Center" FontSize="11"/>
            <Button Grid.Column="1" x:Name="btnHostsClose" Content="Закрыть" Style="{StaticResource HostsBtn}" Width="100" Margin="0"/>
        </Grid>
    </Grid>
</Window>
"@

    $stringReader = New-Object System.IO.StringReader($hostsXamlString)
    $xmlReader    = [System.Xml.XmlReader]::Create($stringReader)
    $hostsWindow  = [Windows.Markup.XamlReader]::Load($xmlReader)
    $hostsWindow.Owner = $window

    $txtHostsContent     = $hostsWindow.FindName("txtHostsContent")
    $btnHostsSave        = $hostsWindow.FindName("btnHostsSave")
    $btnHostsTwitch      = $hostsWindow.FindName("btnHostsTwitch")
    $btnHostsTelegram    = $hostsWindow.FindName("btnHostsTelegram")
    $btnHostsClearZapret = $hostsWindow.FindName("btnHostsClearZapret")
    $btnHostsRestore     = $hostsWindow.FindName("btnHostsRestore")
    $btnHostsClose       = $hostsWindow.FindName("btnHostsClose")
    $txtHostsStatus      = $hostsWindow.FindName("txtHostsStatus")

    $hostsFile = "$env:SystemRoot\System32\drivers\etc\hosts"

    if (Test-Path $hostsFile) {
        $txtHostsContent.Text = [System.IO.File]::ReadAllText($hostsFile)
    }

    $btnHostsSave.Add_Click({
        try {
            if (-not (Test-Path "$hostsFile.bak")) {
                Copy-Item $hostsFile "$hostsFile.bak" -Force
            }
            [System.IO.File]::WriteAllText($hostsFile, $txtHostsContent.Text, [System.Text.Encoding]::UTF8)
            ipconfig /flushdns | Out-Null
            $txtHostsStatus.Text = "Изменения сохранены! Кэш DNS сброшен."
            $txtHostsStatus.Foreground = $brushGreen
            Write-Log "Файл hosts сохранен вручную. Кэш DNS сброшен." "ok"
        } catch {
            $txtHostsStatus.Text = "Ошибка сохранения: $($_.Exception.Message)"
            $txtHostsStatus.Foreground = $brushRed
            Write-Log "Ошибка сохранения hosts: $($_.Exception.Message)" "error"
        }
    })

    $btnHostsTwitch.Add_Click({
        $tText = $txtHostsContent.Text
        $twitchPattern = "(?s)# === TWITCH BYPASS START ===.*?# === TWITCH BYPASS END ==="
        if ($tText -match $twitchPattern) {
            $tText = $tText -replace $twitchPattern, ""
        }
        $oldPattern = "(?s)# Twitch Bypass\r?\n(151\.101\.2\.167 [a-zA-Z0-9.-]+\r?\n)+"
        if ($tText -match $oldPattern) {
            $tText = $tText -replace $oldPattern, ""
        }
        while ($tText -match "\r\n\r\n\r\n") {
            $tText = $tText -replace "\r\n\r\n\r\n", "`r`n`r`n"
        }
        $txtHostsContent.Text = $tText.TrimEnd() + "`r`n"
        $txtHostsStatus.Text = "Домены добавлены в list-general-user.txt. Записи hosts не требуются и были удалены."
        $txtHostsStatus.Foreground = $brushGreen

        $listFile = Join-Path $listsDir "list-general-user.txt"
        $currentDomains = @()
        if (Test-Path $listFile) {
            $currentDomains = Get-Content $listFile | Where-Object { $_.Trim() -ne "" }
        }
        $domainsToAdd = @(
            "twitchcdn.net", "twitch.tv", "ext-twitch.tv", "assets.twitch.tv",
            "scorecardresearch.com", "live-video.net", "gstatic.com", "jtvnw.net",
            "amazon-adsystem.com", "cloudfront.net", "ttvnw.net"
        )
        $addedCount = 0
        foreach ($d in $domainsToAdd) {
            if ($currentDomains -notcontains $d) {
                $currentDomains += $d
                $addedCount++
            }
        }
        if ($addedCount -gt 0) {
            $currentDomains | Out-File $listFile -Encoding UTF8 -Force
            Write-Log "Добавлены домены Twitch в список обхода list-general-user.txt." "ok"
        }
    })

    $btnHostsTelegram.Add_Click({
        $telegramBlock = @"
# === TELEGRAM BYPASS START ===
149.154.167.220 my.telegram.org
149.154.167.220 oauth.telegram.org
149.154.167.220 cdn.telesco.pe
149.154.167.220 cdn1.telesco.pe
149.154.167.220 cdn2.telesco.pe
149.154.167.220 cdn3.telesco.pe
149.154.167.220 cdn4.telesco.pe
149.154.167.220 cdn5.telesco.pe
149.154.167.220 core.telegram.org
149.154.167.220 zws4.web.telegram.org
149.154.167.220 vesta.web.telegram.org
149.154.167.220 vesta-1.web.telegram.org
149.154.167.220 venus-1.web.telegram.org
149.154.167.220 telegram.me
149.154.167.220 telegram.dog
149.154.167.220 telegram.space
149.154.167.220 telesco.pe
149.154.167.220 tg.dev
149.154.167.220 telegram.org
149.154.167.220 t.me
149.154.167.220 api.telegram.org
149.154.167.220 td.telegram.org
149.154.167.220 venus.web.telegram.org
149.154.167.220 web.telegram.org
# === TELEGRAM BYPASS END ===
"@
        $tText = $txtHostsContent.Text
        $tgPattern = "(?s)# === TELEGRAM BYPASS START ===.*?# === TELEGRAM BYPASS END ==="
        if ($tText -match $tgPattern) {
            $tText = $tText -replace $tgPattern, $telegramBlock
        } else {
            $tText = $tText.TrimEnd() + "`r`n`r`n" + $telegramBlock + "`r`n"
        }
        $txtHostsContent.Text = $tText
        $txtHostsStatus.Text = "Добавлены записи Telegram в поле! Сохраните изменения."
        $txtHostsStatus.Foreground = $brushGreen

        $listFile = Join-Path $listsDir "list-general-user.txt"
        $currentDomains = @()
        if (Test-Path $listFile) {
            $currentDomains = Get-Content $listFile | Where-Object { $_.Trim() -ne "" }
        }
        $domainsToAdd = @("telegram.org", "t.me", "telegram.me")
        $addedCount = 0
        foreach ($d in $domainsToAdd) {
            if ($currentDomains -notcontains $d) {
                $currentDomains += $d
                $addedCount++
            }
        }
        if ($addedCount -gt 0) {
            $currentDomains | Out-File $listFile -Encoding UTF8 -Force
            Write-Log "Добавлены домены Telegram в список обхода list-general-user.txt." "ok"
        }
    })



    $btnHostsClearZapret.Add_Click({
        $tText = $txtHostsContent.Text
        $p1 = "(?s)\r?\n?\r?\n?# === ZAPRET HOSTS START ===.*?# === ZAPRET HOSTS END ===\r?\n?"
        $p2 = "(?s)\r?\n?\r?\n?# === TWITCH BYPASS START ===.*?# === TWITCH BYPASS END ===\r?\n?"
        $p3 = "(?s)\r?\n?\r?\n?# === TELEGRAM BYPASS START ===.*?# === TELEGRAM BYPASS END ===\r?\n?"
        $tText = $tText -replace $p1, ""
        $tText = $tText -replace $p2, ""
        $tText = $tText -replace $p3, ""
        $txtHostsContent.Text = $tText.TrimEnd() + "`r`n"
        $txtHostsStatus.Text = "Все блоки ZAPRET очищены из поля! Сохраните изменения."
        $txtHostsStatus.Foreground = $brushGreen
    })

    $btnHostsRestore.Add_Click({
        $bakFile = "$hostsFile.bak"
        if (Test-Path $bakFile) {
            $txtHostsContent.Text = [System.IO.File]::ReadAllText($bakFile)
            $txtHostsStatus.Text = "Резервная копия восстановлена в поле! Сохраните изменения."
            $txtHostsStatus.Foreground = $brushGreen
        } else {
            $txtHostsStatus.Text = "Бэкап hosts.bak не найден!"
            $txtHostsStatus.Foreground = $brushRed
        }
    })

    $btnHostsClose.Add_Click({
        $hostsWindow.Close()
    })

    [void]$hostsWindow.ShowDialog()
})

$script:notifyIcon = New-Object System.Windows.Forms.NotifyIcon
try {
    $iconPath = Join-Path $rootDir "bin\winws.exe"
    if (Test-Path $iconPath) {
        $script:notifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
    } else {
        $script:notifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon([System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName)
    }
} catch {
    $script:notifyIcon.Icon = [System.Drawing.SystemIcons]::Application
}
$script:notifyIcon.Text = "ZAPRET Service Manager"
$script:notifyIcon.Visible = $false

$contextMenu = New-Object System.Windows.Forms.ContextMenu
$menuRestore = New-Object System.Windows.Forms.MenuItem("Открыть")
$menuExit = New-Object System.Windows.Forms.MenuItem("Выход")
$contextMenu.MenuItems.AddRange(@($menuRestore, $menuExit))
$script:notifyIcon.ContextMenu = $contextMenu

$menuRestore.add_Click({
    $window.Dispatcher.Invoke([Action]{
        $window.WindowState = [System.Windows.WindowState]::Normal
        $script:notifyIcon.Visible = $false
        if ($script:dispatcherFrame) {
            $script:dispatcherFrame.Continue = $false
        }
    })
})

$menuExit.add_Click({
    $script:notifyIcon.Visible = $false
    $script:notifyIcon.Dispose()
    Stop-Bypass
    [System.Environment]::Exit(0)
})

$script:notifyIcon.add_MouseClick({
    param($sender, $e)
    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        $window.Dispatcher.Invoke([Action]{
            $window.WindowState = [System.Windows.WindowState]::Normal
            $script:notifyIcon.Visible = $false
            if ($script:dispatcherFrame) {
                $script:dispatcherFrame.Continue = $false
            }
        })
    }
})

$window.add_Closing({
    param($sender, $e)
    $e.Cancel = $true
    
    $exitXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Выход из программы" Height="150" Width="380"
        Background="#121214" Foreground="#E2E2E6"
        WindowStartupLocation="CenterOwner" ResizeMode="NoResize"
        FontFamily="Segoe UI, Arial">
    <Window.Resources>
        <Style TargetType="Button" x:Key="ExitBtn">
            <Setter Property="Background" Value="#1E1E24"/>
            <Setter Property="Foreground" Value="#E2E2E6"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="BorderBrush" Value="#2E2E38"/>
            <Setter Property="Padding" Value="10,6"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="6"
                                Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#282830"/>
                    <Setter Property="BorderBrush" Value="#8A8A96"/>
                </Trigger>
                <Trigger Property="IsPressed" Value="True">
                    <Setter Property="Background" Value="#15151B"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <Style TargetType="Button" x:Key="ExitAccentBtn" BasedOn="{StaticResource ExitBtn}">
            <Setter Property="Background" Value="#003545"/>
            <Setter Property="BorderBrush" Value="#008EA6"/>
            <Setter Property="Foreground" Value="#00F0FF"/>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#004C63"/>
                    <Setter Property="BorderBrush" Value="#00F0FF"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <Style TargetType="Button" x:Key="ExitDangerBtn" BasedOn="{StaticResource ExitBtn}">
            <Setter Property="Background" Value="#45001A"/>
            <Setter Property="BorderBrush" Value="#A6003E"/>
            <Setter Property="Foreground" Value="#FF3366"/>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#630026"/>
                    <Setter Property="BorderBrush" Value="#FF3366"/>
                </Trigger>
            </Style.Triggers>
        </Style>
    </Window.Resources>
    <Grid Margin="15">
        <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <TextBlock Grid.Row="0" Text="Закрыть программу полностью или свернуть в трей?" 
                   HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="12" Foreground="#E2E2E6"/>
        <UniformGrid Grid.Row="1" Columns="3" Rows="1">
            <Button x:Name="btnExitClose" Content="Закрыть" Margin="5" Style="{StaticResource ExitDangerBtn}"/>
            <Button x:Name="btnExitTray" Content="В трей" Margin="5" Style="{StaticResource ExitAccentBtn}"/>
            <Button x:Name="btnExitCancel" Content="Отмена" Margin="5" Style="{StaticResource ExitBtn}"/>
        </UniformGrid>
    </Grid>
</Window>
"@
    $sr = New-Object System.IO.StringReader($exitXaml)
    $xr = [System.Xml.XmlReader]::Create($sr)
    $exitWin = [Windows.Markup.XamlReader]::Load($xr)
    $exitWin.Owner = $window
    
    $btnExitClose = $exitWin.FindName("btnExitClose")
    $btnExitTray = $exitWin.FindName("btnExitTray")
    $btnExitCancel = $exitWin.FindName("btnExitCancel")
    
    $btnExitClose.add_Click({
        $script:notifyIcon.Visible = $false
        $script:notifyIcon.Dispose()
        $exitWin.Close()
        $timer.Stop()
        Stop-Bypass
        [System.Environment]::Exit(0)
    })
    
    $btnExitTray.add_Click({
        $script:notifyIcon.Visible = $true
        $window.Hide()
        $exitWin.Close()
    })
    
    $btnExitCancel.add_Click({
        $exitWin.Close()
    })
    
    [void]$exitWin.ShowDialog()
})

Write-Log "Запуск GUI менеджера..."
Refresh-Configs
Load-CurrentSettings
$timer.Start()

while ($true) {
    [void]$window.ShowDialog()
    
    if ($script:notifyIcon.Visible) {
        $script:dispatcherFrame = New-Object System.Windows.Threading.DispatcherFrame
        [System.Windows.Threading.Dispatcher]::PushFrame($script:dispatcherFrame)
    } else {
        break
    }
}
