-- alerts.lua
local notify = dofile("notify.lua")

local M = {}

local state = {
  temp_high = false,
  hum_high  = false,
  last_sent_s = 0
}

local function can_send_now()
  local now_s = tmr.time()
  return (now_s - state.last_sent_s) >= ALERT_COOLDOWN_S
end

local function mark_sent()
  state.last_sent_s = tmr.time()
end

function M.process(mqtt_client, temp_c, hum_pct)
  -- TEMP HIGH: trigger when >= threshold; clear when <= threshold - hyst
  if (not state.temp_high) and (temp_c >= TEMP_HIGH_C) and can_send_now() then
    state.temp_high = true
    mark_sent()
    notify.send_event_webhook("TEMP_HIGH", temp_c, hum_pct)
    notify.send_event_mqtt(mqtt_client, "sensors/"..DEVICE_ID.."/alert", "TEMP_HIGH", temp_c, hum_pct)

  elseif state.temp_high and (temp_c <= (TEMP_HIGH_C - TEMP_HYST_C)) and can_send_now() then
    state.temp_high = false
    mark_sent()
    notify.send_event_webhook("TEMP_NORMAL", temp_c, hum_pct)
    notify.send_event_mqtt(mqtt_client, "sensors/"..DEVICE_ID.."/alert", "TEMP_NORMAL", temp_c, hum_pct)
  end

  -- HUM HIGH
  if (not state.hum_high) and (hum_pct >= HUM_HIGH_PCT) and can_send_now() then
    state.hum_high = true
    mark_sent()
    notify.send_event_webhook("HUM_HIGH", temp_c, hum_pct)
    notify.send_event_mqtt(mqtt_client, "sensors/"..DEVICE_ID.."/alert", "HUM_HIGH", temp_c, hum_pct)

  elseif state.hum_high and (hum_pct <= (HUM_HIGH_PCT - HUM_HYST_PCT)) and can_send_now() then
    state.hum_high = false
    mark_sent()
    notify.send_event_webhook("HUM_NORMAL", temp_c, hum_pct)
    notify.send_event_mqtt(mqtt_client, "sensors/"..DEVICE_ID.."/alert", "HUM_NORMAL", temp_c, hum_pct)
  end
end

return M
