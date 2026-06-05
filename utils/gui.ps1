# ZAPRET Service Manager WPF GUI

try {
    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore
    Add-Type -AssemblyName WindowsBase
    Add-Type -AssemblyName System.Xaml
    Add-Type -AssemblyName System.Windows.Forms
} catch {
    Write-Host "[ERROR] Ошибка загрузки WPF/WinForms: $($_.Exception.Message)" -ForegroundColor Red
    Start-Sleep -Seconds 5
    exit 1
}

$rootDir  = Split-Path $PSScriptRoot
$listsDir = Join-Path $rootDir "lists"
$utilsDir = Join-Path $rootDir "utils"

# Admin check
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    [System.Windows.MessageBox]::Show(
        "Для работы GUI требуются права Администратора.`nЗапустите через Run GUI.bat.",
        "Требуются права Администратора",
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Warning)
    exit 1
}

# XAML
$xamlString = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="ZAPRET Service Manager" Height="620" Width="850"
        Background="#121214" Foreground="#E2E2E6"
        WindowStartupLocation="CenterScreen" ResizeMode="CanMinimize"
        FontFamily="Segoe UI, Arial">

    <Window.Resources>
        <!-- Shared GroupBox inner Border rounding -->
        <Style TargetType="Border">
            <Setter Property="CornerRadius" Value="6"/>
        </Style>

        <!-- Modern Rounded Button -->
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

        <!-- Accent Button -->
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

        <!-- Danger Button -->
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

        <!-- ComboBox -->
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

        <!-- ComboBoxItem -->
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

        <!-- Header -->
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

        <!-- Main Content -->
        <Grid Grid.Row="2">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="1.2*"/>
                <ColumnDefinition Width="1.8*"/>
            </Grid.ColumnDefinitions>

            <!-- Left Panel -->
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
                            <Button Grid.Column="0" x:Name="btnInstall" Content="Установить"
                                    Style="{StaticResource AccentButton}" Margin="0,0,5,0"/>
                            <Button Grid.Column="1" x:Name="btnRemove" Content="Удалить"
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

            <!-- Right Panel -->
            <Grid Grid.Column="1" Margin="10,0,0,0">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>

                <GroupBox Grid.Row="0" Header=" Инструменты оптимизации " Foreground="#8A8A96"
                          BorderBrush="#26262E" BorderThickness="1" Margin="0,0,0,15">
                    <UniformGrid Columns="2" Rows="2" Margin="5">
                        <Button x:Name="btnAutotune"   Content="⚡ Запустить Autotune"     Style="{StaticResource ModernButton}" Margin="5" Padding="8"/>
                        <Button x:Name="btnEditLists"  Content="📝 Редактировать списки"   Style="{StaticResource ModernButton}" Margin="5" Padding="8"/>
                        <Button x:Name="btnDNS"        Content="🔒 Настроить DNS/DoH"      Style="{StaticResource ModernButton}" Margin="5" Padding="8"/>
                        <Button x:Name="btnOptimize"   Content="🌐 Отключить QUIC/Kyber"   Style="{StaticResource ModernButton}" Margin="5" Padding="8"/>
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

# Control finder (tries FindName, then LogicalTreeHelper, then manual recursion)
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

# Loading-guard: suppresses SelectionChanged handlers during programmatic updates
$script:isLoading = $false

# Bind controls
$txtCurrentStrategy = Find-Control "txtCurrentStrategy"
$statusBadge        = Find-Control "statusBadge"
$statusLed          = Find-Control "statusLed"
$txtStatus          = Find-Control "txtStatus"
$comboConfigs       = Find-Control "comboConfigs"
$btnInstall         = Find-Control "btnInstall"
$btnRemove          = Find-Control "btnRemove"
$comboGameFilter    = Find-Control "comboGameFilter"
$comboIpset         = Find-Control "comboIpset"
$chkAutoUpdate      = Find-Control "chkAutoUpdate"
$btnAutotune        = Find-Control "btnAutotune"
$btnEditLists       = Find-Control "btnEditLists"
$btnDNS             = Find-Control "btnDNS"
$btnOptimize        = Find-Control "btnOptimize"
$txtLog             = Find-Control "txtLog"

# ── Helpers ────────────────────────────────────────────────────────────────────

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
    $comboConfigs.Items.Clear()
    foreach ($f in Get-ConfigFiles) {
        $comboConfigs.Items.Add($f.BaseName) | Out-Null
    }
    if ($comboConfigs.Items.Count -gt 0) { $comboConfigs.SelectedIndex = 0 }
}

# Run service.bat non-interactively by piping menu choices
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

# Launch an external PS script and fire a callback when it exits
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

# ── Settings ───────────────────────────────────────────────────────────────────

function Load-CurrentSettings {
    $script:isLoading = $true
    # Active strategy from registry
    $regPath  = "HKLM\System\CurrentControlSet\Services\zapret"
    $regVal   = "zapret-discord-youtube"
    $strategy = ""
    try { $strategy = (Get-ItemProperty -Path "Registry::$regPath" -ErrorAction SilentlyContinue).$regVal } catch {}

    if ($strategy) {
        $txtCurrentStrategy.Text = "Установленная стратегия: $strategy"
        for ($i = 0; $i -lt $comboConfigs.Items.Count; $i++) {
            if ($comboConfigs.Items[$i] -eq $strategy) { $comboConfigs.SelectedIndex = $i; break }
        }
    } else {
        $txtCurrentStrategy.Text = "Служба не установлена или стратегия не выбрана"
    }

    # Game filter
    $gameFlagFile = Join-Path $utilsDir "game_filter.enabled"
    if (Test-Path $gameFlagFile) {
        $mode = (Get-Content $gameFlagFile -TotalCount 1).Trim().ToLower()
        $comboGameFilter.SelectedIndex = switch ($mode) { "all" { 1 } "tcp" { 2 } "udp" { 3 } default { 0 } }
    } else {
        $comboGameFilter.SelectedIndex = 0
    }

    # IPSet
    $listFile = Join-Path $listsDir "ipset-all.txt"
    if (Test-Path $listFile) {
        if ((Get-Item $listFile).Length -eq 0) {
            $comboIpset.SelectedIndex = 1
        } else {
            $first = [System.IO.File]::ReadLines($listFile) | Select-Object -First 1
            $comboIpset.SelectedIndex = if ($first -and $first.Trim() -eq "203.0.113.113/32") { 2 } else { 0 }
        }
    } else {
        $comboIpset.SelectedIndex = 2
    }

    # Auto-update
    $chkAutoUpdate.IsChecked = (Test-Path (Join-Path $utilsDir "check_updates.enabled"))
    $script:isLoading = $false
}

# ── Status timer (cached brushes — no GC pressure every tick) ──────────────────

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

# ── Event handlers ─────────────────────────────────────────────────────────────

$btnInstall.Add_Click({
    $selected = $comboConfigs.SelectedItem
    if (-not $selected) { Write-Log "Сначала выберите конфигурацию." "warn"; return }

    $batFiles = Get-ConfigFiles
    $idx = $null
    for ($i = 0; $i -lt $batFiles.Count; $i++) {
        if ($batFiles[$i].BaseName -eq $selected) { $idx = $i + 1; break }
    }
    if ($null -eq $idx) { Write-Log "Конфиг файл не найден!" "error"; return }

    Write-Log "Установка службы: $selected (индекс $idx)..."
    Invoke-ServiceBat "echo admin & echo 1 & echo $idx & echo 0"
    Write-Log "Служба успешно установлена!" "ok"
    Load-CurrentSettings
})

$btnRemove.Add_Click({
    Write-Log "Удаление служб zapret/WinDivert..."
    Invoke-ServiceBat "echo admin & echo 2 & echo 0"
    Write-Log "Службы успешно остановлены и удалены!" "ok"
    Load-CurrentSettings
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
        $mode | Out-File $gameFlagFile -Encoding UTF8 -Force
        Write-Log "Игровой фильтр: режим '$mode'."
    }
    Write-Log "Перезапустите службу zapret для применения!" "warn"
})

$comboIpset.Add_SelectionChanged({
    $index    = $comboIpset.SelectedIndex
    if ($index -eq -1 -or $script:isLoading) { return }

    $listFile   = Join-Path $listsDir "ipset-all.txt"
    $backupFile = "$listFile.backup"

    # Helper: back up original list if no backup exists yet
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
                "" | Out-File $listFile -Encoding UTF8 -Force
                Write-Log "Режим IPSet: 'any' (обходить все сайты)."
            }
            2 {
                & $backupIfNeeded
                "203.0.113.113/32" | Out-File $listFile -Encoding UTF8 -Force
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
        "ENABLED" | Out-File $flag -Encoding UTF8 -Force
        Write-Log "Автопроверка обновлений включена."
    } else {
        if (Test-Path $flag) { Remove-Item $flag -Force }
        Write-Log "Автопроверка обновлений отключена."
    }
})

$btnAutotune.Add_Click({
    Write-Log "Запуск Autotune..."
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
            if ($best) {
                Write-Log "Autotune завершен! Лучшая стратегия: $best" "ok"
                Refresh-Configs
                Load-CurrentSettings
                $ans = [System.Windows.MessageBox]::Show(
                    "Autotune определил стратегию: $best.`n`nУстановить сейчас?",
                    "Установка стратегии",
                    [System.Windows.MessageBoxButton]::YesNo,
                    [System.Windows.MessageBoxImage]::Question)
                if ($ans -eq [System.Windows.MessageBoxResult]::Yes) {
                    for ($i = 0; $i -lt $comboConfigs.Items.Count; $i++) {
                        if ($comboConfigs.Items[$i] -eq $best) { $comboConfigs.SelectedIndex = $i; break }
                    }
                    $btnInstall.RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Button]::ClickEvent)))
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

# ── Init ───────────────────────────────────────────────────────────────────────

Write-Log "Запуск GUI менеджера..."
Refresh-Configs
Load-CurrentSettings
$timer.Start()

[void]$window.ShowDialog()
