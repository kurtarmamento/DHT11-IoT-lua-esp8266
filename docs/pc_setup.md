# PC Setup (Mosquitto + Node-RED)

## Mosquitto (MQTT broker)

Requirements:
- Mosquitto installed on Windows
- TCP port 1883 reachable from ESP + phone (same LAN)

### Configuration

In Mosquitto 2.x, remote access typically requires an explicit listener.


```conf
listener 1883 0.0.0.0
allow_anonymous true
```

Then restart the Mosquitto service.

### Verify port is listening

In cmd:

```bat
netstat -ano | findstr :1883
```

You want `0.0.0.0:1883 LISTENING` or `<LAN_IP>:1883 LISTENING`.

## Node-RED

Node-RED is only required if you are forwarding alerts to Discord.

### Start Node-RED

In cmd / PowerShell:

```bat
node-red
```

Open:
- http://127.0.0.1:1880/
