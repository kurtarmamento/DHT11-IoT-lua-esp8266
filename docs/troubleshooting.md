# Troubleshooting

## Nothing happens after reset, but it works after uploading files
Likely causes:
- You executed code but did not **Save to ESP** (flash)
- `init.lc` exists and is overriding `init.lua`

Check files:
```lua
for n,s in pairs(file.list()) do print(n,s) end
```

Check for compiled files:
```lua
for n,s in pairs(file.list()) do if n:match("%.lc$") then print(n,s) end end
```

Remove compiled boot file if needed:
```lua
file.remove("init.lc")
node.restart()
```

## MQTT connected but no dashboard updates
- Broker not reachable (wrong `MQTT_HOST`)
- firewall blocks port 1883
- verify with `mosquitto_sub` on PC
- verify phone is on same LAN

## Alerts only happen once
This is expected for edge-trigger alerts:
- one message on `normal -> high`
- another on `high -> normal`
No repeated messages while state remains unchanged.

If you want repeated reminders, implement a “still high” reminder path.

## Node-RED not posting to Discord
- Node-RED is not running
- Discord webhook URL incorrect
- flow not deployed
- check `debug` node after the HTTP request node
