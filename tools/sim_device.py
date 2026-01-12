import argparse
import os
import random
import sys
import time
from datetime import datetime

import paho.mqtt.client as mqtt

# alert thresholds
TEMP_HIGH_C = 20.0
HUM_HIGH_PCT = 40.0


def clamp(x: float, lo: float, hi: float) -> float:
    return max(lo, min(hi, x))


def now_iso() -> str:
    return datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")


def build_topics(device_id: str) -> dict:
    # Adjust these to match your repo's documented topics exactly.
    base = f"sensors/{device_id}"
    return {
        "temp_c": f"{base}/temp_c",
        "humidity_pct": f"{base}/humidity_pct",
        "status": f"{base}/status",
        "alert": f"{base}/alert"
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Simulate an ESP8266 room sensor publishing MQTT telemetry.")
    parser.add_argument("--host", default=os.environ.get("MQTT_HOST", "127.0.0.1"))
    parser.add_argument("--port", type=int, default=int(os.environ.get("MQTT_PORT", "1883")))
    parser.add_argument("--device-id", default=os.environ.get("DEVICE_ID", "room-sensor-1"))
    parser.add_argument("--interval", type=float, default=10.0, help="Seconds between publishes.")
    parser.add_argument("--retain", action="store_true", help="Publish retained values.")
    parser.add_argument("--temp-start", type=float, default=25.0)
    parser.add_argument("--humidity-start", type=float, default=55.0)
    args = parser.parse_args()

    topics = build_topics(args.device_id)

    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
    client.connect(args.host, args.port, keepalive=60)
    client.loop_start()

    temp = args.temp_start
    hum = args.humidity_start

    try:
        # Send initial "online" status once
        client.publish(topics["status"], payload="online", retain=args.retain, qos=0)

        while True:
            # Random walk, clamped to reasonable ranges
            temp = clamp(temp + random.uniform(-0.2, 0.2), 15.0, 40.0)
            hum = clamp(hum + random.uniform(-0.6, 0.6), 20.0, 90.0)

            client.publish(topics["temp_c"], f"{temp:.1f}", retain=args.retain, qos=0)
            client.publish(topics["humidity_pct"], f"{hum:.1f}", retain=args.retain, qos=0)

            if temp > TEMP_HIGH_C:
                client.publish(topics["alert"], f"TEMP HIGH: {temp:.1f}C (RH {hum:.1f}%)", retain=args.retain, qos=0)
            if hum > HUM_HIGH_PCT:
                client.publish(topics["alert"], f"HUM HIGH: {hum:.1f}% (T {temp:.1f}C)", retain=args.retain, qos=0)

            print(f"[{now_iso()}] {args.device_id} temp_c={temp:.1f} humidity_pct={hum:.1f}")
            time.sleep(args.interval)

    except KeyboardInterrupt:
        pass
    finally:
        client.publish(topics["status"], payload="offline", retain=args.retain, qos=0)
        client.loop_stop()
        client.disconnect()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
