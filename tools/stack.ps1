param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("up", "down", "logs", "restart", "ps")]
  [string]$Cmd
)

switch ($Cmd) {
  "up"      { docker compose up -d }
  "down"    { docker compose down }
  "restart" { docker compose restart }
  "logs"    { docker compose logs -f --tail 200 }
  "ps"      { docker compose ps }
}
