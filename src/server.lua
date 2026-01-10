-- server.lua
-- Minimal HTTP server for manual checking on phone.
-- Endpoints:
--   GET /      -> simple text (no HTML formatting required)
--   GET /json  -> JSON payload

local function read_sensor()
  local status, temp_c, hum_pct = dht.read11(DHT_PIN)
  if status ~= dht.OK then
    return nil, nil, status
  end
  return temp_c, hum_pct, status
end

local function json_escape(s)
  s = tostring(s or "")
  s = s:gsub("\\", "\\\\"):gsub("\"", "\\\"")
  return s
end

local function make_json_ok(temp_c, hum_pct, ip)
  return string.format(
    '{"ok":true,"temp_c":%.1f,"humidity_pct":%.1f,"ip":"%s"}',
    temp_c, hum_pct, json_escape(ip)
  )
end

local function make_json_err(status)
  return string.format('{"ok":false,"error":"dht","status":%d}', tonumber(status or -1))
end

local function parse_request_line(payload)
  -- Extract: METHOD and PATH from "GET /path HTTP/1.1"
  local method, path = payload:match("^(%u+)%s+([^%s]+)%s+HTTP/%d%.%d")
  return method, path
end

local function handle_request(payload)
  local method, path = parse_request_line(payload)
  if not method then
    return "400 Bad Request", "text/plain", "bad request"
  end

  -- We only implement GET in this project
  if method ~= "GET" then
    return "405 Method Not Allowed", "text/plain", "method not allowed"
  end

  local ip = wifi.sta.getip() or ""

  if path == "/" then
    local t, h, st = read_sensor()
    if t == nil then
      return "200 OK", "text/plain", "DHT read failed. status=" .. tostring(st) .. "\n"
    end
    local body = string.format("IP=%s\nTEMP_C=%.1f\nHUMIDITY_PCT=%.1f\n", ip, t, h)
    return "200 OK", "text/plain", body

  elseif path == "/json" then
    local t, h, st = read_sensor()
    if t == nil then
      return "200 OK", "application/json", make_json_err(st)
    end
    return "200 OK", "application/json", make_json_ok(t, h, ip)

  else
    return "404 Not Found", "text/plain", "not found"
  end
end

-- Keep a global reference to avoid GC-related shutdowns
http_srv = http_srv or net.createServer(net.TCP, 30)

http_srv:listen(80, function(conn)
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
