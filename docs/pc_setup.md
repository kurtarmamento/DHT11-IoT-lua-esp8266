# PC Setup (Mosquitto + Node-RED)

## Drivers

Ensure the correct drivers are installed for your ESP8266.

I used the Wi-Fi Mini ESP8266 from Jaycar 
https://media.jaycar.com.au/product/resources/XC3802_driverMain_94619.zip?_gl=1*fn3tfa*_gcl_aw*R0NMLjE3NjgxMTgwNTYuQ2p3S0NBaUFqb2pMQmhBbEVpd0FjamhyRG5jcnA2UE5nX29aNWRRaEU5bHhJcHdwVWM2Q2tHWFJrMFpmbXNTUmNFMXpiNjFjYlVDTkFCb0M3TjBRQXZEX0J3RQ..*_gcl_au*MTQ2Mzc4OTk2MS4xNzY3NDE4NDQ2

The driver this board can be downloaded here:
https://media.jaycar.com.au/product/resources/XC3802_driverMain_94619.zip?_gl=1*fn3tfa*_gcl_aw*R0NMLjE3NjgxMTgwNTYuQ2p3S0NBaUFqb2pMQmhBbEVpd0FjamhyRG5jcnA2UE5nX29aNWRRaEU5bHhJcHdwVWM2Q2tHWFJrMFpmbXNTUmNFMXpiNjFjYlVDTkFCb0M3TjBRQXZEX0J3RQ..*_gcl_au*MTQ2Mzc4OTk2MS4xNzY3NDE4NDQ2

## Mosquitto (MQTT broker)

This project uses your PC as the **MQTT broker host** (Mosquitto), and optionally as the **alert forwarder** (Node-RED -> Discord).

## What must be running on the PC

### Required (for live phone updates)
- **Mosquitto broker** running and reachable on your LAN at `<PC_LAN_IP>:1883`.

### Optional (for Discord alerts)
- **Node-RED** running (UI at `http://127.0.0.1:1880`) with a flow that:
  - subscribes to `sensors/<DEVICE_ID>/alert`
  - posts to Discord webhook via HTTPS

If Node-RED is not running, the phone dashboard can still work (MQTT telemetry), but Discord alerts will not.


### Configuration

In Mosquitto 2.x, remote access typically requires an explicit listener.

Add these 2 lines to the config file.

Typical path:
C:\Program Files\mosquitto\mosquitto.CONF

```conf
listener 1883 0.0.0.0
allow_anonymous true
```

Then restart the Mosquitto service via services.msc

### Verify port is listening

In cmd:

```bat
netstat -ano | findstr :1883
```

You want `0.0.0.0:1883 LISTENING` or `<LAN_IP>:1883 LISTENING`.

If the port is not listening, try:

```bat
mosquitto -v -c "C:\Program Files\mosquitto\mosquitto.conf"
```

to manually start mosquitto

## Windows Firewall

Ensure an Inbound rule for mosquitto exists allowing for TCP port 1883

Create a new rule if not

## Node-RED

Node-RED is only required if you are forwarding alerts to Discord.

### Discord

In discord, edit the channel you wish to add the alerts

Under integrations, create a new webhook and copy the link

### Start Node-RED

In cmd / PowerShell:

```bat
node-red
```

Open in browser:
- http://127.0.0.1:1880/

Import the node_red_flow.json into node_red.

In the function node, insert your discord webhook.

Use the inject node to verify the webhook is working.

