-- config.example.lua
SSID = "YOUR_WIFI_NAME"
PASS = "YOUR_WIFI_PASSWORD"

-- Hardware
DHT_PIN = 4  -- D4 on your Jaycar DHT11 shield


-- identity
DEVICE_ID = "room-sensor-1"

-- sampling
READ_INTERVAL_MS = 10 * 1000

-- alert thresholds
TEMP_HIGH_C = 30.0
TEMP_HYST_C = 0.5          -- hysteresis so it doesn't spam near threshold
HUM_HIGH_PCT = 70.0
HUM_HYST_PCT = 2.0

-- notification throttling
ALERT_COOLDOWN_S = 300     -- 5 minutes

-- MQTT (local broker)
MQTT_HOST = "192.168.0.50" -- IPv4 Address
MQTT_PORT = 1883
MQTT_USER = nil
MQTT_PASS = nil

-- optional: local webhook (Node-RED or a small server on your PC)
ALERT_WEBHOOK_URL = "http://192.168.0.50:1880/alert"

PUBLISH_MS = 5000
