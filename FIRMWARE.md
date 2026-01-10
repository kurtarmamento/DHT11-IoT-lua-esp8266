# Firmware and Flashing (NodeMCU Lua on ESP8266)

This project targets ESP8266 with NodeMCU firmware (Lua 5.1).

## Required NodeMCU Modules

Minimum modules used by the project:

- `wifi`, `net`, `http`, `mqtt`
- `dht`
- `tmr`, `node`, `file`
- optional: `mdns` (for `room-sensor.local`)

Recommended to include:
- `tls` (not required for the ESP code here, but often useful)
- `sjson` (optional)

## Build Type

Use **float** build. The DHT read in float builds provides float temperature values.

Example DHT read output:
- `status, temp_c, hum_pct, ...`
- status `0` indicates success (`dht.OK`)

## Flashing Firmware (Windows)

Common options:
- NodeMCU Flasher (GUI)
- `esptool.py` (CLI)

General steps:
1. Put ESP8266 into flash mode (board-dependent).
2. Flash the NodeMCU firmware binary.
3. Reboot.
4. Connect via serial (ESPlorer recommended for Lua development).

## ESPlorer Workflow

1. Select COM port and baud rate (commonly 115200).
2. Open the terminal and confirm you see the NodeMCU banner.
3. Upload your Lua files to flash using **Save to ESP** (not just Run):
   - `init.lua`
   - `server.lua`
   - `mqtt_pub.lua`
   - `config.lua`

### Confirm files exist on the ESP

Run:
```lua
for n,s in pairs(file.list()) do print(n,s) end
```

### Avoid `.lc` overriding `.lua`

If you ever compiled files, NodeMCU may boot `init.lc` instead of `init.lua`.

Check for compiled files:
```lua
for n,s in pairs(file.list()) do if n:match("%.lc$") then print(n,s) end end
```

Remove them if needed:
```lua
file.remove("init.lc")
file.remove("mqtt_pub.lc")
file.remove("server.lc")
```

Then reboot:
```lua
node.restart()
```

## Hardware Wiring

This project uses a Jaycar DHT11 shield. Configuration is via:

- `DHT_PIN` in `config.lua`

Verify DHT reads:
```lua
print(dht.read11(DHT_PIN))
```

## Boot Expectations

On boot (serial output), you should see:
- IP assigned
- HTTP server started
- MQTT connected
- periodic serial prints (optional)

If you do not see these after reset, confirm:
- you uploaded and saved the correct `init.lua`
- `.lc` files are not overriding `.lua`
