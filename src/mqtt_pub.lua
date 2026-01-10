-- mqtt_pub.lua
-- Publishes retained telemetry topics + non-retained alerts over MQTT.
-- Topics:
--   sensors/<DEVICE_ID>/status        ("online"/"offline", retained)
--   sensors/<DEVICE_ID>/temp_c        (e.g. "28.4", retained)
--   sensors/<DEVICE_ID>/humidity_pct  (e.g. "61.0", retained)
--   sensors/<DEVICE_ID>/alert         (event text, NOT retained)

local M = {}

local client = nil
local connected = false

-- Alert state (prevents flapping/spam)
local last_alert_s = -(ALERT_COOLDOWN_S or 0)
local temp_high = false
local hum_high  = false

local function topic(suffix)
  return "sensors/" .. DEVICE_ID .. "/" .. suffix
end

local function can_alert()
  -- tmr.time() is seconds since boot
  local now_s = tmr.time()
  return (now_s - last_alert_s) >= ALERT_COOLDOWN_S
end

local function send_alert(msg)
  if not (client and connected) then return end
  client:publish(topic("alert"), msg, 0, 0) -- qos=0, retain=0
  last_alert_s = tmr.time()
end

local function schedule_reconnect()
  tmr.create():alarm(5000, tmr.ALARM_SINGLE, function()
    M.connect()
  end)
end

function M.connect()
  if not mqtt then
    print("MQTT module missing")
    return
  end

  -- If you later add MQTT_USER/MQTT_PASS to config.lua, this will use them.
  local user = MQTT_USER
  local pass = MQTT_PASS

  client = mqtt.Client(DEVICE_ID, 60, user, pass) -- keepalive 60s
  client:lwt(topic("status"), "offline", 0, 1)    -- retained offline on unexpected drop

  client:on("offline", function()
    connected = false
    print("MQTT offline; retrying in 5s")
    schedule_reconnect()
  end)

  client:connect(MQTT_HOST, MQTT_PORT, false,
    function(c)
      connected = true
      print("MQTT connected")
      c:publish(topic("status"), "online", 0, 1)
    end,
    function(_, reason)
      connected = false
      print("MQTT connect failed:", reason, "retrying in 5s")
      schedule_reconnect()
    end
  )
end

function M.start()
  M.connect()

  tmr.create():alarm(PUBLISH_MS, tmr.ALARM_AUTO, function()
    if not (client and connected) then return end

    -- DHT11 read (float firmware: temp/humidity are usable directly)
    local st, temp_c, hum_pct = dht.read11(DHT_PIN)
    if st ~= dht.OK then return end

    -- Telemetry: retained so the phone dashboard shows latest immediately
    client:publish(topic("temp_c"), string.format("%.1f", temp_c), 0, 1)
    client:publish(topic("humidity_pct"), string.format("%.1f", hum_pct), 0, 1)

    -- Alerts with hysteresis + cooldown
    -- TEMP HIGH edge
    if (not temp_high) and (temp_c >= TEMP_HIGH_C) and can_alert() then
      temp_high = true
      send_alert(string.format("TEMP HIGH: %.1fC (RH %.1f%%)", temp_c, hum_pct))

    -- TEMP NORMAL edge (clear when below threshold - hysteresis)
    elseif temp_high and (temp_c <= (TEMP_HIGH_C - TEMP_HYST_C)) and can_alert() then
      temp_high = false
      send_alert(string.format("TEMP NORMAL: %.1fC (RH %.1f%%)", temp_c, hum_pct))
    end


    if temp_high and (temp_c >= TEMP_HIGH_C) and can_alert() then
      send_alert(string.format("TEMP STILL HIGH: %.1fC (RH %.1f%%)", temp_c, hum_pct))
    end


    -- HUM HIGH edge
    if (not hum_high) and (hum_pct >= HUM_HIGH_PCT) and can_alert() then
      hum_high = true
      send_alert(string.format("HUM HIGH: %.1f%% (T %.1fC)", hum_pct, temp_c))

    -- HUM NORMAL edge
    elseif hum_high and (hum_pct <= (HUM_HIGH_PCT - HUM_HYST_PCT)) and can_alert() then
      hum_high = false
      send_alert(string.format("HUM NORMAL: %.1f%% (T %.1fC)", hum_pct, temp_c))
    end
  end)
end

return M
