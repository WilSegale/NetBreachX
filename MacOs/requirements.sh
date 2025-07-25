#!/bin/bash
# Load DontEdit.sh if it exists
if [ -f "DontEdit.sh" ]; then
    source DontEdit.sh
else
    echo "DontEdit.sh not found!"
    exit 1
fi

# quits program with ctrl-c
EXIT_PROGRAM_WITH_CTRL_C() {
    echo ""
    echo -e "${RED}${BRIGHT}[-]${NC} EXITING SOFTWARE..."
    # Add cleanup commands here
    exit 1
}

# quits program with ctrl-z
EXIT_PROGRAM_WITH_CTRL_Z(){
    echo ""
    echo -e "${RED}${BRIGHT}[-]${NC} EXITING SOFTWARE..."
    # Add cleanup commands here
    exit 1
}

# Function to be executed when Ctrl+Z is pressed
handle_ctrl_z() {
    EXIT_PROGRAM_WITH_CTRL_Z
    exit 1
    # Your custom action goes here
}

# Set up the trap to call the function on SIGTSTP (Ctrl+Z)
trap 'handle_ctrl_z' SIGTSTP

# Function to handle Ctrl+C
ctrl_c() {
    echo ""
    EXIT_PROGRAM_WITH_CTRL_C
}

trap ctrl_c SIGINT


# get the os type and if its not a MAC then it say error you are not using a MAC computer
if [[ "$OSTYPE" == "${OS}"* ]]; then

    # Default values
    pipForceMode=false

    # Argument Parsing
    for arg in "$@"; do
        case $arg in
            --pipForce)
                pipForceMode=true
                shift
                ;;
        esac
    done

    # Wifi connection check function
    WifiConnection() {
        if ping -c 1 google.com >/dev/null 2>&1; then
            # Check if Homebrew is installed
            if command -v brew &> /dev/null; then
                installPackages
            else
                InstallHomeBrew
            fi
        else
            echo -e "[ ${RED}FAIL${NC} ] NOT CONNECTED TO THE INTERNET"
        fi
    }

    # Help function
    HELP(){
        echo "REQUIREMENTS HELP"
        echo "_________________"
        echo "This script is used to check if the system has the required packages installed."
        echo "If the pip packages fail to install type"
        echo '''bash requirements.sh --pipForce'''
        echo "_________________"
        exit 1
    }

    # Install Homebrew if not already installed
    InstallHomeBrew() {
        echo ""
        echo -e "[ ${RED}${BRIGHT}!${NC} ] Checking Homebrew installation..."
        if command -v brew &>/dev/null; then
            echo -e "[ ${GREEN}OK${NC} ] Homebrew is already installed."
        else
            echo "Homebrew is not installed."
            echo "Would you like to install Homebrew? (YES/NO)"
            read -p ">>> " answer
            if [[ " ${yes[*]} " == *" ${answer} "*  ]]; then
                echo "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                sleep 1
                eval "$(/opt/homebrew/bin/brew shellenv)"
                if [ $? -ne 0 ]; then
                    echo -e "[ ${RED}FAIL${NC} ] Homebrew installation failed."
                else
                    echo -e "[ ${GREEN}OK${NC} ] Homebrew installation successful."
                    echo -e "\n${GREEN}Run the program again to install the rest of the packages.${NC}"
                fi
            else
                echo "Exiting the script."
                exit 1
            fi
        fi
    }

    # Function to install a package using brew
    install_brew_package() {
        package_name="$1"
        if ! brew list --formula | grep -q "^${package_name}\$"; then
            brew install "${package_name}"
            if [ $? -eq 0 ]; then
                echo -e "[ ${GREEN}OK${NC} ] ${package_name} installed successfully."
            else
                echo -e "[ ${yellow}WARNING${NC} ] ${package_name} installation failed."
            fi
        else
            echo -e "[ ${GREEN}OK${NC} ] ${package_name} is already installed."
        fi
    }

    # Function to check for installed packages
    checkForPackages() {
        for package in "${Packages[@]}"; do
            if brew list --formula | grep -q "^${package}\$"; then
                echo -e "[ ${GREEN}OK${NC} ] ${package}"
            else
                echo -e "[ ${RED}FAIL${NC} ] ${package}"
            fi
        done

        echo -e "________PIP Packages________"
        for pipPackage in "${pipPackages[@]}"; do
            if python3 -c "import ${pipPackage}" &>/dev/null; then
                echo -e "[ ${GREEN}OK${NC} ] ${pipPackage}"
            else
                echo -e "[ ${RED}FAIL${NC} ] ${pipPackage}"
            fi
        done
    }

    # Function to install pip package
    install_pip_package() {
        # Notification title and message
        if $pipForceMode; then
            title="[+] PIP FORCE"
            message="Using PIP FORCE mode"
            osascript -e "display notification \"$message\" with title \"$title\""
            
            # Upgrade pip with force
            if python3 -m pip install --upgrade pip --break-system-packages; then
                echo -e "[ ${GREEN}OK${NC} ] pip upgraded successfully."
            else
                echo -e "[ ${RED}ERROR${NC} ] Failed to upgrade pip with force."
            fi
        else
            title="[-] PIP FORCE"
            message="Not using PIP FORCE mode"
            osascript -e "display notification \"$message\" with title \"$title\""
            
            # Normal pip upgrade
            if python3 -m pip install --upgrade pip; then
                echo -e "[ ${GREEN}OK${NC} ] pip upgraded successfully."
            else
                echo -e "[ ${RED}ERROR${NC} ] Failed to upgrade pip."
            fi
        fi


        # Now the package name is in $1
        package_name="$1"

        # Install the package
        python3 -m pip install --user --upgrade "${package_name}" --break-system-packages
        if [ $? -eq 0 ]; then
            if python3 -c "import ${package_name}" &>/dev/null; then
                echo -e "[ ${GREEN}OK${NC} ] ${package_name} installed and verified successfully."
            else
                echo -e "[ ${RED}FAIL${NC} ] ${package_name} installed but could not be imported in Python."
                exit 1
            fi
        else
            echo -e "[ ${RED}FAIL${NC} ] Failed to install ${package_name}."
            exit 1
        fi
    }

    # Install packages function
    installPackages() {
        if [ "$(id -u)" -eq 0 ]; then
            echo ""
            echo "+++++++++++++++++++++++++++++++++++++++++"
            echo "+   Don't use sudo for this script.     +"
            echo "+   Because it can damage your computer +"
            echo "+++++++++++++++++++++++++++++++++++++++++"
            echo ""
            exit 1
        else
            if [[ "${OSTYPE}" == "darwin"* ]]; then
                echo "_________BREW PACKAGES INSTALLATION________"
                for package in "${Packages[@]}"; do
                    install_brew_package "${package}"
                done

                echo "_________PIP PACKAGES INSTALLATION AND PIP UPDATE________"
                for PIP in "${pipPackages[@]}"; do
                    install_pip_package "${PIP}"
                done

                echo "_________INSTALLED PACKAGES________"
                checkForPackages
            else
                echo -e "[ ${RED}FAIL${NC} ] Unsupported OS. Please use macOS."
            fi
        fi
    }

    listForPackages() {
        echo "_________BREW PACKAGE CHECK________"
        for package in "${Packages[@]}"; do
            if brew list --formula | grep -q "^$package\$"; then
                echo "${package} ✅"
            else
                echo "${package} ❌ (not installed)"
            fi
        done

        echo -e "\n_________PIP PACKAGE CHECK________"
        for pip_pkg in "${pipPackages[@]}"; do
            if pip3 list --format=freeze 2>/dev/null | grep -i "^$pip_pkg=="; then
                echo "${pip_pkg} ✅"
            else
                echo "${pip_pkg} ❌ (not installed)"
            fi
        done
        
        echo -e "\nDo you want me to update the packages for you? "Yes/No/Install""

        read -p ">>> " update
        if [[ " ${yes[*]} " == *" ${update} "* ]]; then
            upgradePackages
        
        elif [[ " ${forceInstall[*]} " == *" ${update} "* ]]; then
            installPackages
        fi
        echo -e "\n_________BREW PACKAGE UPDATE CHECK________"
        for package in "${Packages[@]}"; do
            if brew outdated | grep -q "^$package"; then
                echo "${package} ❗ (needs update)"
            else
                echo "${package} ✅ (up to date)"
            fi
        done

        exit
    }
    
    upgradePackages() {
        echo "_________BREW PACKAGE UPGRADE________"
        for package in "${Packages[@]}"; do
            brew upgrade "${package}"
            if [ $? -eq 0 ]; then
                echo -e "[ ${GREEN}OK${NC} ] ${package} upgraded successfully."
            else
                echo -e "[ ${RED}FAIL${NC} ] ${package} upgrade failed."
            fi
        done

        echo -e "\n_________PIP PACKAGE UPGRADE________"
        for pip_pkg in "${pipPackages[@]}"; do
            python3 -m pip install --upgrade "${pip_pkg}"
            if [ $? -eq 0 ]; then
                echo -e "[ ${GREEN}OK${NC} ] ${pip_pkg} upgraded successfully."
            else
                echo -e "[ ${RED}FAIL${NC} ] ${pip_pkg} upgrade failed."
            fi
        done

        exit
    }
    # Handle Ctrl+Z (SIGTSTP)
    trap 'EXIT_PROGRAM_WITH_CTRL_Z' SIGTSTP

    # Handle Ctrl+C (SIGINT)
    trap 'EXIT_PROGRAM_WITH_CTRL_C' SIGINT

    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        HELP
    
    elif [[ "$1" == "--list" ]]; then
        listForPackages
    
    elif [[ "$1" == "--upgrade" ]]; then
        upgradePackages
    fi

    WifiConnection
else
    echo -e "[ ${yellow}${BRIGHT}WARNING${NC} ] This script is only supported on ${GREEN}${OS}${NC} operating systems."
    exit 1
fi