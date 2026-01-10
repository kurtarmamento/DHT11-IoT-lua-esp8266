-- notify.lua
local M = {}

-- minimal JSON builder (no sjson dependency)
local function json_escape(s)
  s = tostring(s or "")
  s = s:gsub("\\", "\\\\"):gsub("\"", "\\\"")
  return s
end

local function make_event_json(event, temp_c, hum_pct)
  return string.format(
    '{"device":"%s","event":"%s","temp_c":%.1f,"humidity_pct":%.1f,"uptime_s":%d}',
    json_escape(DEVICE_ID),
    json_escape(event),
    temp_c, hum_pct,
    tmr.time()
  )
end

function M.send_event_mqtt(mqtt_client, topic, event, temp_c, hum_pct)
  if not mqtt_client then return end
  local payload = make_event_json(event, temp_c, hum_pct)
  mqtt_client:publish(topic, payload, 0, 0) -- qos=0 retain=0
end

function M.send_event_webhook(event, temp_c, hum_pct)
  if not ALERT_WEBHOOK_URL then return end
  if not http then return end

  local body = make_event_json(event, temp_c, hum_pct)
  http.post(
    ALERT_WEBHOOK_URL,
    "Content-Type: application/json\r\n",
    body,
    function(code, data)
      if code < 0 then
        print("Webhook failed")
      else
        print("Webhook OK:", code)
      end
    end
  )
end

return M
