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

# Define the parameters and their default values
parameters=(
    "DBUSER:db_user"
    "DBPASS:"
    "SERVICE_NAME:Thermometer_proj_server"
    "WEB_PORT:80"
    "NODE_PORT:5000"
    "BUFFER_TABLE:buffer_table"
    "HOURLY_TABLE:hourly_table"
)

# Declare an associative array to store the configuration
declare -A config

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



# Function to parse the configuration file
# Saves the config values to the config variables
parse_config() {
    while IFS='=' read -r key value; do
        # Skip lines that are comments or empty
        [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue

        # Remove whitespace from key and value
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)

        # Assign the value to the respective variable
        case "$key" in
            DBUSER) DBUSER="$value" ;;
            DBPASS) DBPASS="$value" ;;
            SERVICE_NAME) SERVICE_NAME="$value" ;;
            WEB_PORT) WEB_PORT="$value" ;;
            NODE_PORT) NODE_PORT="$value" ;;
            BUFFER_TABLE) BUFFER_TABLE="$value" ;;
            HOURLY_TABLE) HOURLY_TABLE="$value" ;;
        esac
    done < "$CONFIG_FILE"
}


# Function to parse the configuration file
parse_config() {
    # Load defaults first
    for param in "${parameters[@]}"; do
        key="${param%%:*}"
        default="${param##*:}"
        config["$key"]="$default"
    done

    # Overwrite with values from the configuration file if they exist
    if [[ -f "$CONFIG_FILE" ]]; then
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue

            # Remove whitespace
            key=$(echo "$key" | xargs)
            value=$(echo "$value" | xargs)

            # Update the config with the file's value
            config["$key"]="$value"
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
            key="${param%%:*}"
            echo "$key=${config[$key]}"
        done
    } > "$CONFIG_FILE"
}

# Function to print the configuration
print_config() {
    echo "Configuration:"
    for param in "${parameters[@]}"; do
        key="${param%%:*}"
        echo "$key=${config[$key]}"
    done
}





    ## Please keep these functions at the bottom of file since they are commonly updated

# Function to display help
print_help() {
    echo -e "\nThis script is used to manage the Thermometer Project."
    echo -e "${CYAN}Usage:${RESET} $0 [options]"
    echo -e "\n${CYAN}Options:${RESET}"
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


parse_config
update_config
clear
parse_config
print_config
