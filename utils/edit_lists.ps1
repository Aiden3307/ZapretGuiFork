# Console List Editor for Zapret
$rootDir = Split-Path $PSScriptRoot
$listsDir = Join-Path $rootDir "lists"

function Show-Header {
    Clear-Host
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "         ZAPRET CONSOLE LIST EDITOR" -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
}

function Edit-ListFile {
    param([string]$fileName, [string]$displayName)

    $filePath = Join-Path $listsDir $fileName
    if (-not (Test-Path $filePath)) {
        # Initialize file if not found
        "" | Out-File $filePath -Encoding UTF8
    }

    while ($true) {
        Show-Header
        Write-Host "Редактирование: $displayName" -ForegroundColor Yellow
        Write-Host "Файл: $filePath" -ForegroundColor DarkGray
        Write-Host "---------------------------------------------" -ForegroundColor DarkCyan

        # Read domains
        $items = @()
        if (Test-Path $filePath) {
            $items = Get-Content $filePath | Where-Object { $_.Trim() -ne "" -and -not $_.StartsWith("#") }
        }

        if ($items.Count -eq 0) {
            Write-Host "  [Список пуст]" -ForegroundColor Gray
        } else {
            for ($i = 0; $i -lt $items.Count; $i++) {
                $idx = $i + 1
                Write-Host "  [$idx] $($items[$i])" -ForegroundColor Green
            }
        }

        Write-Host "---------------------------------------------" -ForegroundColor DarkCyan
        Write-Host "1. Добавить домен(ы)" -ForegroundColor Gray
        Write-Host "2. Удалить домен (по номеру или имени)" -ForegroundColor Gray
        Write-Host "3. Очистить весь список" -ForegroundColor Gray
        Write-Host "0. Вернуться назад" -ForegroundColor Gray
        Write-Host ""
        
        $choice = Read-Host "Выберите действие (0-3)"
        
        switch ($choice) {
            "1" {
                $newInput = Read-Host "Введите один или несколько доменов/IP через пробел или запятую"
                if ($newInput.Trim() -ne "") {
                    $newItems = $newInput -split '[\s,]+' | Where-Object { $_.Trim() -ne "" }
                    foreach ($item in $newItems) {
                        $cleaned = $item.Trim().ToLower()
                        if ($items -notcontains $cleaned) {
                            $items += $cleaned
                            Write-Host "Добавлено: $cleaned" -ForegroundColor Green
                        } else {
                            Write-Host "Уже есть в списке: $cleaned" -ForegroundColor Yellow
                        }
                    }
                    $items | Out-File $filePath -Encoding UTF8 -Force
                    Start-Sleep -Seconds 1
                }
            }
            "2" {
                if ($items.Count -eq 0) {
                    Write-Host "Список пуст, нечего удалять." -ForegroundColor Yellow
                    Start-Sleep -Seconds 1
                    continue
                }
                $delInput = Read-Host "Введите номер элемента или имя для удаления"
                if ($delInput.Trim() -ne "") {
                    if ($delInput -match '^\d+$') {
                        $idx = [int]$delInput - 1
                        if ($idx -ge 0 -and $idx -lt $items.Count) {
                            $removed = $items[$idx]
                            $items = $items | Where-Object { $_ -ne $removed }
                            Write-Host "Удалено: $removed" -ForegroundColor Red
                        } else {
                            Write-Host "Неверный номер!" -ForegroundColor Red
                        }
                    } else {
                        $cleanedDel = $delInput.Trim().ToLower()
                        if ($items -contains $cleanedDel) {
                            $items = $items | Where-Object { $_ -ne $cleanedDel }
                            Write-Host "Удалено: $cleanedDel" -ForegroundColor Red
                        } else {
                            Write-Host "Элемент '$cleanedDel' не найден в списке." -ForegroundColor Yellow
                        }
                    }
                    $items | Out-File $filePath -Encoding UTF8 -Force
                    Start-Sleep -Seconds 1
                }
            }
            "3" {
                $confirm = Read-Host "Вы уверены, что хотите очистить весь список? (Y/N)"
                if ($confirm -eq "y" -or $confirm -eq "Y" -or $confirm -eq "д" -or $confirm -eq "Д") {
                    "" | Out-File $filePath -Encoding UTF8 -Force
                    Write-Host "Список очищен." -ForegroundColor Red
                    Start-Sleep -Seconds 1
                }
            }
            "0" {
                return
            }
        }
    }
}

# Main menu loop
while ($true) {
    Show-Header
    Write-Host "Выберите список для редактирования:" -ForegroundColor Yellow
    Write-Host "  1. Общий список обхода (list-general-user.txt)" -ForegroundColor Gray
    Write-Host "  2. Список исключений (list-exclude-user.txt)" -ForegroundColor Gray
    Write-Host "  3. Список исключений IP-адресов (ipset-exclude-user.txt)" -ForegroundColor Gray
    Write-Host "  0. Выход" -ForegroundColor Gray
    Write-Host ""

    $menuChoice = Read-Host "Выберите опцию (0-3)"
    
    switch ($menuChoice) {
        "1" { Edit-ListFile -fileName "list-general-user.txt" -displayName "Общий список обхода" }
        "2" { Edit-ListFile -fileName "list-exclude-user.txt" -displayName "Список исключений" }
        "3" { Edit-ListFile -fileName "ipset-exclude-user.txt" -displayName "Список исключений IP-адресов" }
        "0" { exit }
    }
}
