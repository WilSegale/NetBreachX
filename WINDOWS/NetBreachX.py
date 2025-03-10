# Import statements remain the same
from DontEdit import *
# Constants
LOG_FILE = "netbreach.LOG"
TIMEOUT = 5
MAX_THREADS = 20  # Adjust for more or less concurrency

# Setup logging
logging.basicConfig(filename=LOG_FILE, level=logging.INFO, format="%(asctime)s - %(message)s")

# Validate subnet input
def validate_subnet(subnet):
    pattern = r"^\d{1,3}\.\d{1,3}\.\d{1,3}$"
    return re.match(pattern, subnet)

def get_valid_subnet():
    while True:
        subnet = input("Enter subnet (e.g., 192.168.1): ")
        if validate_subnet(subnet):
            return subnet
        else:
            print("Invalid subnet format. Please try again.")

# Async network scan to find active hosts
async def scan_ip_async(session, ip):
    url = f"http://{ip}"
    try:
        async with session.get(url, timeout=ClientTimeout(total=TIMEOUT)) as response:
            if response.status == 200:
                return ip
    except:
        return None

async def network_scan_async(subnet):
    active_hosts = []
    async with ClientSession() as session:
        tasks = [scan_ip_async(session, f"{subnet}.{i}") for i in range(1, 255)]
        for result in await asyncio.gather(*tasks):
            if result:
                active_hosts.append(result)
    return active_hosts

# Connect to SSH
def ssh_connect_with_timeout(host, username, password, port, timeout=10):
    try:
        client = SSHClient()
        client.set_missing_host_key_policy(AutoAddPolicy())
        client.connect(host, port=port, username=username, password=password, timeout=timeout)
        logging.info(f"Connected to {host}:{port}")
        print(f"Connected to {host}:{port}")
        return client
    except Exception as e:
        logging.error(f"Failed to connect to {host}:{port}: {e}")
        print(f"Failed to connect to {host}:{port}: {e}")
        return None

# Disconnect from SSH
def ssh_disconnect(client):
    try:
        client.close()
        logging.info("SSH session closed.")
        print("SSH session closed.")
    except Exception as e:
        logging.error(f"Error disconnecting: {e}")

# Parallelized password checking
def check_weak_passwords_parallel(host, username, password_list, port):
    with ThreadPoolExecutor(max_workers=MAX_THREADS) as executor:
        futures = {executor.submit(attempt_login, host, username, password, port): password for password in password_list}
        for future in as_completed(futures):
            result = future.result()
            if result:
                print(f"Success! {host}:{port} - {username}:{result}")
                return
    print(f"No weak passwords found for {host}:{port}")

# Attempt SSH login
def attempt_login(host, username, password, port):
    client = ssh_connect_with_timeout(host, username, password, port)
    if client:
        ssh_disconnect(client)
        return password
    return None

# Terminate SSH session
def terminate_ssh_session(ip):
    try:
        if platform.system() == "Windows":
            os.system(f"taskkill /F /FI \"WINDOWTITLE eq {ip}\"")
        else:
            os.system(f"pkill -f {ip}")
        logging.info(f"Terminated SSH session for {ip}.")
        print(f"Terminated SSH session for {ip}.")
    except Exception as e:
        logging.error(f"Failed to terminate session for {ip}: {e}")
        print(f"Failed to terminate session for {ip}: {e}")

# Main menu
def main():
    try:
        while True:
            print("\nNetBreach - Network Security Tool")
            print("1. Scan Network")
            print("2. Manage SSH Sessions")
            print("3. Check for Weak Passwords")
            print("4. Terminate SSH Session")
            print("5. Exit")
            
            choice = input("Enter your choice: ")
            
            if choice == "1":
                subnet = get_valid_subnet()
                hosts = asyncio.run(network_scan_async(subnet))  # Async network scan
                print(f"Active hosts: {hosts}")
            elif choice == "2":
                host = input("Enter SSH host: ")
                port = int(input("Enter port number (default 22): ") or 22)
                username = input("Enter username: ")
                password = input("Enter password: ")
                client = ssh_connect_with_timeout(host, username, password, port)
                if client:
                    ssh_disconnect(client)
            elif choice == "3":
                host = input("Enter SSH host: ")
                port = int(input("Enter port number (default 22): ") or 22)
                username = input("Enter username: ")
                password_file = "rockyou.txt"  # Example password list
                with open(password_file, "r") as file:
                    passwords = file.read().splitlines()
                check_weak_passwords_parallel(host, username, passwords, port)  # Parallel password checking
            elif choice == "4":
                ip = input("Enter IP of session to terminate: ")
                terminate_ssh_session(ip)
            elif choice == "5":
                print("Exiting NetBreach.")
                sys.exit()
            else:
                print("Invalid choice.")
    except KeyboardInterrupt:
        print("\nExiting NetBreach.")
        sys.exit()

if __name__ == "__main__":
    # Check if the platform is not "win32" (Windows)
    if platform.system() != "Windows":
            print(f"{BRIGHT}{RED}[-]{RESET} Not supported for your OS")
    else:
        main()