# Import necessary modules
from pathlib import Path
import datetime
import os
import platform
import subprocess
import sys
import time
import urllib.request
import socket
import ipaddress
import json

# gets the current time and formats it HH:MM:SS
current_time = datetime.datetime.now().time()

#get the current time and formats it in the 12 hour format
formatted_time = current_time.strftime("%I:%M:%S %p")

# Get the current date
current_date = datetime.datetime.now().strftime("%m/%d/%Y")

# holds the error file to read from
ERROR = open("ERROR.log", "a")

# name of program and software name
ProgramName = "NetBreachX"
SoftwareName = "NetBreachX.py"  

# holds the argument of the --globla function
argument = sys.argv

# easy way to read the root user function
ROOT = 0

# terminal command var so you can run terminal commands without having to type out " os.system"
terminalCommand = os.system

# list of the files to remove
RemoveFile = ["ERROR.log","ERROR.LOG"]

#the asscie art var
lineArt = subprocess.run

#name of the os
OS = "Darwin"
name = "MAC"

# Define color codes for console output
BRIGHT = '\033[1m'
GREEN = "\033[92m"
RED = "\033[91m"
BLUE = "\033[34m"
YELLOW = "\033[33m"
ORANGE_Start = "\033[38;2;255;165;0m"
GRAY_TEXT = "\033[90m"
CYAN_TEXT = "\033[36m"
RESET = "\033[0m"

#check for the internet connection
Link="google.com"

# Define constants for command-line arguments
HELP = {"--HELP", "--Help", "--help", "-h", "-H"}
GUI = {"--GUI", "--Gui", "--gui", "-GU","-Gu"}
GLOBAL = {"--GLOBAL", "--Global", "--global", "-G", "-g"}
LOCAL = {"--LOCAL", "--Local", "--local", "-l", "-L"}
GuiLocal = {"--GUI-LOCAL", "--Gui-Local", "--gui-local", "--g-l", "--G-l", "--G-L"}
GlobalManualArgument = {"--MANUAL-GLOBAL", "--Manual-Global", "--Manual-global", "--manual-Global", "--manual-global", "--m-g", "--M-g", "--M-G", "--man-global"}
LocalManualArgument = {"--MANUAL-LOCAL", "--Manual-Local","--Manual-local", "--manual-Local", "--manual-local", "--m-l", "--M-l", "--M-L", "--man-local"}
installRequirement = {"--INSTALL", "--install", "--in"}
uninstallRequirement = {"--UNINSTALL", "--uninstall", "--un"}
uninstallPIP = {"--UNINSTALL-PIP", "--uninstall-pip", "--un-pip"}
conenctRDP = {"--xfreerdp", "--XFREERDP", "--XFREE", "--xfree"}
pipForce = {"--pipForce", "--Pip-Force", "--PIP-FORCE", "--pip-force", "-Pip-Force"}
autoConnect = {"--autoConnect", "--autoconnect", "--auto", "--AUTO", "-a", "-A"}
skipGlobal = {"--SKIPGLOBAL", "--skip-Global", "--skip-g", "--SKIP-G","--SKIP-Global","--skip-global", "--Skip-Global", "--Skip-global", "-s-g", "-S-G", "-s-G", "-S-g"}
skipLocal = {"--skip-Local", "--SKIP-LOCAL", "--skip-l", "--SKIP-L", "--skip-local", "--Skip-Local", "--Skip-local", "-s-l", "-S-L", "-s-L", "-S-l"}
skipManG = {"--skip-manual-global", "--SKIP-MANUAL-GLOBAL", "--skip-manual-global", "--Skip-Manual-Global", "--Skip-manual-global", "-s-m-g", "-S-M-G", "-s-M-G", "-S-m-g"}
skipManL = {"--skip-manual-local", "--SKIP-MANUAL-LOCAL", "--skip-manual-local", "--Skip-Manual-Local", "--Skip-manual-local", "-s-m-l", "-S-M-L", "-s-M-L", "-S-m-l"}
GlobalHelpPy = {"--GlobalHelp", "--globalHelp", "--GLOBALHELP", "--global-help", "--Global-Help", "--GLOBAL-HELP"}
LocalHelpPy = {"--LocalHelp", "--localHelp", "--LOCALHELP", "--local-help", "--Local-Help", "--LOCAL-HELP"}
ListPackages = {"--list", "--LIST", "--List"}
upgrade = {"--UPGRADE", "--upgrade", "--Upgrade", "-U", "-u", "--up", "--UP", "--Up"}
PackageVersion = {"--Package-Version", "--package-version", "--PACKAGE-VERSION", "-PV", "-pv"}

FIX = {"--FIX", "--fix", "-f", "-F"}

# Define list of scripts to run
#normal commands for NetBreachX
GuiScript = ["bash", "GuiGlobal.sh"]
GlobalScript = ["bash", "GlobalScript.sh"]  # runs the script in Global mode
LocalScript = ["bash", "localScript.sh"]  # runs the script in Local mode
GuiLocalScript = ["bash", "GuiLocal.sh"]  # runs the script that uses GUI mode with local mode
GlobalManual = ["bash", "ManualGlobalScript.sh"]
LocalManual = ["bash", "ManualLocalScript.sh"]
RDPconnect = ["bash", "xfreerdp.sh"]

#argumnent lines
install = ["bash", "requirements.sh"]
installList = ["bash", "requirements.sh", "--list"]
uninstall = ["bash", "uninstall.sh"]
uninstall_PIP = ["bash", "uninstall.sh", "--pip"]
skipGlobalBASH = ["bash", "GlobalScript.sh", "--skip"]
skipLocalBASH = ["bash", "localScript.sh", "--skip"]
skipManGBASH = ["bash", "ManualGlobalScript.sh", "--skip"]
skipManLBASH = ["bash", "ManualLocalScript.sh", "--skip"]
SaveAuto = ["bash", "GlobalScript.sh", "--auto"]
GlobalHelp = ["bash", "GlobalScript.sh", "--help"]
LocalHelp = ["bash", "localScript.sh", "--help"]
upgradeBASH = ["bash", "requirements.sh", "--upgrade"]
PackageVersionBASH = ["bash", "requirements.sh", "--Package-Version"]
PIP = ["bash", "requirements.sh", "--pipForce"]
