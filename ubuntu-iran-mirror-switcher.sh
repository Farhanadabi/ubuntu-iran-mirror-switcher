#!/bin/bash

# Ubuntu Iranian Mirror Changer Script
# Based on Persian instructions for changing Ubuntu mirrors to Iranian ones

echo "🔸 Ubuntu Mirror Changer - Replacing default Ubuntu mirrors with Iranian mirrors"
echo "⚠️  If you have package download issues, changing download servers can be a solution."
echo

# Iranian mirror list
MIRRORS=(
    "https://mirror.iranserver.com/ubuntu/"
    "https://mirrors.pardisco.co/ubuntu/"
    "http://mirror.aminidc.com/ubuntu/"
    "http://mirror.faraso.org/ubuntu/"
    "https://ir.ubuntu.sindad.cloud/ubuntu/"
    "https://ubuntu-mirror.kimiahost.com/"
    "https://archive.ubuntu.petiak.ir/ubuntu/"
    "https://ubuntu.hostiran.ir/ubuntuarchive/"
    "https://ubuntu.bardia.tech/"
    "https://mirror.iranserver.com/ubuntu/"
    "https://ir.archive.ubuntu.com/ubuntu/"
    "https://mirror.0-1.cloud/ubuntu/"
    "http://linuxmirrors.ir/pub/ubuntu/"
    "http://repo.iut.ac.ir/repo/Ubuntu/"
    "https://ubuntu.shatel.ir/ubuntu/"
    "http://ubuntu.byteiran.com/ubuntu/"
    "https://mirror.rasanegar.com/ubuntu/"
)

# Default mirror
DEFAULT_MIRROR="http://archive.ubuntu.com/ubuntu/"

# Global variables
selected_mirror=""
SUDO_CMD=""

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        echo "⚠️  Running as root user detected."
        SUDO_CMD=""
    else
        SUDO_CMD="sudo"
    fi
}

# Function to backup current sources.list
backup_sources() {
    echo "🔹 Backing up current sources.list..."
    if [ -f "/etc/apt/sources.list" ]; then
        $SUDO_CMD mv /etc/apt/sources.list /etc/apt/sources.list.bak
        echo "✅ Backup created at /etc/apt/sources.list.bak"
        return 0
    else
        echo "❌ /etc/apt/sources.list not found!"
        return 1
    fi
}

# Function to create new sources.list with selected mirror
create_sources_list() {
    local mirror_url="$1"
    echo "🔹 Creating new sources.list with mirror: $mirror_url"
    
    # Remove trailing slash if present
    mirror_url="${mirror_url%/}"
    
    # Get Ubuntu codename
    codename=$(lsb_release -sc)
    
    # Create new sources.list
    $SUDO_CMD sh -c "printf 'deb ${mirror_url}/ %s main restricted universe multiverse\n' '$codename' > /etc/apt/sources.list"
    $SUDO_CMD sh -c "printf 'deb ${mirror_url}/ %s-updates main restricted universe multiverse\n' '$codename' >> /etc/apt/sources.list"
    $SUDO_CMD sh -c "printf 'deb ${mirror_url}/ %s-backports main restricted universe multiverse\n' '$codename' >> /etc/apt/sources.list"
    $SUDO_CMD sh -c "printf 'deb ${mirror_url}/ %s-security main restricted universe multiverse\n' '$codename' >> /etc/apt/sources.list"
    
    echo "✅ New sources.list created successfully"
    return 0
}

# Function to update package list
update_packages() {
    echo "🔹 Updating package list..."
    if $SUDO_CMD apt update; then
        echo "✅ Package list updated successfully"
        return 0
    else
        echo "❌ Failed to update package list"
        return 1
    fi
}

# Function to restore backup
restore_backup() {
    echo "🔹 Restoring backup..."
    if [ -f "/etc/apt/sources.list.bak" ]; then
        $SUDO_CMD mv /etc/apt/sources.list.bak /etc/apt/sources.list
        echo "✅ Backup restored successfully"
        return 0
    else
        echo "❌ No backup found!"
        return 1
    fi
}

# Function to show mirror selection menu
show_mirror_menu() {
    echo "🔹 Available Iranian mirrors:"
    echo "0) Use default mirror (${DEFAULT_MIRROR})"
    for i in "${!MIRRORS[@]}"; do
        echo "$((i+1))) ${MIRRORS[$i]}"
    done
    echo "$((${#MIRRORS[@]}+1))) Enter custom mirror URL"
    echo "$((${#MIRRORS[@]}+2))) 🎯 Smart Pick (Auto-select best working mirror)"
    echo
}

# Function to test mirror connectivity
test_mirror() {
    local mirror_url="$1"
    local quiet="${2:-false}"
    
    case "$quiet" in
        "true")
            ;;
        *)
            echo "Testing connectivity to: $mirror_url"
            ;;
    esac
    
    if curl -s --connect-timeout 10 "${mirror_url}" > /dev/null 2>&1; then
        case "$quiet" in
            "true")
                ;;
            *)
                echo "✅ Mirror is accessible"
                ;;
        esac
        return 0
    else
        case "$quiet" in
            "true")
                ;;
            *)
                echo "❌ Mirror is not accessible"
                ;;
        esac
        return 1
    fi
}

# Function to smart pick the best working mirror
smart_pick_mirror() {
    echo "🔍 Smart Pick: Testing all mirrors to find the best working one..."
    echo "This may take a moment..."
    echo
    
    local working_mirrors=()
    local total_mirrors=$((${#MIRRORS[@]} + 1))
    local current=0
    
    # Test default mirror first
    current=$((current + 1))
    echo "[$current/$total_mirrors] Testing default mirror: $DEFAULT_MIRROR"
    if test_mirror "$DEFAULT_MIRROR" "true"; then
        working_mirrors+=("$DEFAULT_MIRROR")
        echo "✅ Default mirror is working"
    else
        echo "❌ Default mirror failed"
    fi
    echo
    
    # Test all other mirrors
    for mirror in "${MIRRORS[@]}"; do
        current=$((current + 1))
        echo "[$current/$total_mirrors] Testing: $mirror"
        if test_mirror "$mirror" "true"; then
            working_mirrors+=("$mirror")
            echo "✅ Mirror is working"
        else
            echo "❌ Mirror failed"
        fi
        echo
    done
    
    # Show results
    if [ ${#working_mirrors[@]} -eq 0 ]; then
        echo "😞 No working mirrors found!"
        echo "You may want to check your internet connection or try again later."
        return 1
    else
        echo "🎉 Found ${#working_mirrors[@]} working mirror(s):"
        for i in "${!working_mirrors[@]}"; do
            echo "$((i+1)). ${working_mirrors[$i]}"
        done
        echo
        
        # Use the first working mirror
        selected_mirror="${working_mirrors[0]}"
        echo "🎯 Selected: $selected_mirror"
        return 0
    fi
}

# Function to handle mirror selection
select_mirror() {
    show_mirror_menu
    
    # Get user selection
    read -p "Select mirror (0-$((${#MIRRORS[@]}+2))): " selection
    
    case "$selection" in
        "0")
            selected_mirror="$DEFAULT_MIRROR"
            ;;
        "$((${#MIRRORS[@]}+1))")
            read -p "Enter custom mirror URL: " selected_mirror
            ;;
        "$((${#MIRRORS[@]}+2))")
            # Smart Pick option
            if smart_pick_mirror; then
                echo "✅ Smart Pick completed successfully"
                return 0
            else
                echo "❌ Smart Pick failed to find any working mirrors"
                return 1
            fi
            ;;
        *)
            # Check if selection is a valid mirror index
            if [[ "$selection" -ge 1 && "$selection" -le "${#MIRRORS[@]}" ]]; then
                selected_mirror="${MIRRORS[$((selection-1))]}"
            else
                echo "❌ Invalid selection!"
                return 1
            fi
            ;;
    esac
    
    return 0
}

# Function to handle mirror testing and retry options
handle_mirror_test() {
    echo "Selected mirror: $selected_mirror"
    
    # Test mirror connectivity
    if test_mirror "$selected_mirror"; then
        return 0
    fi
    
    # Mirror failed, show options
    while true; do
        echo "⚠️  Mirror seems to be inaccessible. What would you like to do?"
        echo "1) Continue anyway"
        echo "2) Try another mirror"
        echo "3) Exit and restore backup"
        echo
        read -p "Select option (1-3): " mirror_choice
        
        case "$mirror_choice" in
            "1")
                echo "Continuing with inaccessible mirror..."
                return 0
                ;;
            "2")
                echo
                if select_mirror; then
                    if handle_mirror_test; then
                        return 0
                    fi
                else
                    echo "❌ Mirror selection failed! Returning to options..."
                fi
                ;;
            "3")
                echo "Exiting and restoring backup..."
                restore_backup
                exit 0
                ;;
            *)
                echo "❌ Invalid option! Please select 1, 2, or 3."
                ;;
        esac
    done
}

# Main script execution
main() {
    echo "Starting Ubuntu Mirror Changer..."
    echo
    
    # Check if running as root
    check_root
    
    # Check if lsb_release is available
    if ! command -v lsb_release &> /dev/null; then
        echo "❌ lsb_release command not found. Please install lsb-release package."
        exit 1
    fi
    
    # Backup current sources.list
    if ! backup_sources; then
        exit 1
    fi
    
    # Select mirror
    if ! select_mirror; then
        restore_backup
        exit 1
    fi
    
    # Handle mirror testing (only for non-Smart Pick selections)
    if ! handle_mirror_test; then
        restore_backup
        exit 1
    fi
    
    # Create new sources.list with selected mirror
    if ! create_sources_list "$selected_mirror"; then
        echo "❌ Failed to create new sources.list"
        restore_backup
        exit 1
    fi
    
    # Update package list
    if ! update_packages; then
        echo "❌ Failed to update with selected mirror. Restoring backup..."
        restore_backup
        update_packages
        echo "⚠️  Mirror change failed. You may want to try a different mirror."
        exit 1
    fi
    
    echo
    echo "🎉 Mirror successfully changed to: $selected_mirror"
    echo "✅ Package list updated successfully"
    echo
    echo "To restore original settings, run:"
    echo "sudo mv /etc/apt/sources.list.bak /etc/apt/sources.list && sudo apt update"
}

# Run main function
main "$@"