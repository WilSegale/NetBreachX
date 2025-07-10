#!/bin/bash
# Check if root user
# Load DontEdit.sh if it exists
if [ -f "DontEdit.sh" ]; then
    source DontEdit.sh
else
    echo "DontEdit.sh not found!"
    exit 1
fi

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

    # Load DontEdit.sh if it exists
    if [ -f "DontEdit.sh" ]; then
        source DontEdit.sh
    else
        echo "DontEdit.sh not found!"
        exit 1
    fi

    # Help function
    HELP() {
        echo "REQUIREMENTS HELP"
        echo "_________________"
        echo "This script is used to check if the system has the required packages installed."
        echo "If the pip packages fail to install type"
        echo '''bash requirements.sh --pipForce'''
        echo "_________________"
        exit 1
    }

        # Determine package manager (apt or yum)
    if command -v apt &>/dev/null; then
        PKG_MANAGER="apt"
    elif command -v yum &>/dev/null; then
        PKG_MANAGER="yum"
    else
        echo "Unsupported package manager. This script supports apt and yum."
        exit 1
    fi

    # Function to install packages
    install_package() {
        package_name="$1"
        if [ "$PKG_MANAGER" == "apt" ]; then
            if ! dpkg -l | grep -q "^ii  ${package_name} "; then
                sudo apt update
                sudo apt install -y "${package_name}"
            fi
        elif [ "$PKG_MANAGER" == "yum" ]; then
            if ! rpm -q "${package_name}" &>/dev/null; then
                sudo yum install -y "${package_name}"
            fi
        fi
    }


    # Function to check for installed packages
    checkForPackages() {
        for package in "${Packages[@]}"; do
            if dpkg -l | grep -q "^ii  ${package} "; then
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
        if $pipForceMode; then
            title="[+] PIP FORCE"
            message="Using PIP FORCE mode"
            notify-send "$title" "$message"
            if python3 -m pip install --upgrade pip --break-system-packages; then
                echo -e "[ ${GREEN}OK${NC} ] pip upgraded successfully."
            else
                echo -e "[ ${RED}ERROR${NC} ] Failed to upgrade pip with force."
            fi
        else
            title="[-] PIP FORCE"
            message="Not using PIP FORCE mode"
            notify-send "$title" "$message"
            if python3 -m pip install --upgrade pip; then
                echo -e "[ ${GREEN}OK${NC} ] pip upgraded successfully."
            else
                echo -e "[ ${RED}ERROR${NC} ] Failed to upgrade pip."
            fi
        fi

        package_name="$1"
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

    listForPackages() {
        echo "_________APT PACKAGE CHECK________"
        for package in "${Packages[@]}"; do
            if dpkg -l | grep -w "^ii" | grep -qw "$package"; then
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

        echo -e "\nDo you want me to update the packages for you?"
        read -p ">>> " update

        if [[ " ${yes[*]} " == *" ${install} "* ]]; then
            upgradePackages
        fi
        echo -e "\n_________APT PACKAGE UPDATE CHECK________"
        for package in "${Packages[@]}"; do
            if apt list --upgradable 2>/dev/null | grep -q "^$package/"; then
                echo "${package} ❗ (needs update)"
            else
                echo "${package} ✅ (up to date)"
            fi
        done

        exit
    }

    upgradePackages() {
        echo "________UPGRADING APT PACKAGES________"
        for package in "${Packages[@]}"; do
            if dpkg -l | grep -q "^ii  ${package} "; then
                sudo apt update
                sudo apt upgrade -y "${package}"
            else
                echo -e "[ ${RED}FAIL${NC} ] ${package} not installed."
            fi
        done

        echo "________UPGRADING PIP PACKAGES________"
        for pipPackage in "${pipPackages[@]}"; do
            if python3 -c "import ${pipPackage}" &>/dev/null; then
                install_pip_package "${pipPackage}"
            else
                echo -e "[ ${RED}FAIL${NC} ] ${pipPackage} not installed."
            fi
        done
    }
    # Function to install packages
    # Handle Ctrl+Z (SIGTSTP)
    trap 'EXIT_PROGRAM_WITH_CTRL_Z' SIGTSTP

    # Handle Ctrl+C (SIGINT)
    trap 'EXIT_PROGRAM_WITH_CTRL_C' SIGINT

    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        HELP
    # list of packages taht are installed or not
    elif [[ "$1" == "--list" ]]; then
        listForPackages

    elif [[ "$1" == "--upgrade" ]]; then
        upgradePackages

    fi
    # Check for installed packages
    checkForPackages
else
    echo -e "[ ${yellow}${BRIGHT}WARNING${NC} ] This script is only supported on ${GREEN}${OS}${NC} operating systems."
    exit 1
fi