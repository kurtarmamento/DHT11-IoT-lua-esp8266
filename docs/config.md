# Configuration
The device reads `config.lua` at boot.

## Required keys

### Wi-Fi
- `SSID` (string)
- `PASS` (string)

### Hardware
- `DHT_PIN` (integer) — must match your shield/pin mapping

### Identity
- `DEVICE_ID` (string)

### MQTT
- `MQTT_HOST` (string) — your PC LAN IP
- `MQTT_PORT` (integer) — typically 1883
- optional:
  - `MQTT_USER`, `MQTT_PASS`

### Telemetry
- `PUBLISH_MS` — publish interval in milliseconds

### Alerts
- `TEMP_HIGH_C`, `TEMP_HYST_C`
- `HUM_HIGH_PCT`, `HUM_HYST_PCT`
- `ALERT_COOLDOWN_S` — seconds

## Example

See `config_example.lua`.
