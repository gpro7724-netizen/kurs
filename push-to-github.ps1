# Скрипт: читает токен из env.env, делает commit и push в новый репозиторий
# Запуск: установи Git (https://git-scm.com), затем в PowerShell: .\push-to-github.ps1

$ErrorActionPreference = "Stop"
$projectRoot = $PSScriptRoot
Set-Location $projectRoot

# Читаем токен из env.env (ВАЖНО: только из этого файла)
$envFile = Join-Path $projectRoot "env.env"
if (-not (Test-Path $envFile)) {
    Write-Error "Файл env.env не найден в $projectRoot"
}
$line = Get-Content $envFile | Where-Object { $_ -match '^TELEGRAM_TOKEN=(.+)$' } | Select-Object -First 1
if (-not $line -or $line -notmatch '^TELEGRAM_TOKEN=(.+)$') {
    Write-Error "В env.env не найден TELEGRAM_TOKEN"
}
$token = $matches[1].Trim()
$remoteUrl = "https://${token}@github.com/gpro7724-netizen/kurs.git"

# Проверяем наличие git
$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) {
    Write-Host "Git не найден. Установите: https://git-scm.com/download/win"
    exit 1
}

# Инициализация и первый коммит
if (-not (Test-Path ".git")) {
    git init
    git branch -M main
}
git remote remove origin 2>$null
git remote add origin $remoteUrl
git add -A
git commit -m "Initial commit" 2>$null
if ($LASTEXITCODE -ne 0) { git commit -m "Initial commit" --allow-empty }
git push -u origin main

Write-Host "Готово. Репозиторий: https://github.com/gpro7724-netizen/kurs"
