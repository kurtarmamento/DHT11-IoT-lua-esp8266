-- mqtt_client.lua
local M = {}
local client = nil
local connected = false

function M.client()
  return client, connected
end

function M.connect(on_ready)
  if not mqtt then
    print("mqtt module missing")
    return
  end

  client = mqtt.Client(DEVICE_ID, 60, MQTT_USER, MQTT_PASS)  -- keepalive=60s :contentReference[oaicite:7]{index=7}
  client:lwt("sensors/"..DEVICE_ID.."/status", "offline", 0, 1) -- retained "offline" on unexpected drop :contentReference[oaicite:8]{index=8}

  client:on("offline", function()
    connected = false
    print("MQTT offline")
  end)

  client:connect(MQTT_HOST, MQTT_PORT, false,
    function(c)
      connected = true
      print("MQTT connected")
      c:publish("sensors/"..DEVICE_ID.."/status", "online", 0, 1)
      if on_ready then on_ready(c) end
    end,
    function(_, reason)
      connected = false
      print("MQTT connect failed:", reason)
    end
  )
end

function M.publish_telemetry(temp_c, hum_pct)
  if not (client and connected) then return end
  local payload = string.format('{"temp_c":%.1f,"humidity_pct":%.1f,"uptime_s":%d}', temp_c, hum_pct, tmr.time())
  client:publish("sensors/"..DEVICE_ID.."/telemetry", payload, 0, 1) -- retained latest
end

return M
