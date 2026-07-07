#!/bin/bash

# Checks if the required configuration file exists
# DontEdit.sh contains variables/functions that this script needs
if [ -f "DontEdit.sh" ]; then
    source DontEdit.sh
else
    echo "DontEdit.sh not found!"
    exit 1
fi


# Function that exits the program when Ctrl+C is pressed
EXIT_PROGRAM_WITH_CTRL_C() {
    echo -e "${RED}[-]${NC} EXITING SOFTWARE..."
    exit 1
}


# Function that exits the program when Ctrl+Z is pressed
EXIT_PROGRAM_WITH_CTRL_Z(){
    echo ""
    echo -e "${RED}[-]${NC} EXITING SOFTWARE..."
    exit 1
}


# Handles Ctrl+Z signal
handle_ctrl_z() {
    EXIT_PROGRAM_WITH_CTRL_Z
}


# Creates a trap so Ctrl+Z calls the exit function
trap 'handle_ctrl_z' SIGTSTP


# Handles Ctrl+C signal
ctrl_c() {
    echo ""
    EXIT_PROGRAM_WITH_CTRL_C
}


# Creates a trap so Ctrl+C calls the exit function
trap ctrl_c SIGINT


# Checks if the operating system is Linux
if [[ "${OSTYPE}" == "linux-gnu"* ]]; then


    # Ask the user for confirmation before removing packages
    echo -e "${RED}${BRIGHT}!Are you sure you want to remove your packages (YES/NO)!: ${NC}"

    read -p ">>> " YES_NO



    # Checks if the user selected YES
    if [[ "${yes[*]}" == *"${YES_NO}"* ]]; then



        # Detects which Linux package manager is installed
        # Supports Debian/Ubuntu, Fedora, and Arch Linux
        if command -v apt >/dev/null 2>&1; then

            PACKAGE_MANAGER="apt"


        elif command -v dnf >/dev/null 2>&1; then

            PACKAGE_MANAGER="dnf"


        elif command -v pacman >/dev/null 2>&1; then

            PACKAGE_MANAGER="pacman"


        else

            # Stops if the Linux distribution is unsupported
            echo "Unsupported Linux distribution"
            exit 1

        fi




        # Function used to check if a package exists
        # Then removes the package using the detected package manager
        check_package() {

            # Stores the package name from the function input
            package_name="$1"


            # Checks if the package is installed
            if command -v "$package_name" >/dev/null 2>&1; then


                echo "$package_name is installed."



                # Removes the package depending on the Linux distribution
                case $PACKAGE_MANAGER in


                    # Debian / Ubuntu
                    apt)

                        sudo apt remove "$package_name" -y

                    ;;



                    # Fedora
                    dnf)

                        sudo dnf remove "$package_name" -y

                    ;;



                    # Arch Linux
                    pacman)

                        sudo pacman -R "$package_name" --noconfirm

                    ;;


                esac


            fi

        }




        # Loops through all system packages
        # Removes each package found
        for package in "${Packages[@]}"
        do

            check_package "$package"

        done




        # Removes Python packages installed with pip
        for pipPackage in "${pipPackages[@]}"
        do


            # Checks if the Python package exists
            if python3 -m pip show "$pipPackage" >/dev/null 2>&1; then



                # Uninstalls the pip package
                pip3 uninstall "$pipPackage" -y



                # Checks if the uninstall failed
                if [ $? -ne 0 ]; then

                    echo -e "Error removing ${pipPackage}"


                else

                    echo -e "${pipPackage}: ${GREEN}removed successfully${NC}"

                fi


            fi


        done




        # Displays removed system packages
        echo ""
        echo "________Packages Removed________"


        for package in "${Packages[@]}"
        do

            echo "$package"

        done




        # Displays removed Python packages
        echo ""
        echo "________PIP Packages Removed________"


        for pipPackage in "${pipPackages[@]}"
        do

            echo "$pipPackage"

        done





    # If the user selects NO, exit without removing anything
    elif [[ "${no[*]}" == *"$YES_NO"* ]]; then


        echo -e "${GREEN}${BRIGHT}Ok, I will not remove the packages.${NC}"

        exit 1


    fi




# If the system is not Linux
else

    echo -e "[ ${RED}FAIL${NC} ] This script can only run on Linux"

fi