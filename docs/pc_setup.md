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

This project keeps the Discord webhook URL out of the repo and out of exported Node-RED flows by using an environment variable.

### 1) In discord, edit the channel you wish to add the alerts
       Under integrations, create a new webhook and copy the link


### 2) Create your local `.env` file

At the repo root:

1. Copy the template:
   - `.env.example` → `.env`
2. Edit `.env` and set your real webhook URL:

```dotenv
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/REPLACE_ME
```

### 3) Start and configure Node-RED

1. In cmd / PowerShell:

   ```bat
   powershell -ExecutionPolicy Bypass -File .\tools\run_nodered.ps1
   ```

2. Open in browser:
   - http://127.0.0.1:1880/

3. Import the node_red_flow.json into node_red.

   Use the inject node to verify your alerts are working

## Simulator (no hardware required)

This repo includes a PC-side simulator that publishes the same MQTT topics as the ESP8266, so you can demo the pipeline without hardware

### Requirements

Install requirements through powershell

```powershell
python -m venv .venv
.\.venv\Scripts\activate
pip install -r .\tools\requirements_pc.txt
```

### Run
Run the simulator

```powershell
python .\tools\sim_device.py --host 127.0.0.1 --port 1883 --device-id room-sensor-1 --interval 10 --retain
```

Verify functionality
```powershell
mosquitto_sub -h 127.0.0.1 -p 1883 -t "sensors/room-sensor-01/#" -v
```

### Output
The simulator can be connected to any IoT dashboard using your computer's IPv4 address and port 1883.

It will also send alerts to discord once Node-Red is configured.