# Architecture

## Components

1. **ESP8266 (NodeMCU Lua)**
   - Reads sensor via `dht.read11(DHT_PIN)`
   - Hosts HTTP server on port 80 for manual checks
   - Publishes MQTT telemetry + alerts

2. **Mosquitto Broker (PC)**
   - Accepts MQTT connections on TCP port 1883
   - Routes published messages to subscribers (phone, Node-RED)

3. **Android Phone**
   - MQTT dashboard subscribes to telemetry topics

4. **Node-RED (PC)**
   - Subscribes to alert topic(s)
   - Forwards alerts to Discord via HTTPS webhook

## Data Flows

### Flow A: Manual check (HTTP)
Phone browser -> `http://<esp-ip>/` or `/json` -> ESP reads sensor -> HTTP response.

### Flow B: Live updates (MQTT telemetry)
ESP publishes retained telemetry every `PUBLISH_MS`:
- `temp_c` (retained)
- `humidity_pct` (retained)
- `status` (retained online/offline)

Phone subscribes and displays live values.

### Flow C: Notifications (MQTT alerts -> Node-RED -> Discord)
ESP publishes non-retained events to:
- `sensors/<DEVICE_ID>/alert`

Node-RED subscribes to this topic and sends a Discord webhook message.

## Topic Schema

Namespace:
- `sensors/<DEVICE_ID>/<suffix>`

Suffixes:
- `status`, `temp_c`, `humidity_pct`, `alert`

## Alert Semantics

Alerts are generated using:

- Thresholds:
  - `TEMP_HIGH_C`, `HUM_HIGH_PCT`

- Hysteresis:
  - `TEMP_HYST_C`, `HUM_HYST_PCT`

- Cooldown:
  - `ALERT_COOLDOWN_S`

The default implementation is **edge-triggered**:

- On transition `normal -> high`, publish `HIGH` message
- On transition `high -> normal`, publish `NORMAL` message
- No repeated messages while remaining in the same state

Formally (temperature):
- Define boolean state `temp_high`.
- Transition to `true` when `temp_c >= TEMP_HIGH_C`.
- Transition to `false` when `temp_c <= TEMP_HIGH_C - TEMP_HYST_C`.

Cooldown ensures two events are separated by at least `ALERT_COOLDOWN_S`.

## Failure Modes and Recovery

- Wi-Fi drop:
  - device reconnects; HTTP and MQTT resume when IP returns
- Broker down:
  - MQTT reconnect logic retries; telemetry resumes on reconnect
- DHT read failure:
  - telemetry publish for that interval is skipped; HTTP returns an error JSON
