-- server.lua
-- Minimal HTTP server for manual checking on phone
-- Endpoints:
--   GET /      -> HTML page
--   GET /json  -> JSON payload

local function read_sensor()
  local status, temp_c, hum_pct = dht.read11(DHT_PIN)
  if status ~= dht.OK then return nil, nil, status end
  return temp_c, hum_pct, status
end

local function json_escape(s)
  -- minimal escape for quotes/backslashes
  s = tostring(s)
  s = s:gsub("\\", "\\\\"):gsub("\"", "\\\"")
  return s
end

local function make_json(temp_c, hum_pct, ip)
  -- Avoid dependencies; build JSON manually.
  return string.format(
    '{"ok":true,"temp_c":%.1f,"humidity_pct":%.1f,"ip":"%s"}',
    temp_c, hum_pct, json_escape(ip or "")
  )
end

local function make_error_json(status)
  return string.format('{"ok":false,"error":"dht","status":%d}', tonumber(status or -1))
end

local function handle_request(payload)
  local method, path = payload:match("^(%u+)%s+([^%s]+)%s+HTTP/%d%.%d")
  if not method then return "400 Bad Request", "text/plain", "bad request" end

  local ip = wifi.sta.getip() or ""

  if path == "/" then
    local t, h, st = read_sensor()
    local body
    if t == nil then
      body = "<html><body><h2>Room Sensor</h2><p>DHT read failed. status=" .. tostring(st) .. "</p></body></html>"
    else
      body = string.format(
        "<html><body><h2>Room Sensor</h2><p>IP: %s</p><p>Temperature: %.1f C</p><p>Humidity: %.1f %%</p><p><a href=\"/json\">/json</a></p></body></html>",
        ip, t, h
      )
    end
    return "200 OK", "text/html", body

  elseif path == "/json" then
    local t, h, st = read_sensor()
    if t == nil then
      return "200 OK", "application/json", make_error_json(st)
    end
    return "200 OK", "application/json", make_json(t, h, ip)

  else
    return "404 Not Found", "text/plain", "not found"
  end
end

-- Start server
local srv = net.createServer(net.TCP, 30)
srv:listen(80, function(conn)
  conn:on("receive", function(c, payload)
    local status, ctype, body = handle_request(payload)
    c:send(
      "HTTP/1.1 " .. status .. "\r\n" ..
      "Content-Type: " .. ctype .. "\r\n" ..
      "Connection: close\r\n" ..
      "Cache-Control: no-store\r\n\r\n" ..
      body,
      function() c:close() end
    )
  end)
end)

print("HTTP server started on port 80")
