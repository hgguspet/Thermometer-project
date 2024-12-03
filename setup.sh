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
PHP_INI_FILE="/etc/php/php.ini"


# Runtime variables
UPDATED=false
 
# List of required packages (check for their commands, not the package itself)
REQUIRED_PACKAGES=("npm" "ssh" "node" "php")  # We now check for 'ssh' instead of 'openssh'
REQUIRED_NPM_LIBRARIES=("express" "cors" "child_process" "mysql")

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

# Function to handle flags and parameters
handle_flags() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --conf)
                check_and_update_config 
                shift
                ;;
            --help | -h)
                print_help
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${RESET}"
                print_help
                exit 1
                ;;
        esac
    done
}


# Function to enable MySQL extensions in php.ini
enable_mysql_extensions() {
    # Check if php.ini exists
    if [[ ! -f "$PHP_INI_FILE" ]]; then
        echo -e "${RED}Error: php.ini file not found at $PHP_INI_FILE${RESET}"
        return 1
    fi

    # Enable mysqli extension
    if ! grep -q "^extension=mysqli" "$PHP_INI_FILE"; then
        echo -e "${YELLOW}Enabling mysqli extension...${RESET}"
        sudo sed -i 's/^;extension=mysqli/extension=mysqli/' "$PHP_INI_FILE"
        echo -e "${GREEN}mysqli extension enabled successfully.${RESET}"
    else
        echo -e "${GREEN}mysqli extension is already enabled.${RESET}"
    fi

    # Enable pdo_mysql extension
    if ! grep -q "^extension=pdo_mysql" "$PHP_INI_FILE"; then
        echo -e "${YELLOW}Enabling pdo_mysql extension...${RESET}"
        sudo sed -i 's/^;extension=pdo_mysql/extension=pdo_mysql/' "$PHP_INI_FILE"
        echo -e "${GREEN}pdo_mysql extension enabled successfully.${RESET}"
    else
        echo -e "${GREEN}pdo_mysql extension is already enabled.${RESET}"
    fi

    echo -e "${GREEN}MySQL extensions enabled successfully!${RESET}"
}

# Function to check if the configuration file exists and update it if necessary
check_and_update_config() {
    # Load the current configuration
    load_config

    # Display current configuration
    echo -e "${CYAN}Current Configuration:${RESET}"
    display_current_config

    # Ask if the user wants to update the configuration
    if [ "$UPDATED" = true ]; then
        read -p "Would you like to update it? (y/n): " update_choice
        if [[ "$update_choice" =~ ^[Yy]$ ]]; then
            clear
            echo -e "${YELLOW}Updating configuration...${RESET}"
            
            # Prompt for all config values, using defaults where applicable
            prompt_and_update "DBUSER" "Enter the database user" "$DBUSER"
            prompt_and_update "DBPASS" "Enter the database password" "$DBPASS"
            prompt_and_update "SERVICE_NAME" "Enter the service name" "$SERVICE_NAME"
            prompt_and_update "WEB_PORT" "Enter the web port" "$WEB_PORT"
            prompt_and_update "NODE_PORT" "Enter the node backend port" "$NODE_PORT"
            prompt_and_update "BUFFER_TABLE" "Enter the buffer table name" "$BUFFER_TABLE"
            prompt_and_update "HOURLY_TABLE" "Enter the hourly average table name" "$HOURLY_TABLE"
            
            # Save the updated configuration to the file
            update_config_file
        else
            echo -e "${CYAN}No changes made. Keeping the current configuration.${RESET}"
        fi
    else
        echo -e "${CYAN}No updates required. Using current configuration.${RESET}"
    fi
}

# Function to load configuration from the file
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        echo -e "${CYAN}Loading configuration from $CONFIG_FILE...${RESET}"
        # Read the config file and assign values to variables
        while IFS='=' read -r key value; do
            case "$key" in
                "DBUSER") DBUSER="$value" ;;
                "DBPASS") DBPASS="$value" ;;
                "SERVICE_NAME") SERVICE_NAME="$value" ;;
                "WEB_PORT") WEB_PORT="$value" ;;
                "NODE_PORT") NODE_PORT="$value" ;;
                "BUFFER_TABLE") BUFFER_TABLE="$value" ;;
                "HOURLY_TABLE") HOURLY_TABLE="$value" ;;
            esac
        done < "$CONFIG_FILE"
        echo -e "${GREEN}Configuration loaded successfully!${RESET}"
    else
        echo -e "${RED}Configuration file $CONFIG_FILE not found. Creating a new one...${RESET}"
        UPDATED=true
    fi
}

# Function to display the current configuration
display_current_config() {
    echo -e "${CYAN}Current Configuration:${RESET}"
    echo -e "${YELLOW}Database User:${RESET} ${CYAN}$DBUSER${RESET}"
    echo -e "${YELLOW}Database Password:${RESET} ${RED}[hidden]${RESET}"
    echo -e "${YELLOW}Service Name:${RESET} ${CYAN}$SERVICE_NAME${RESET}"
    echo -e "${YELLOW}Web Port:${RESET} ${CYAN}$WEB_PORT${RESET}"
    echo -e "${YELLOW}Node Backend Port:${RESET} ${CYAN}$NODE_PORT${RESET}"
    echo -e "${YELLOW}Buffer Table:${RESET} ${CYAN}$BUFFER_TABLE${RESET}"
    echo -e "${YELLOW}Hourly Table:${RESET} ${CYAN}$HOURLY_TABLE${RESET}"
}

# Function to prompt for missing or default values and update the config
prompt_and_update() {
    local var_name=$1
    local prompt=$2
    local default_value=$3
    local current_value=${!var_name}

    # Show the default value in the prompt if the current value is empty
    if [ -z "$current_value" ]; then
        read -p "$prompt [default: $default_value]: " input_value
        eval "$var_name=${input_value:-$default_value}"
    fi
}

# Function to update the configuration file
update_config_file() {
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

# Database tables
BUFFER_TABLE="$BUFFER_TABLE" # The name of the buffer table
HOURLY_TABLE="$HOURLY_TABLE" # The name of the hourly average table
EOF
    echo -e "${GREEN}Configuration updated successfully!${RESET}"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root or using sudo.${RESET}"
    echo -e "${YELLOW}Please re-run as: ${CYAN}sudo $0${RESET}"
    exit 1
fi


clear

# Handle flags 
handle_flags "$@"



# Dependency Checking (System dependencies)
print_dependency_check
check_dependencies

# Now display the npm libraries banner
print_npm_check_banner
install_npm_dependencies

# Enable mysql php extension
enable_mysql_extensions
