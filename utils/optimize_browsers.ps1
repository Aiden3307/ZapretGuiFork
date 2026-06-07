$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[ERROR] Требуются права Администратора!" -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit 1
}

function Show-Header {
    Clear-Host
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "         BROWSER NETWORK OPTIMIZER" -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
}

Show-Header
Write-Host "Этот скрипт отключает протоколы QUIC и Kyber (постквантовое шифрование)," -ForegroundColor Gray
Write-Host "которые часто мешают работе обхода блокировок в Chromium браузерах." -ForegroundColor Gray
Write-Host ""
Write-Host "Выберите действие:" -ForegroundColor Yellow
Write-Host "  1. Применить оптимизацию (Отключить QUIC и Kyber) - [РЕКОМЕНДУЕТСЯ]" -ForegroundColor Gray
Write-Host "  2. Отменить изменения (Включить QUIC и Kyber обратно)" -ForegroundColor Gray
Write-Host "  0. Отмена" -ForegroundColor Gray
Write-Host ""

$choice = Read-Host "Выберите опцию (0-2)"

if ($choice -eq "0" -or $choice -eq "") {
    exit
}

$policyKeys = @(
    @{ Name = "Chrome"; Path = "HKLM:\SOFTWARE\Policies\Google\Chrome" },
    @{ Name = "Edge";   Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge" },
    @{ Name = "Yandex"; Path = "HKLM:\SOFTWARE\Policies\YandexBrowser" }
)

if ($choice -eq "1") {
    Write-Host "`nПрименение групповых политик..." -ForegroundColor Cyan
    
    foreach ($item in $policyKeys) {
        $path = $item.Path
        $name = $item.Name
        
        Write-Host "Настройка политик для $name..." -ForegroundColor DarkGray
        
        if (-not (Test-Path $path)) {
            New-Item -Path $path -Force | Out-Null
        }
        
        Set-ItemProperty -Path $path -Name "QuicAllowed" -Value 0 -Type DWord -Force
        Write-Host "  [OK] QUIC отключен (QuicAllowed = 0)" -ForegroundColor Green
        
        if ($name -eq "Chrome" -or $name -eq "Edge") {
            Set-ItemProperty -Path $path -Name "PostQuantumKeyAgreementEnabled" -Value 0 -Type DWord -Force
            Write-Host "  [OK] Kyber отключен (PostQuantumKeyAgreementEnabled = 0)" -ForegroundColor Green
        }
    }
    
    Write-Host "`nОптимизация успешно применена!" -ForegroundColor Yellow
    Write-Host "Пожалуйста, ПЕРЕЗАПУСТИТЕ ваши браузеры (Chrome, Edge, Yandex), чтобы изменения вступили в силу." -ForegroundColor Green
    
} elseif ($choice -eq "2") {
    Write-Host "`nУдаление групповых политик..." -ForegroundColor Cyan
    
    foreach ($item in $policyKeys) {
        $path = $item.Path
        $name = $item.Name
        
        if (Test-Path $path) {
            Write-Host "Откат настроек для $name..." -ForegroundColor DarkGray
            
            Remove-ItemProperty -Path $path -Name "QuicAllowed" -ErrorAction SilentlyContinue
            if ($name -eq "Chrome" -or $name -eq "Edge") {
                Remove-ItemProperty -Path $path -Name "PostQuantumKeyAgreementEnabled" -ErrorAction SilentlyContinue
            }
            
            $properties = Get-ItemProperty -Path $path
            $propNames = $properties.PSObject.Properties | Where-Object { $_.Name -notin "PSPath","PSParentPath","PSChildName","PSDrive","PSProvider" }
            if ($propNames.Count -eq 0) {
                Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
            }
            
            Write-Host "  [OK] Настройки сброшены" -ForegroundColor Green
        }
    }
    
    Write-Host "`nВсе политики успешно удалены. Браузеры вернулись к стандартным настройкам!" -ForegroundColor Yellow
}

Start-Sleep -Seconds 4
