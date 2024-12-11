#!/bin/zsh

# Define color codes
GREEN="\033[01;32m"
BLUE="\033[01;34m"
YELLOW="\033[01;33m"
RED="\033[01;31m"
MAGENTA="\033[01;35m"
CYAN="\033[01;36m"
RESET="\033[00m"

# Enable alias expansion
setopt aliases

# Function to get user confirmation
confirm_action() {
    read -q "confirmation?Are you sure? (y/n): "
    echo
    [[ "$confirmation" == [Yy]* ]]
}

# Function to deploy API
deploy_api() {
    echo -e "${MAGENTA}Deploying API to server...${RESET}"
    if confirm_action; then
        /Users/vikash/projects/deploy/local/ddev.sh
        echo -e "${GREEN}Deployment successful!${RESET}"
    else
        echo -e "${RED}Deployment canceled.${RESET}"
    fi
}

# Function to deploy API (stage)
deploy_api_stage() {
    echo -e "${MAGENTA}Deploying API to [STAGE] server...${RESET}"
    if confirm_action; then
        /Users/vikash/projects/deploy/local/dstage.sh
        echo -e "${GREEN}Deployment successful!${RESET}"
    else
        echo -e "${RED}Deployment canceled.${RESET}"
    fi
}

# Function to build APK
build_apk() {
    echo -e "${MAGENTA}Building APK...${RESET}"
    cd /Users/vikash/projects/app && ./gradlew assembleDebug --parallel
}

# Function to build APK offline
build_apk_offline() {
    echo -e "${MAGENTA}Building APK (offline)...${RESET}"
    cd /Users/vikash/projects/app && ./gradlew assembleDebug --offline --parallel
}

# Function to install APK
install_apk() {
    echo -e "${MAGENTA}Installing APK...${RESET}"
    devices=$(adb devices | awk 'NR>1 && NF {print $1}')
    echo -e "${CYAN}Available devices:${RESET}"
    select device in ${(f)devices}; do
        if [[ -n $device ]]; then
            # Trim leading and trailing whitespace from the selected device
            device=$(echo "$device" | xargs)
            echo -e "${GREEN}Selected device: $device${RESET}"
            break
        else
            echo -e "${RED}Invalid selection. Please try again.${RESET}"
        fi
    done

    # Make sure to use the trimmed device ID
    cd /Users/vikash/projects/app/android/android-app/build/outputs/apk/apbooks/debug && adb -s "$device" install android-app-apbooks-debug.apk
}

# Function to run Android Emulator
run_emulator() {
    echo -e "${MAGENTA}Running Android Emulator...${RESET}"
    cd /Users/vikash/projects/app && D:/Applications/Development/ANDROID/SDK/emulator/emulator.exe -avd pxl8 &
}

# Function to open APPS directory
open_apps_directory() {
    echo -e "${MAGENTA}Opening APPS directory...${RESET}"
    cd /Users/vikash/projects/api-app && open .
}

# Function to run API
run_api() {
    echo -e "${MAGENTA}Running API...${RESET}"
    cd /Users/vikash/projects/api-app && go run ./main
}

# Function to run tests
run_tests() {
    echo -e "${MAGENTA}Running Tests...${RESET}"
    cd /Users/vikash/projects/api-app && time richgo test -failfast -parallel 4 -cpu 4 -skip 'TestTagsNestedSetTree|TestTagsNestedSetTreeValidate|TestStop|TestStopThreadRoomBroker|TestMessageSendAndReceive|TestDisconnect' ./...
}

# Function to run tests with coverage
run_tests_with_coverage() {
    echo -e "${MAGENTA}Running Tests with coverage...${RESET}"
    filename="/Users/vikash/projects/test-coverage-api-app/coverage-$(date +%Y%m%d-%H%M%S).out"
    cd /Users/vikash/projects/api-app && time richgo test -parallel 8 -failfast -coverprofile $filename ./...
    echo -e "Test Coverage package built and stored at: ${GREEN}${filename}${RESET}"
}

# Function to run static analysis
run_static_analysis() {
    echo -e "${MAGENTA}Running static analysis on code..${RESET}"
    cd /Users/vikash/projects/api-app && time staticcheck ./...
}

# Function to run GolangCI-Lint
run_golangci_lint() {
    echo -e "${MAGENTA}Running linters on code..${RESET}"
    cd /Users/vikash/projects/api-app && time golangci-lint run -v
}

# Function to run GolangCI-Lint
run_goconvey_test_ui() {
    echo -e "${MAGENTA}Running goconvey on code..${RESET}"
    cd /Users/vikash/projects/api-app && goconvey 
}


# Function to find empty files or files with only Go package definitions
find_empty_or_package_files() {
    local dir="."
    find "$dir" -type d -name .git -prune -o -type f -print0 | while IFS= read -r -d '' file; do
        if [[ ! -s "$file" || $(grep -Ev '^\s*(package\s+\w+)?\s*$' "$file") == "" ]]; then
            echo "$file"
        fi
    done
}

# Main function to display menu and handle user input
paf() {
    # Check for command line arguments (e.g., paf 7)
    if [ $# -eq 1 ] && [[ $1 =~ ^[0-9]$ ]] && (( $1 >= 0 && $1 <= 13 )); then
        choice=$1
        echo -e "${CYAN}Automatically selected option $choice.${RESET}"
    else
        echo -e "${CYAN}Select an option by entering the corresponding number:${RESET}"
        echo -e "0)  ${GREEN}Deploy API${RESET}"
        echo -e "1)  ${YELLOW}Build APK${RESET}"
        echo -e "2)  ${YELLOW}Build APK Offline${RESET}"
        echo -e "3)  ${YELLOW}Install APK${RESET}"
        echo -e "4)  ${YELLOW}Run Android Emulator${RESET}"
        echo -e "5)  ${RESET}Open APPS directory${RESET}"
        echo -e "6)  ${GREEN}Run API${RESET}"
        echo -e "7)  ${CYAN}Run Tests${RESET}"
        echo -e "8)  ${RED}Run Tests with Coverage${RESET}"
        echo -e "9)  ${GREEN}Deploy (on Stage)${RESET}"
        echo -e "10) ${RESET}Run Static Analysis on Code (Very Expensive)${RESET}"
        echo -e "11) ${RESET}Go-lint (Very Expensive)${RESET}"
        echo -e "12) ${RESET}Find empty go files${RESET}"
        echo -e "13) ${RESET}Start Goconvey (test UI)${RESET}"
        
        while true; do
            echo -ne "${YELLOW}Enter your choice (0-13 or q to quit): ${RESET}"
            read -n choice  # Read a single character

            if [[ $choice == "q" ]]; then
                echo -e "\n${CYAN}Goodbye! Exiting.${RESET}"
                return
            elif [[ $choice =~ ^[0-9]$ ]] || [[ $choice == "1" ]]; then
                echo  # Print a newline after the choice
                break
            else
                echo -e "\n${RED}Invalid input. Try again.${RESET}"
            fi
        done
    fi

    case $choice in
        0) deploy_api ;;
        1) build_apk ;;
        2) build_apk_offline ;;
        3) install_apk ;;
        4) run_emulator ;;
        5) open_apps_directory ;;
        6) run_api ;;
        7) run_tests ;;
        8) run_tests_with_coverage ;;
        9) deploy_api_stage ;;
        10) run_static_analysis ;;
        11) run_golangci_lint ;;
        12) find_empty_or_package_files ;;
        13) run_goconvey_test_ui ;;
        *) echo -e "${RED}Invalid option. Exiting.${RESET}" ;;
    esac
}

# Run the main menu function
paf "$@"

# usage: 
# Below command runs 7th number script.
# paf 7 

# below command executes the whole script.
# paf
