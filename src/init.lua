-- init.lua
local ok, err = pcall(dofile, "config.lua")
if not ok then
  print("config.lua error: " .. tostring(err))
  return
end

wifi.setmode(wifi.STATION)
wifi.sta.config({ ssid = SSID, pwd = PASS, save = false })
wifi.sta.connect()

tmr.create():alarm(500, tmr.ALARM_AUTO, function(t)
  local ip = wifi.sta.getip()
  if not ip then return end

  t:unregister()
  print("IP:", ip)

  -- Optional mDNS (only if module exists)
  if mdns then
    mdns.register("room-sensor", { service = "http", port = 80, description = "Room Sensor" })
    print("mDNS: http://room-sensor.local/")
  end

  -- Start HTTP server
  dofile("server.lua")

  -- Start MQTT telemetry + alerts (single MQTT client)
  local pub = dofile("mqtt_pub.lua")
  pub.start()

  -- Optional serial prints
  tmr.create():alarm(5000, tmr.ALARM_AUTO, function()
    local st, temp_c, hum_pct = dht.read11(DHT_PIN)
    if st == dht.OK then
      print(string.format("T=%.1fC RH=%.1f%%", temp_c, hum_pct))
    end
  end)
end)

