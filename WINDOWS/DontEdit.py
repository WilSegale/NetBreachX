import os
import sys
import logging
import socket
import platform
import asyncio
from paramiko import SSHClient, AutoAddPolicy
from concurrent.futures import ThreadPoolExecutor, as_completed
from aiohttp import ClientSession, ClientTimeout
import re

RED = "\033[31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
BLUE = "\033[34m"
ORANGE_Start = "\033[38;2;255;165;0m"
ORANGE_END = "\033[0m"
BRIGHT = "\033[1m"
RESET = "\033[0m"
GRAY_TEXT = "\033[90m"
CYAN_TEXT = "\033[36m"