#!/bin/bash

# Color codes
RED="\e[31m"
LIGHT_RED="\e[91m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
BLUE="\e[34m"
MAGENTA="\e[35m"
RESET="\e[0m"

CONFIG_FILE="proj_config.conf"
UPDATED=false

# List of required packages
REQUIRED_PACKAGES=("npm" "openssh" "nodejs")
REQUIRED_NPM_LIBRARIES=("express" "cors")

# ASCII Art Header
print_header() {
    echo -e "${CYAN}"
    echo "##############################################################"
    echo "#                                                            #"
    echo "#                    Configuration Script                    #"
    echo "#                                                            #"
    echo "##############################################################"
    echo -e "${RESET}"
}

# ASCII Art Dependency Check
print_dependency_check() {
    echo -e "${LIGHT_RED}"
    echo "##############################################################"
    echo "#                                                            #"
    echo "#               Checking for Missing Dependencies            #"
    echo "#                                                            #"
    echo "##############################################################"
    echo -e "${RESET}"
}

# ASCII Art npm libraries check
print_npm_check_banner() {
    echo -e "${MAGENTA}"
    echo "##############################################################"
    echo "#                                                            #"
    echo "#                 Checking npm Libraries                     #"
    echo "#                                                            #"
    echo "##############################################################"
    echo -e "${RESET}"
}

# ASCII Art Footer
print_footer() {
    echo -e "${BLUE}"
    echo "##############################################################"
    echo "#                     Thank you!                             #"
    echo "##############################################################"
    echo -e "${RESET}"
}

# ASCII Art for Data Entry
data_entry_art() {
    echo -e "${BLUE}"
    echo "------------------------------------------------------------"
    echo "                 Please provide input!                      "
    echo "------------------------------------------------------------"
    echo -e "${RESET}"
}

# Dependency Checking Function
check_dependencies() {
    local total_packages=${#REQUIRED_PACKAGES[@]}  # Total number of dependencies
    local missing_count=0                          # Counter for missing dependencies
    local index=0                                  # Current package index

    echo -e "${CYAN}Checking dependencies...${RESET}"

    for pkg in "${REQUIRED_PACKAGES[@]}"; do
        index=$((index + 1))
        if command -v "$pkg" &>/dev/null; then
            echo -e "[${CYAN}${index}/${total_packages}${RESET}] ${GREEN}[OK]${RESET} ${CYAN}$pkg${RESET} Dependency found"
        else
            echo -e "[${CYAN}${index}/${total_packages}${RESET}] ${RED}[MISSING]${RESET} ${CYAN}$pkg${RESET} Dependency missing"

            # Attempt to install the missing package
            echo -e "${YELLOW}Attempting to install ${CYAN}$pkg${RESET}..."
            if command -v apt &>/dev/null; then
                sudo apt update && sudo apt install -y "$pkg"
            elif command -v yum &>/dev/null; then
                sudo yum install -y "$pkg"
            elif command -v pacman &>/dev/null; then
                sudo pacman -Sy --noconfirm "$pkg"
            else
                echo -e "${RED}Unsupported package manager. Please install $pkg manually.${RESET}"
                missing_count=$((missing_count + 1)) # Increment if no package manager available
                continue
            fi

            # Recheck if the package is installed successfully
            if command -v "$pkg" &>/dev/null; then
                echo -e "${GREEN}${CYAN}$pkg${RESET} installed successfully!${RESET}"
            else
                echo -e "${RED}Failed to install ${CYAN}$pkg${RESET}. Please install it manually.${RESET}"
                missing_count=$((missing_count + 1)) # Increment if the installation failed
            fi
        fi
    done

    # Summary
    echo
    if [ "$missing_count" -gt 0 ]; then
        echo -e "${RED}$missing_count dependencies are missing.${RESET}"
        echo -e "${YELLOW}Please ensure all dependencies are installed.${RESET}"
        exit 1
    else
        echo -e "${GREEN}All dependencies are satisfied!${RESET}"
    fi
}

# Check for required npm packages
install_npm_dependencies() {
    local missing_count=0                              # Counter for missing npm packages
    local total_packages=${#REQUIRED_NPM_LIBRARIES[@]}  # Total number of npm libraries
    local index=0                                      # Current package index

    echo -e "${CYAN}Checking npm libraries...${RESET}"

    for lib in "${REQUIRED_NPM_LIBRARIES[@]}"; do
        index=$((index + 1))
        if npm list -g "$lib" &>/dev/null; then
            echo -e "[${CYAN}${index}/${total_packages}${RESET}] ${GREEN}[OK]${RESET} ${CYAN}$lib${RESET} Library found globally"
        else
            echo -e "[${CYAN}${index}/${total_packages}${RESET}] ${RED}[MISSING]${RESET} ${CYAN}$lib${RESET} Library missing"

            # Attempt to install the missing library
            echo -e "${YELLOW}Attempting to install ${CYAN}$lib${RESET}..."
            if npm install -g "$lib" &>/dev/null; then
                echo -e "${GREEN}${CYAN}$lib${RESET} installed successfully!${RESET}"
            else
                echo -e "${RED}Failed to install ${CYAN}$lib${RESET}. Please install it manually.${RESET}"
                missing_count=$((missing_count + 1))
            fi
        fi
    done

    # Summary
    echo
    if [ "$missing_count" -gt 0 ]; then
        echo -e "${RED}$missing_count npm libraries are missing.${RESET}"
        echo -e "${YELLOW}Please ensure all npm libraries are installed.${RESET}"
        exit 1
    else
        echo -e "${GREEN}All npm libraries are satisfied!${RESET}"
    fi
}

# Function to display help
print_help() {
    echo -e "${CYAN}Usage:${RESET} $0 [options]"
    echo -e "\nThis script is used to configure and check dependencies for the Thermometer Project."
    echo -e "\n${CYAN}Options:${RESET}"
    echo -e "  --conf           Update the configuration file"
    echo -e "  --help           Show this help message"
    echo -e "\n${CYAN}Example:${RESET}"
    echo -e "  sudo ./setup.sh --conf  # Update the configuration file"
    echo -e "  sudo ./setup.sh        # Run the script without updating the configuration"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root or using sudo.${RESET}"
    echo -e "${YELLOW}Please re-run as: ${CYAN}sudo $0${RESET}"
    exit 1
fi

# Check for "--conf" flag to update config
UPDATE_CONFIG=false

if [[ "$@" == *"--conf"* ]]; then
    UPDATE_CONFIG=true
elif [[ "$@" == *"--help"* || "$@" == *"--h"* ]]; then 
    print_help
    exit
fi

# Header
print_header

check_conf_file() {
    # Handle Configuration File
    if [ -f "$CONFIG_FILE" ]; then
        echo -e "${CYAN}Configuration file $CONFIG_FILE exists.${RESET}"

        # Show current configuration
        echo -e "${CYAN}Current Configuration:${RESET}"
        cat "$CONFIG_FILE"

        # Ask user if they want to update it
        if $UPDATE_CONFIG; then
            echo -e "${YELLOW}Updating configuration...${RESET}"
        else
            echo -e "${CYAN}Loading existing configuration.${RESET}"
            source "$CONFIG_FILE"
            CONFIG_MESSAGE="${CYAN}Configuration loaded successfully!${RESET}"
            clear
            print_header
            echo -e "$CONFIG_MESSAGE"
            echo -e "${YELLOW}Database User:${RESET} ${CYAN}$DBUSER${RESET}"
            echo -e "${YELLOW}Database Password:${RESET} ${RED}[hidden]${RESET}"
            echo -e "${YELLOW}Service Name:${RESET} ${CYAN}$SERVICE_NAME${RESET}"
            echo -e "${YELLOW}Web Port:${RESET} ${CYAN}$WEB_PORT${RESET}"
            echo -e "${YELLOW}Node Backend Port:${RESET} ${CYAN}$NODE_PORT${RESET}"
            print_footer

            return
        fi
    else
        echo "Configuration file $CONFIG_FILE not found. Creating a new one..."
        touch "$CONFIG_FILE"
        UPDATED=true
    fi

    # Prompt for missing or default values, updating only if needed
    prompt_and_update() {
        local var_name=$1
        local prompt=$2
        local default_value=$3
        local current_value=${!var_name}

        if [ -z "$current_value" ]; then
            read -p "$prompt [default: $default_value]: " input_value
            eval "$var_name=${input_value:-$default_value}"
            UPDATED=true
        fi
    }

    # Load existing values
    DBUSER=""
    DBPASS=""
    SERVICE_NAME=""
    WEB_PORT=""
    NODE_PORT=""
    data_entry_art

    # Prompt for config values
    prompt_and_update "DBUSER" "Enter the database user" "dbuser"

    if [ -z "$DBPASS" ]; then
        while true; do
            read -sp "Enter the database password: " dbpass1
            echo
            read -sp "Re-enter the database password: " dbpass2
            echo
            if [ "$dbpass1" == "$dbpass2" ]; then
                DBPASS="$dbpass1"
                UPDATED=true
                break
            else
                echo "Passwords do not match. Please try again."
            fi
        done
    fi

    prompt_and_update "SERVICE_NAME" "Enter the service name" "thermometer-web-server"
    prompt_and_update "WEB_PORT" "Enter the web port" "80"
    prompt_and_update "NODE_PORT" "Enter the node backend port" "5000"

    # Save updated values back to the configuration file if any changes were made
    if [ "$UPDATED" = true ]; then
        echo "Saving updated values to $CONFIG_FILE..."
        cat > "$CONFIG_FILE" <<EOF
# Configuration file for the Thermometer Project
# Generated by the setup script
# Modify these values manually or run the script to update them.

# Database user credentials
DBUSER="$DBUSER"           # The username for the database
DBPASS="$DBPASS"           # The password for the database (hidden)

# Service information
SERVICE_NAME="$SERVICE_NAME"  # The name of the web service

# Network configuration
WEB_PORT="$WEB_PORT"        # The port used for the web server
NODE_PORT="$NODE_PORT"      # The port used for the backend server
EOF
        CONFIG_MESSAGE="${GREEN}Configuration updated successfully!${RESET}"
    else
        CONFIG_MESSAGE="${CYAN}Configuration loaded successfully!${RESET}"
    fi

    # Clear the console and print final configuration
    clear
    print_header
    echo -e "$CONFIG_MESSAGE"
    echo -e "${YELLOW}Database User:${RESET} ${CYAN}$DBUSER${RESET}"
    echo -e "${YELLOW}Database Password:${RESET} ${RED}[hidden]${RESET}"
    echo -e "${YELLOW}Service Name:${RESET} ${CYAN}$SERVICE_NAME${RESET}"
    echo -e "${YELLOW}Web Port:${RESET} ${CYAN}$WEB_PORT${RESET}"
    echo -e "${YELLOW}Node Backend Port:${RESET} ${CYAN}$NODE_PORT${RESET}"
    print_footer
}


clear
check_conf_file

# Dependency Checking (System dependencies)
print_dependency_check
check_dependencies
echo  # Adds a newline after system dependency check

# Now display the npm libraries banner
print_npm_check_banner
install_npm_dependencies

