# =============================================
# ハンディターミナルのログファイル自動削除
# 保存期間150日を超過した ZIP ログを毎日削除する 
# 保存期間はディスクを圧迫しないように設定してある(ドライブサイズの5%程度を想定)
# =============================================

# ---- パラメータ設定ここから ----
$TargetPath = "D:\ftproot"
$Pattern    = "*.zip"
$DaysToKeep = 150
$limit      = (Get-Date).AddDays(-$DaysToKeep)

$LogDir  = "D:\Logs\HTLogCleaner"
New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
$LogFile = Join-Path $LogDir "$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
# ---- パラメータ設定ここまで ----

# ログ出力関数
function Write-Log {
    param([string]$Message)
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $Message"
    Add-Content -Path $LogFile -Value $line
}

# 処理開始
Write-Log "===== 処理開始 Path=$TargetPath, DaysToKeep=$DaysToKeep ====="

$files = Get-ChildItem -Path $TargetPath -Recurse -Filter $Pattern |
         Where-Object { $_.LastWriteTime -lt $limit }

foreach ($f in $files) {
    try {
        Remove-Item $f.FullName -Force
        Write-Log "$($f.FullName)"
    } catch {
        Write-Log "[エラー]$($f.FullName): $($_.Exception.Message)"
    }
}

Write-Log "===== 処理終了 削除件数: $($files.Count) file(s) ====="