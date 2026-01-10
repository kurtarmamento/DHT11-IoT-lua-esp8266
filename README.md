# Room Sensor IoT (ESP8266 + NodeMCU Lua + MQTT + Node-RED)

A room temperature + humidity sensor built on ESP8266 (NodeMCU firmware, Lua) with:

- Live telemetry to phone via MQTT (Mosquitto broker)
- Manual “check now” HTTP endpoint for your phone browser
- Threshold alerts published to MQTT and forwarded to Discord via Node-RED

## Features

- **Sensor:** DHT11 temperature + humidity
- **Connectivity:** ESP8266 connects to Wi-Fi (station mode)
- **Manual check:** HTTP server on port 80
  - `GET /` returns a human-readable page
  - `GET /json` returns JSON
- **MQTT telemetry:** retained topics for instant dashboard display
  - `temp_c`, `humidity_pct`, `status`
- **MQTT alerts:** topic `alert` (non-retained)
  - hysteresis + cooldown to prevent spam
- **PC integration:** Mosquitto broker + Node-RED forwarding to Discord

## Architecture

```
[DHT11] -> [ESP8266 / NodeMCU Lua]
             |  HTTP (port 80)
             |--> Phone browser (manual check)
             |
             |  MQTT publish (port 1883)
             v
        [Mosquitto Broker on PC]
             | MQTT subscribe
             |--> Android MQTT dashboard (live values)
             |
             | MQTT subscribe
             v
          [Node-RED]
             | HTTPS POST
             v
        [Discord Webhook]
```

## MQTT Topics

All topics are namespaced by `DEVICE_ID`.

- `sensors/<DEVICE_ID>/status`
  - payload: `online` / `offline`
  - retained: yes

- `sensors/<DEVICE_ID>/temp_c`
  - payload: `"31.1"` (string)
  - retained: yes

- `sensors/<DEVICE_ID>/humidity_pct`
  - payload: `"55.0"` (string)
  - retained: yes

- `sensors/<DEVICE_ID>/alert`
  - payload example: `TEMP HIGH: 31.1C (RH 55.0%)`
  - retained: no

## HTTP Endpoints

- `GET /`
  - Human-readable output for quick checks from a phone browser.

- `GET /json`
  - JSON payload:
    - success: `{"ok":true,"temp_c":...,"humidity_pct":...,"ip":"..."}`
    - failure: `{"ok":false,"error":"dht","status":...}`

## Repo Structure

Recommended structure:

```
.
├─ init.lua
├─ server.lua
├─ mqtt_pub.lua
├─ config.example.lua
├─ README.md
├─ FIRMWARE.md
├─ docs/
│  ├─ architecture.md
│  ├─ pc_setup.md
│  ├─ node_red_discord.md
│  ├─ config.md
│  ├─ testing.md
│  └─ troubleshooting.md
├─ logs/
│  └─ sample_serial_output.txt
└─ photos/
   ├─ build_01.jpg
   ├─ build_02.jpg
   └─ dashboard_and_discord.png
```

## Setup Overview

### 1) Flash NodeMCU firmware (Lua)
See `FIRMWARE.md`.

### 2) Configure device (do not commit secrets)
1. Copy `config.example.lua` → `config.lua`
2. Fill in Wi-Fi + broker settings
3. Upload files to the ESP:
   - `init.lua`
   - `server.lua`
   - `mqtt_pub.lua`
   - `config.lua` (local only)

### 3) PC: run Mosquitto broker
See `docs/pc_setup.md`.

### 4) Phone: install an MQTT dashboard
Recommended: **IoT MQTT Panel** (Android). Configure it to subscribe to:
- `sensors/<DEVICE_ID>/temp_c`
- `sensors/<DEVICE_ID>/humidity_pct`
- `sensors/<DEVICE_ID>/status`

### 5) PC: run Node-RED for Discord alerts
See `docs/node_red_discord.md`.

## How to Use

1. Power the ESP8266
2. Confirm it prints IP and connects MQTT over serial
3. Phone dashboard should show live values (retained topics will populate immediately)
4. Manual check:
   - open `http://<ESP_IP>/` or `http://room-sensor.local/` (if mDNS works)
5. Alerts:
   - when thresholds are crossed, ESP publishes to `.../alert`
   - Node-RED forwards those alert messages to Discord

## Security Notes

- Never commit `config.lua` (contains Wi-Fi credentials and potentially webhook URLs).
- Use `config.example.lua` for the repo.
- Treat Discord webhooks as secrets.