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


# Path to the configuration file
CONFIG_FILE="./conf/proj_vars.conf"
JSON_FILE="./conf/config.json"
# Path to php.ini file, used to enable mysqli
PHP_INI_FILE="/etc/php/php.ini"

NPM_DIR="./web/src/"
 
# List of required packages (check for their commands, not the package itself)
REQUIRED_PACKAGES=("npm" "ssh" "node" "php" "mariadb" "expect" "jq" "ufw")  # We now check for 'ssh' instead of 'openssh'
REQUIRED_NPM_LIBRARIES=("express" "cors" "child_process" "mysql" "serve" )

services=("sshd" "mariadb")

# Define the parameters and their default values
parameters=(
    "DBUSER=dbuser"
    "DBPASS="
    "SERVICE_NAME=Thermometer_proj_service"
    "WEB_PORT=80"
    "NODE_PORT=5000"
    "BUFFER_TABLE=buffer_table"
    "HOURLY_TABLE=hourly_table"
)

print_server_manager_banner() {
    echo -e "${CYAN}"
    echo " ___                        __  __                             "
    echo "/ __| ___ _ ___ _____ _ _  |  \/  |__ _ _ _  __ _ __ _ ___ _ _ "
    echo "\\__ \\/ -_) '_\\ V / -_) '_| | |\\/| / _\` | ' \\/ _\` / _\` / -_) '_|"
    echo "|___/\___|_|  \_/\___|_|   |_|  |_\__,_|_||_\__,_\__, \___|_|  "
    echo "                                                |___/         "
    echo -e "${RESET}" 
}

print_dependency_check() {
    echo
    echo -e "${RED}████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████${RESET}"
    echo -e "${RED}████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████${RESET}"
    echo
    echo -e "${CYAN}██████  ██    ██ ███    ██ ███    ██ ██ ███    ██  ██████      ██ ███    ██ ███████ ████████  █████  ██      ██          ███████  ██████ ██████  ██ ██████  ████████ ${RESET}"
    echo -e "${CYAN}██   ██ ██    ██ ████   ██ ████   ██ ██ ████   ██ ██           ██ ████   ██ ██         ██    ██   ██ ██      ██          ██      ██      ██   ██ ██ ██   ██    ██    ${RESET}"
    echo -e "${CYAN}██████  ██    ██ ██ ██  ██ ██ ██  ██ ██ ██ ██  ██ ██   ███     ██ ██ ██  ██ ███████    ██    ███████ ██      ██          ███████ ██      ██████  ██ ██████     ██    ${RESET}"
    echo -e "${CYAN}██   ██ ██    ██ ██  ██ ██ ██  ██ ██ ██ ██  ██ ██ ██    ██     ██ ██  ██ ██      ██    ██    ██   ██ ██      ██               ██ ██      ██   ██ ██ ██         ██    ${RESET}"
    echo -e "${CYAN}██   ██  ██████  ██   ████ ██   ████ ██ ██   ████  ██████      ██ ██   ████ ███████    ██    ██   ██ ███████ ███████     ███████  ██████ ██   ██ ██ ██         ██    ${RESET}"
    echo
    echo -e "${RED}████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████${RESET}"
    echo -e "${RED}████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████${RESET}"
    echo
}


print_conf_edit_script_text() {
    echo -e "${RED}████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████${RESET}"
    echo -e "${RED}████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████${RESET}"
    echo
    echo -e "${CYAN} ██████  ██████  ███    ██ ███████ ██  ██████      ███████ ██████  ██ ████████     ███████  ██████ ██████  ██ ██████  ████████ ${RESET}"
    echo -e "${CYAN}██      ██    ██ ████   ██ ██      ██ ██           ██      ██   ██ ██    ██        ██      ██      ██   ██ ██ ██   ██    ██    ${RESET}"
    echo -e "${CYAN}██      ██    ██ ██ ██  ██ █████   ██ ██   ███     █████   ██   ██ ██    ██        ███████ ██      ██████  ██ ██████     ██    ${RESET}"
    echo -e "${CYAN}██      ██    ██ ██  ██ ██ ██      ██ ██    ██     ██      ██   ██ ██    ██             ██ ██      ██   ██ ██ ██         ██    ${RESET}"
    echo -e "${CYAN} ██████  ██████  ██   ████ ██      ██  ██████      ███████ ██████  ██    ██        ███████  ██████ ██   ██ ██ ██         ██    ${RESET}"
    echo
    echo -e "${RED}████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████${RESET}"
    echo -e "${RED}████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████${RESET}"
}

# Function to extract parameter values and set environment variables
set_env_variables() {
    for param in "${parameters[@]}"; do
        key="${param%%=*}"   # Extract the key (everything before '=')
        value="${param#*=}"  # Extract the value (everything after '=')

        # Set environment variables only for ports
        if [[ "$key" == "WEB_PORT" || "$key" == "NODE_PORT" ]]; then
            export "$key=$value"
            echo "Exported $key=$value"
        fi
    done
}

# Function to parse the configuration file
parse_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue

            # Remove whitespace
            key=$(echo "$key" | xargs)
            value=$(echo "$value" | xargs)

            # Update the parameters list
            for i in "${!parameters[@]}"; do
                param_key="${parameters[$i]%%=*}"
                if [[ "$key" == "$param_key" ]]; then
                    parameters[$i]="$key=$value"
                fi
            done
        done < "$CONFIG_FILE"
    fi
}

# Function to write the configuration back to the file
write_config() {
    # Backup the old configuration file
    cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"

    # Write the configuration to the file
    {
        echo "# Configuration file for the Thermometer Project"
        echo "# Generated by the script"
        for param in "${parameters[@]}"; do
            echo "$param"
        done
    } > "$CONFIG_FILE"
}




# Function to edit the config file
interactive_config() {
    echo "Enter new configuration values. Password is required. Press Enter to keep other values."

    for i in "${!parameters[@]}"; do
        key="${parameters[$i]%%=*}"
        current_value="${parameters[$i]#*=}"

        if [[ "$key" == "DBPASS" ]]; then
            # Special handling for passwords (mandatory)
            while true; do
                echo -n "$key (required, hidden): "
                read -s new_password1
                echo
                echo -n "Confirm $key: "
                read -s new_password2
                echo

                if [[ -z "$new_password1" ]]; then
                    echo "Password cannot be empty. Please try again."
                elif [[ "$new_password1" != "$new_password2" ]]; then
                    echo "Passwords do not match. Please try again."
                else
                    parameters[$i]="$key=$new_password1"
                    break
                fi
            done
        else
            # Standard handling for other keys
            echo -n "$key [$current_value]: "
            read -r new_value

            # If the user enters a value, update it; otherwise, keep the current value
            if [[ -n "$new_value" ]]; then
                parameters[$i]="$key=$new_value"
            else
                parameters[$i]="$key=$current_value"
            fi
        fi
    done

    write_config # Save the new configuration
}



# Function to print the configuration
print_config() {
    echo "Current Configuration:"
    for param in "${parameters[@]}"; do
        key="${param%%=*}"
        value="${param#*=}"
        if [[ "$key" == "DBPASS" ]]; then
            echo "$key=******"  # Mask the password
        else
            echo "$param"  # Print the key-value pair as is
        fi
    done
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
            echo -e "[${CYAN}${index}/${total_packages}${RESET}] ${RESET}[ ${GREEN}OK ${RESET}] ${CYAN}$pkg${RESET} Dependency found"
        else
            echo -e "[${CYAN}${index}/${total_packages}${RESET}] ${RESET}[ ${RED}MISSING ${RESET}] ${CYAN}$pkg${RESET} Dependency missing"

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
            echo -e "[${CYAN}${index}/${total_packages}${RESET}] ${RESET}[ ${GREEN}OK ${RESET}] ${CYAN}$lib${RESET} Library found globally"
        else
            echo -e "[${CYAN}${index}/${total_packages}${RESET}] ${RESET}[ ${RED}MISSING ${RESET}] ${CYAN}$lib${RESET} Library missing"

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


# Function to enable and start services
manage_services() {
    # List of services to manage
    for service in "${services[@]}"; do
        echo -e "${CYAN}Managing service: ${YELLOW}$service${RESET}"

        # Enable the service
        echo -e "${GREEN}Enabling ${YELLOW}$service${GREEN}...${RESET}"
        sudo systemctl enable "$service" > /dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}Failed to enable ${YELLOW}$service${RED}. Skipping...${RESET}"
            continue
        fi

        # Start the service
        echo -e "${GREEN}Starting ${YELLOW}$service${GREEN}...${RESET}"
        sudo systemctl start "$service" > /dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}Failed to start ${YELLOW}$service${RED}.${RESET}"
        else
            echo -e "${GREEN}$service successfully enabled and started.${RESET}"
        fi
    done
}


# Function to automate MariaDB secure installation
secure_mariadb() {
    echo -e "${YELLOW}Automating MariaDB secure installation...${RESET}"

    # Automate mysql_secure_installation using an `expect` script
    expect <<EOF
spawn sudo mysql_secure_installation

expect "Enter current password for root (enter for none):"
send "\r"

expect "Switch to unix_socket authentication"
send "n\r"

expect "Change the root password?"
send "n\r"

expect "Remove anonymous users?"
send "Y\r"

expect "Disallow root login remotely?"
send "n\r"

expect "Remove test database and access to it?"
send "Y\r"

expect "Reload privilege tables now?"
send "Y\r"

expect eof
EOF

    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}MariaDB secure installation completed successfully.${RESET}"
    else
        echo -e "${RED}Failed to complete MariaDB secure installation.${RESET}"
        exit 1
    fi
}

# Function to enable and start MariaDB
setup_mariadb_service() {
    echo -e "${YELLOW}Enabling and starting MariaDB service...${RESET}"
    sudo systemctl enable mariadb > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Failed to enable MariaDB service.${RESET}"
        exit 1
    fi

    sudo systemctl start mariadb > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Failed to start MariaDB service.${RESET}"
        exit 1
    fi
    echo -e "${GREEN}MariaDB service enabled and started successfully.${RESET}"
}




# Function to extract parameter values
get_param() {
    local key="$1"
    for param in "${parameters[@]}"; do
        if [[ "$param" == "$key="* ]]; then
            echo "${param#*=}"
            return
        fi
    done
}
# Extract values from parameters
WEB_PORT=$(get_param "WEB_PORT")
NODE_PORT=$(get_param "NODE_PORT")
DBUSER=$(get_param "DBUSER")
DBPASS=$(get_param "DBPASS")
BUFFER_TABLE=$(get_param "BUFFER_TABLE")
HOURLY_TABLE=$(get_param "HOURLY_TABLE")



# Function to create database, user, and tables
mariadb_setup_database() {
    echo -e "${YELLOW}Setting up the database, user, and tables...${RESET}"

    # Run SQL commands
    sudo mariadb -u root <<EOF
CREATE DATABASE IF NOT EXISTS thermometer_project;

CREATE USER IF NOT EXISTS '$DBUSER'@'localhost' IDENTIFIED BY '$DBPASS';

GRANT ALL PRIVILEGES ON thermometer_project.* TO '$DBUSER'@'localhost';

USE thermometer_project;

CREATE TABLE IF NOT EXISTS $BUFFER_TABLE (
    id INT AUTO_INCREMENT PRIMARY KEY,
    temperature FLOAT NOT NULL,
    humidity FLOAT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS $HOURLY_TABLE (
    id INT AUTO_INCREMENT PRIMARY KEY,
    avg_temperature FLOAT NOT NULL,
    avg_humidity FLOAT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

FLUSH PRIVILEGES;
EOF

    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Database, user, and tables created successfully.${RESET}"
    else
        echo -e "${RED}Failed to create database, user, or tables.${RESET}"
        exit 1
    fi
}




# Main function to run the setup
mariadb_main() {
    echo -e "${CYAN}Starting MariaDB automated setup...${RESET}"
    setup_mariadb_service
    secure_mariadb
    setup_test_database
    mariadb_setup_database
    echo -e "${CYAN}MariaDB setup completed successfully.${RESET}"
}



allow_port_80() {
    echo -e "${CYAN}Allowing port 80/tcp through the firewall...${RESET}"

    # Run the ufw command to allow port 80
    sudo ufw allow 80/tcp

    # Check if the command was successful
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Port 80/tcp successfully allowed through the firewall.${RESET}"
    else
        echo -e "${RED}Failed to allow port 80/tcp. Please check your firewall settings.${RESET}"
        return 1
    fi

    # Reload the firewall to apply the changes
    sudo ufw reload

    # Confirm the changes
    echo -e "${CYAN}Current ufw status:${RESET}"
    sudo ufw status
}


# Function to export WEB_PORT and NODE_PORT as environment variables
export_ports() {
    # Extract WEB_PORT and NODE_PORT from parameters
    WEB_PORT=$(get_param "WEB_PORT")
    NODE_PORT=$(get_param "NODE_PORT")

    # Check if WEB_PORT and NODE_PORT are set
    if [[ -z "$WEB_PORT" ]]; then
        echo -e "${RED}WEB_PORT is not set in the parameters. Exiting.${RESET}"
        return 1
    fi

    if [[ -z "$NODE_PORT" ]]; then
        echo -e "${RED}NODE_PORT is not set in the parameters. Exiting.${RESET}"
        return 1
    fi

    # Export the variables to the environment
    export WEB_PORT
    export NODE_PORT

    echo -e "${CYAN}WEB_PORT set to $WEB_PORT${RESET}"
    echo -e "${CYAN}NODE_PORT set to $NODE_PORT${RESET}"

    return 0
}


# Function to run the runWeb.js script
run_run_web() {
    # Check if the runWeb.js file exists
    if [[ ! -f "runWeb.js" ]]; then
        echo -e "${RED}runWeb.js not found. Exiting.${RESET}"
        return 1
    fi

    # Export the environment variables to ensure they're passed to the Node.js process
    export WEB_PORT
    export NODE_PORT

    # Run the script with Node.js, using the environment variables
    echo -e "${CYAN}Running runWeb.js with WEB_PORT=$WEB_PORT and NODE_PORT=$NODE_PORT...${RESET}"
    sudo WEB_PORT=$WEB_PORT NODE_PORT=$NODE_PORT node runWeb.js

    # Check if the command was successful
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}runWeb.js ran successfully.${RESET}"
    else
        echo -e "${RED}Failed to run runWeb.js.${RESET}"
        return 1
    fi
}


    ## @NOTE: keep these functions at the bottom of file since they are commonly updated

# Function to display help
print_help() {

    echo -e "\nThis script is used to manage the Thermometer Project."
    echo -e "${CYAN}Usage:${RESET} sudo $0 [options]"
    echo -e "\n${CYAN}Options:${RESET}"
    echo -e "  --install        Install required packages and setup features"
    echo -e "  --conf           Update the configuration file"
    echo -e "  --help           Show this help message"
    echo -e "\n${CYAN}Example:${RESET}"
    echo -e "  sudo ./run.sh --conf  # Update the configuration file"
    echo -e "  sudo ./run.sh        # Run the script without updating the configuration"
}

# Function to handle flags and parameters
handle_flags() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --setup)
                clear
                print_conf_edit_script_text
                interactive_config
                set_env_variables

                # print ascii art
                print_dependency_check
                # install dependencies
                check_dependencies
                install_npm_dependencies
                enable_mysql_extensions
                # enable required services 
                manage_services
                # setup mariadb
                mariadb_main
                # allow_port_80 through firewall
                allow_port_80
                exit
                shift 
                ;;
            --conf)
                clear
                print_conf_edit_script_text
                interactive_config 
                set_env_variables
                exit
                shift
                ;;
            --install)
                clear
                # print ascii art
                print_dependency_check
                # install dependencies
                check_dependencies
                install_npm_dependencies
                exit
                shift
                ;;
            *)
                echo -e "${RED}Unknown option: $1${RESET}"
                print_help
                exit 1
                ;;
        esac
    done
}
  # Function to enable and start services
manage_services() {
    # List of services to manage
    for service in "${services[@]}"; do
        echo -e "${CYAN}Managing service: ${YELLOW}$service${RESET}"

        # Enable the service
        echo -e "${GREEN}Enabling ${YELLOW}$service${GREEN}...${RESET}"
        sudo systemctl enable "$service" > /dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}Failed to enable ${YELLOW}$service${RED}. Skipping...${RESET}"
            continue
        fi

        # Start the service
        echo -e "${GREEN}Starting ${YELLOW}$service${GREEN}...${RESET}"
        sudo systemctl start "$service" > /dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}Failed to start ${YELLOW}$service${RED}.${RESET}"
        else
            echo -e "${GREEN}$service successfully enabled and started.${RESET}"
        fi
    done
}


# Make sure the user is running as root 
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root or using sudo.${RESET}"
    echo -e "${YELLOW}Please re-run as: ${CYAN}sudo $0${RESET}"
    print_help
    exit 1:
fi


    #always run
parse_config

# flag hanldler
handle_flags "$@"

print_server_manager_banner
export_ports
run_run_web
