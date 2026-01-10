# Testing

## 1) DHT sensor read
Run in console:
```lua
print(dht.read11(DHT_PIN))
```
Expect status `0` for success.

## 2) HTTP endpoints
From phone browser:
- `http://<esp-ip>/`
- `http://<esp-ip>/json`

## 3) MQTT telemetry
On PC:
```bat
mosquitto_sub -h 127.0.0.1 -t "sensors/room-sensor-1/#" -v
```
Expect:
- `status` retained
- periodic `temp_c` and `humidity_pct`

## 4) Alert trigger
Set threshold for a controlled test (temporarily):
- `TEMP_HIGH_C` slightly below room temp to trigger
- then set above room temp to clear

Confirm:
- `.../alert` appears in `mosquitto_sub`
- Discord message appears if Node-RED is running
