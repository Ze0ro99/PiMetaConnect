"""
led_control.py

Smart LED control script for Raspberry Pi, designed for PiMetaConnect.

- Blinks an LED on a chosen GPIO pin.
- Fetches & logs project info (name, description, license) from local repo files if available.
- Self-checks for GPIO library & guides install if missing.
- Clear, user-friendly logging.
- Ready to upload directly to your GitHub repo.

Author: Ze0ro99 (PiMetaConnect)
License: MIT
"""

import os
import time
import json
import logging

def fetch_repo_metadata():
    """Fetch project metadata from common files."""
    meta = {"name": None, "description": None, "license": None}

    # Try package.json (JS/TS projects)
    if os.path.isfile("package.json"):
        try:
            with open("package.json", "r", encoding="utf-8") as f:
                data = json.load(f)
                meta["name"] = data.get("name")
                meta["description"] = data.get("description")
                meta["license"] = data.get("license")
        except Exception as e:
            logging.warning(f"Cannot read package.json: {e}")

    # Try pyproject.toml (Python projects)
    elif os.path.isfile("pyproject.toml"):
        try:
            import tomllib
            with open("pyproject.toml", "rb") as f:
                pdata = tomllib.load(f)
                project = pdata.get("project", {})
                meta["name"] = project.get("name")
                meta["description"] = project.get("description")
                l = project.get("license")
                meta["license"] = l.get("text") if isinstance(l, dict) else l
        except Exception as e:
            logging.warning(f"Cannot read pyproject.toml: {e}")

    # Try README.md
    if not meta["description"] and os.path.isfile("README.md"):
        try:
            with open("README.md", encoding="utf-8") as f:
                meta["description"] = f.readline().strip("# \n")
        except Exception as e:
            logging.warning(f"Cannot read README.md: {e}")

    # Try LICENSE
    if not meta["license"] and os.path.isfile("LICENSE"):
        try:
            with open("LICENSE", encoding="utf-8") as f:
                meta["license"] = f.readline().strip()
        except Exception as e:
            logging.warning(f"Cannot read LICENSE: {e}")

    # Fallbacks
    meta["name"] = meta["name"] or os.path.basename(os.getcwd())
    meta["description"] = meta["description"] or "No description found."
    meta["license"] = meta["license"] or "No license found."
    return meta

logging.basicConfig(
    format="%(asctime)s [%(levelname)s]: %(message)s",
    level=logging.INFO
)

# ==== GPIO SETUP ====
try:
    import RPi.GPIO as GPIO
    GPIO_AVAILABLE = True
except ImportError:
    logging.error("RPi.GPIO not installed! Please run: sudo pip install RPi.GPIO")
    GPIO_AVAILABLE = False

LED_PIN = 18  # Change this if your LED is connected to another GPIO

def setup_gpio():
    if not GPIO_AVAILABLE:
        raise ImportError("RPi.GPIO is not available.")
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(LED_PIN, GPIO.OUT)
    logging.info(f"GPIO setup complete. LED_PIN={LED_PIN}")

def blink_led(times=5, interval=0.5):
    """Blink LED for 'times' times with 'interval' seconds."""
    logging.info(f"Blinking LED on GPIO {LED_PIN} ({times} times, {interval}s interval)...")
    for i in range(times):
        GPIO.output(LED_PIN, GPIO.HIGH)
        logging.info(f"LED ON ({i+1}/{times})")
        time.sleep(interval)
        GPIO.output(LED_PIN, GPIO.LOW)
        logging.info(f"LED OFF ({i+1}/{times})")
        time.sleep(interval)

def main():
    meta = fetch_repo_metadata()
    logging.info(f"Project Name: {meta['name']}")
    logging.info(f"Description : {meta['description']}")
    logging.info(f"License     : {meta['license']}")

    if not GPIO_AVAILABLE:
        logging.error("RPi.GPIO is not available. Exiting.")
        return

    try:
        setup_gpio()
        blink_led(times=5, interval=0.5)
    except KeyboardInterrupt:
        logging.info("Interrupted by user.")
    except Exception as e:
        logging.error(f"Error: {e}")
    finally:
        if GPIO_AVAILABLE:
            GPIO.cleanup()
            logging.info("GPIO cleanup done.")

if __name__ == "__main__":
    main()