# modbus_simple_firmware を Arduino Nano R4 に書き込む Windows 用スクリプト
#
# 使い方（推奨）: PowerShell に以下を貼り付けて実行
#   powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/KikuchiMakoto/modbus_simple_system/main/scripts/flash-firmware-windows.ps1 | iex"
#
# 中身を確認してから実行したい場合は、このファイルの内容をコピーして
# PowerShell 画面に直接貼り付けて Enter しても同じ結果になります
# （貼り付け実行なら .ps1 の実行ポリシー制限にも引っかかりません）。
#
# やっていること:
#   1. winget で Arduino CLI をインストール（未インストールの場合のみ）
#   2. Arduino Nano R4 用のボードコア(arduino:renesas_uno)をインストール
#   3. modbus_simple_firmware の最新 Release から ArduinoNanoR4.bin を
#      %TEMP% にダウンロード
#   4. 接続されている COM ポートを検出し、書き込みを実行

$ErrorActionPreference = "Stop"

function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path", "User")
}

Write-Host "=== 1. Arduino CLI の確認 ===" -ForegroundColor Cyan
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget が見つかりません。Microsoft Store の「アプリ インストーラー」を導入してから再実行してください。"
}

if (-not (Get-Command arduino-cli -ErrorAction SilentlyContinue)) {
    Write-Host "Arduino CLI が見つからないためインストールします..."
    winget install -e --id ArduinoSA.CLI --accept-package-agreements --accept-source-agreements
    Refresh-Path
}

if (-not (Get-Command arduino-cli -ErrorAction SilentlyContinue)) {
    throw "arduino-cli のインストール後に見つかりませんでした。PowerShell を一度閉じて開き直してから再実行してください。"
}

Write-Host "=== 2. Arduino Nano R4 用ボードコアの準備 ===" -ForegroundColor Cyan
arduino-cli core update-index | Out-Null
arduino-cli core install arduino:renesas_uno

Write-Host "=== 3. ファームウェア(最新Release)のダウンロード ===" -ForegroundColor Cyan
$work = Join-Path $env:TEMP "modbus_simple_firmware"
New-Item -ItemType Directory -Force -Path $work | Out-Null

$release = Invoke-RestMethod "https://api.github.com/repos/KikuchiMakoto/modbus_simple_firmware/releases/latest"
$asset = $release.assets | Where-Object { $_.name -eq "ArduinoNanoR4.bin" }
if (-not $asset) {
    throw "最新リリース($($release.tag_name))に ArduinoNanoR4.bin が見つかりませんでした。"
}

$binPath = Join-Path $work "ArduinoNanoR4.bin"
Write-Host "ダウンロード中: $($asset.browser_download_url)"
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $binPath
Write-Host "保存先: $binPath"

Write-Host "=== 4. 書き込み先 COM ポートの選択 ===" -ForegroundColor Cyan
$ports = [System.IO.Ports.SerialPort]::GetPortNames()
if ($ports.Count -eq 0) {
    throw "COMポートが見つかりません。Arduino Nano R4 をUSBで接続してから再実行してください。"
} elseif ($ports.Count -eq 1) {
    $port = $ports[0]
    Write-Host "COMポート: $port を使用します"
} else {
    Write-Host "複数のCOMポートが見つかりました: $($ports -join ', ')"
    $port = Read-Host "書き込み先のCOMポート名を入力してください（例: COM5）"
}

Write-Host "=== 5. 書き込み ===" -ForegroundColor Cyan
arduino-cli upload -p $port --fqbn arduino:renesas_uno:nanor4 -i $binPath

Write-Host "完了しました。" -ForegroundColor Green
