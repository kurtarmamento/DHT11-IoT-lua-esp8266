# Load .env into process environment, then start Node-RED.
$envPath = Join-Path $PSScriptRoot "..\.env"

if (Test-Path $envPath) {
  Get-Content $envPath | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq "" -or $line.StartsWith("#")) { return }
    $parts = $line.Split("=", 2)
    if ($parts.Length -ne 2) { return }
    $name = $parts[0].Trim()
    $value = $parts[1].Trim().Trim('"')
    if ($name -ne "") { Set-Item -Path "Env:$name" -Value $value }
  }
} else {
  Write-Host "No .env found. Copy .env.example to .env and set DISCORD_WEBHOOK_URL." -ForegroundColor Yellow
}

node-red
