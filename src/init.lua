-- init.lua (Day 1)
-- init.lua
local ok, err = pcall(dofile, "config.lua")
if not ok then
  print("Missing/failed config.lua: " .. tostring(err))
  -- Stop here so you don't accidentally run with blank credentials
  return
end

wifi.setmode(wifi.STATION)
wifi.sta.config({ ssid = SSID, pwd = PASS, save = false })
wifi.sta.connect()

local function read_and_print()
  local status, temp_c, hum_pct = dht.read11(DHT_PIN)  -- float firmware: use first 3
  if status == dht.OK then
    print(string.format("IP=%s  T=%.1fC  RH=%.1f%%",
      wifi.sta.getip() or "no-ip", temp_c, hum_pct))
  elseif status == dht.ERROR_CHECKSUM then
    print("DHT checksum error")
  else
    print("DHT timeout")
  end
end

tmr.create():alarm(5000, tmr.ALARM_AUTO, read_and_print)



