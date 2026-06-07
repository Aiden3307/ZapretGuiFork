$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[ERROR] Требуются права Администратора!" -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit 1
}

function Show-Header {
    Clear-Host
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "         SECURE DNS CONFIGURATOR" -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
}

Show-Header
Write-Host "Выберите DNS провайдера:" -ForegroundColor Yellow
Write-Host "  1. Cloudflare DNS (1.1.1.1 / 1.0.0.1) - [РЕКОМЕНДУЕТСЯ]" -ForegroundColor Gray
Write-Host "  2. Google DNS (8.8.8.8 / 8.8.4.4)" -ForegroundColor Gray
Write-Host "  3. Сбросить на автоматический DNS (DHCP)" -ForegroundColor Gray
Write-Host "  0. Отмена" -ForegroundColor Gray
Write-Host ""

$choice = Read-Host "Выберите опцию (0-3)"

if ($choice -eq "0" -or $choice -eq "") {
    exit
}

$primaryDNS = $null
$secondaryDNS = $null
$dohPrimaryTemplate = $null
$dohSecondaryTemplate = $null
$modeName = ""

if ($choice -eq "1") {
    $primaryDNS = "1.1.1.1"
    $secondaryDNS = "1.0.0.1"
    $dohPrimaryTemplate = "https://cloudflare-dns.com/dns-query"
    $dohSecondaryTemplate = "https://cloudflare-dns.com/dns-query"
    $modeName = "Cloudflare Secure DNS"
} elseif ($choice -eq "2") {
    $primaryDNS = "8.8.8.8"
    $secondaryDNS = "8.8.4.4"
    $dohPrimaryTemplate = "https://dns.google/dns-query"
    $dohSecondaryTemplate = "https://dns.google/dns-query"
    $modeName = "Google Secure DNS"
} elseif ($choice -eq "3") {
    $modeName = "Automatic DNS (DHCP)"
} else {
    Write-Host "Неверный выбор." -ForegroundColor Red
    Start-Sleep -Seconds 2
    exit
}

Write-Host "`nПоиск активных сетевых адаптеров..." -ForegroundColor Cyan
$adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.HardwareInterface }

if ($adapters.Count -eq 0) {
    Write-Host "[WARN] Активные сетевые адаптеры не найдены!" -ForegroundColor Yellow
    Start-Sleep -Seconds 3
    exit
}

foreach ($adapter in $adapters) {
    Write-Host "Настройка адаптера: $($adapter.Name) ($($adapter.InterfaceDescription))..." -ForegroundColor DarkGray
    try {
        if ($choice -eq "3") {
            Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ResetServerAddresses
            Write-Host "  [OK] Сброшено на DHCP" -ForegroundColor Green
        } else {
            Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses ($primaryDNS, $secondaryDNS)
            Write-Host "  [OK] Установлены DNS-сервера: $primaryDNS, $secondaryDNS" -ForegroundColor Green
            
            $osBuild = [System.Environment]::OSVersion.Version.Build
            if ($osBuild -ge 22000) {
                Write-Host "  [INFO] Обнаружена Windows 11. Настройка DNS-over-HTTPS (DoH)..." -ForegroundColor Cyan
                Set-DnsClientDohServerAddress -ServerAddress $primaryDNS -DohTemplate $dohPrimaryTemplate -AllowFallbackToUdp $true -ErrorAction SilentlyContinue
                Set-DnsClientDohServerAddress -ServerAddress $secondaryDNS -DohTemplate $dohSecondaryTemplate -AllowFallbackToUdp $true -ErrorAction SilentlyContinue
                Write-Host "  [OK] DoH успешно включен для $primaryDNS и $secondaryDNS" -ForegroundColor Green
            } else {
                Write-Host "  [INFO] DoH не поддерживается этой версией Windows (требуется Windows 11)." -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "  [ОШИБКА] Не удалось настроить адаптер $($adapter.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

Clear-DnsClientCache
Write-Host "`nКэш DNS успешно очищен." -ForegroundColor Green
Write-Host "Настройка завершена! Текущий режим: $modeName" -ForegroundColor Yellow
Start-Sleep -Seconds 3
