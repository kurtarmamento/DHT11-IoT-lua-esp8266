# Node-RED: Forward MQTT Alerts to Discord

Goal:
- Subscribe to `sensors/<DEVICE_ID>/alert`
- POST the message to a Discord webhook URL

## Required Nodes

- `mqtt in` (built-in)
- `function` (built-in)
- `http request` (built-in)
- optional `debug` (built-in)

## Flow

`mqtt in` -> `function` -> `http request` -> `debug`

### MQTT In node

- Server: `localhost`
- Port: `1883`
- Topic: `sensors/room-sensor-1/alert` (replace `room-sensor-1`)

### Function node

Paste:

```js
const alertText = (typeof msg.payload === "string")
  ? msg.payload
  : JSON.stringify(msg.payload);

msg.method = "POST";
msg.url = "YOUR_DISCORD_WEBHOOK_URL";  
msg.headers = { "Content-Type": "application/json" };

msg.payload = { content: "[Room Sensor Alert] " + alertText };
return msg;
```

### HTTP Request node

- Method: Use `msg.method` (or fixed POST)
- URL: leave blank if using `msg.url` (or paste webhook URL here)
- Return: string or JSON is fine

## Testing

Before relying on real alerts:
- Add an `inject` node with payload `"TEST ALERT: pipeline ok"`
- Wire `inject -> function -> http request`
- Deploy and click Inject; you should see it in Discord.
