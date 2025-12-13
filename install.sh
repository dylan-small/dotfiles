#!/usr/bin/env bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
print_info "Dotfiles directory: $DOTFILES_DIR"

if [[ ! -f "$DOTFILES_DIR/.zshenv" ]]; then
    print_error "This script must be run from the dotfiles directory!"
    exit 1
fi

if [[ ! -f /etc/arch-release ]]; then
    print_error "This script is designed for Arch Linux!"
    exit 1
fi

print_info "Starting dotfiles installation..."

# 1. INSTALL BASE PACKAGES

print_info "Installing base packages with pacman..."

PACMAN_PACKAGES=(

    hyprland
    hyprpaper
    hypridle
    hyprlock
    xdg-desktop-portal-hyprland
    waybar
    wofi
    kitty
    dolphin
    swaync
    firefox
    wireplumber
    pipewire
    pipewire-audio
    pipewire-pulse
    brightnessctl
    playerctl
    polkit-gnome
    networkmanager
    bluez
    bluez-utils
    wl-clipboard
    zsh
    git
    curl
    jq
    unzip
    nvidia-utils
    nvidia
    ttf-font-awesome
    ttf-roboto
    ttf-dejavu
    noto-fonts-emoji
    inter-font
)

sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"
print_success "Base packages installed"

# 2. INSTALL AUR HELPER

if ! command -v yay &> /dev/null && ! command -v paru &> /dev/null; then
    print_info "No AUR helper found. Installing yay..."

    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR"
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd "$DOTFILES_DIR"
    rm -rf "$TMP_DIR"

    print_success "yay installed"
else
    print_success "AUR helper already installed"
fi

if command -v yay &> /dev/null; then
    AUR_HELPER="yay"
elif command -v paru &> /dev/null; then
    AUR_HELPER="paru"
fi

print_info "Using AUR helper: $AUR_HELPER"

# 3. INSTALL AUR PACKAGES

print_info "Installing AUR packages..."

AUR_PACKAGES=(
    hyprshot
    bluetuith
    pamix
    eza
    fastfetch
    pokego
    wlogout
    hyprland-split-monitor-workspaces
    ttf-jetbrains-mono-nerd
)

$AUR_HELPER -S --needed --noconfirm "${AUR_PACKAGES[@]}"
print_success "AUR packages installed"

# 4. INSTALL OH-MY-ZSH AND PLUGINS

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    print_info "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "oh-my-zsh installed"
else
    print_success "oh-my-zsh already installed"
fi

# Install zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

print_info "Installing zsh plugins..."

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-256color" ]]; then
    git clone https://github.com/chrissicool/zsh-256color "$ZSH_CUSTOM/plugins/zsh-256color"
fi

print_success "zsh plugins installed"

# Install Powerlevel10k theme
if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
    print_info "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
    print_success "Powerlevel10k theme installed"
else
    print_success "Powerlevel10k theme already installed"
fi

# 5. CREATE SYMLINKS FOR DOTFILES

print_info "Creating symlinks for dotfiles..."

mkdir -p "$HOME/.config"

# Symlink config directories
CONFIG_DIRS=(
    "hypr"
    "waybar"
    "wofi"
    "wlogout"
    "kitty"
)

for dir in "${CONFIG_DIRS[@]}"; do
    if [[ -L "$HOME/.config/$dir" ]]; then
        print_warning "$HOME/.config/$dir is already a symlink, skipping..."
    elif [[ -d "$HOME/.config/$dir" ]]; then
        print_warning "$HOME/.config/$dir exists. Backing up to $HOME/.config/$dir.backup"
        mv "$HOME/.config/$dir" "$HOME/.config/$dir.backup"
        ln -sf "$DOTFILES_DIR/.config/$dir" "$HOME/.config/$dir"
        print_success "Backed up and symlinked $dir"
    else
        ln -sf "$DOTFILES_DIR/.config/$dir" "$HOME/.config/$dir"
        print_success "Symlinked $dir"
    fi
done

# Symlink .zshenv
if [[ -f "$HOME/.zshenv" ]] && [[ ! -L "$HOME/.zshenv" ]]; then
    print_warning "$HOME/.zshenv exists. Backing up to $HOME/.zshenv.backup"
    mv "$HOME/.zshenv" "$HOME/.zshenv.backup"
fi
ln -sf "$DOTFILES_DIR/.zshenv" "$HOME/.zshenv"
print_success "Symlinked .zshenv"

# Symlink .p10k.zsh
if [[ -f "$HOME/.p10k.zsh" ]] && [[ ! -L "$HOME/.p10k.zsh" ]]; then
    print_warning "$HOME/.p10k.zsh exists. Backing up to $HOME/.p10k.zsh.backup"
    mv "$HOME/.p10k.zsh" "$HOME/.p10k.zsh.backup"
fi
ln -sf "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
print_success "Symlinked .p10k.zsh"

# 6. ADDITIONAL SETUP

print_info "Performing additional setup..."

mkdir -p "$HOME/.config/wallpapers"
print_success "Created wallpapers directory"

chmod +x "$DOTFILES_DIR/.config/hypr/scripts/"*.sh
chmod +x "$DOTFILES_DIR/.config/waybar/scripts/"*.sh
print_success "Made scripts executable"

print_info "Enabling system services..."
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
print_success "System services enabled"

if [[ "$SHELL" != "$(which zsh)" ]]; then
    print_info "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
    print_success "Default shell set to zsh (will take effect on next login)"
else
    print_success "zsh is already the default shell"
fi

# 7. CONFIGURE MONITORS

print_info "Detecting monitors and configuring display settings..."

if ! command -v hyprctl &> /dev/null; then
    print_warning "hyprctl not found. Skipping monitor auto-configuration."
    print_warning "You'll need to manually configure monitors in hyprland.conf"
else
    MONITOR_DATA=$(hyprctl monitors -j)

    if [[ -z "$MONITOR_DATA" ]] || [[ "$MONITOR_DATA" == "[]" ]]; then
        print_warning "No monitors detected. Skipping monitor auto-configuration."
    else
        MONITOR_CONFIGS=""
        CUMULATIVE_OFFSET=0
        MONITOR_COUNT=$(echo "$MONITOR_DATA" | jq 'length')

        print_info "Found $MONITOR_COUNT monitor(s)"

        for ((i=0; i<MONITOR_COUNT; i++)); do
            # Extract monitor information
            MONITOR_NAME=$(echo "$MONITOR_DATA" | jq -r ".[$i].name")

            CURRENT_WIDTH=$(echo "$MONITOR_DATA" | jq -r ".[$i].width")
            CURRENT_HEIGHT=$(echo "$MONITOR_DATA" | jq -r ".[$i].height")
            CURRENT_REFRESH=$(echo "$MONITOR_DATA" | jq -r ".[$i].refreshRate")

            REFRESH_RATE=$(printf "%.0f" "$CURRENT_REFRESH")

            RESOLUTION="${CURRENT_WIDTH}x${CURRENT_HEIGHT}@${REFRESH_RATE}"
            POSITION="${CUMULATIVE_OFFSET}x0"

            MONITOR_CONFIG="monitor=$MONITOR_NAME, $RESOLUTION, $POSITION, 1"

            if [[ -n "$MONITOR_CONFIGS" ]]; then
                MONITOR_CONFIGS="${MONITOR_CONFIGS}\n${MONITOR_CONFIG}"
            else
                MONITOR_CONFIGS="${MONITOR_CONFIG}"
            fi

            print_info "Configured monitor $((i+1)): $MONITOR_NAME at $RESOLUTION, offset $POSITION"

            CUMULATIVE_OFFSET=$((CUMULATIVE_OFFSET + CURRENT_WIDTH))
        done

        HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"

        if [[ -f "$HYPRLAND_CONF" ]]; then
            # Create a backup
            cp "$HYPRLAND_CONF" "${HYPRLAND_CONF}.backup"
            print_info "Backed up hyprland.conf to ${HYPRLAND_CONF}.backup"

            TEMP_FILE=$(mktemp)

            IN_MONITOR_SECTION=0
            while IFS= read -r line; do

                if [[ "$line" == "### MONITORS ###" ]]; then
                    IN_MONITOR_SECTION=1
                    echo "$line" >> "$TEMP_FILE"
                    continue
                fi

                if [[ $IN_MONITOR_SECTION -eq 1 ]] && [[ "$line" == "################" ]]; then
                    echo "$line" >> "$TEMP_FILE"
                    echo "" >> "$TEMP_FILE"
                    echo "# See https://wiki.hyprland.org/Configuring/Monitors/" >> "$TEMP_FILE"
                    echo -e "$MONITOR_CONFIGS" >> "$TEMP_FILE"
                    IN_MONITOR_SECTION=2
                    continue
                fi

                if [[ "$line" =~ ^monitor= ]]; then
                    continue
                fi

                if [[ "$line" == "# See https://wiki.hyprland.org/Configuring/Monitors/" ]]; then
                    continue
                fi

                echo "$line" >> "$TEMP_FILE"
            done < "$HYPRLAND_CONF"

            mv "$TEMP_FILE" "$HYPRLAND_CONF"

            print_success "Monitor configuration updated in hyprland.conf"
        else
            print_warning "hyprland.conf not found at $HYPRLAND_CONF"
        fi

        # Replace monitor names in all hypr config files
        # Build an array of detected monitor names in order (left to right)
        DETECTED_MONITORS=()
        for ((i=0; i<MONITOR_COUNT; i++)); do
            MONITOR_NAME=$(echo "$MONITOR_DATA" | jq -r ".[$i].name")
            DETECTED_MONITORS+=("$MONITOR_NAME")
        done

        # Define the current/template monitor names (in order: left to right)
        TEMPLATE_MONITORS=("DP-2" "DP-3")

        # Only proceed with replacement if we have monitors to map
        if [[ ${#DETECTED_MONITORS[@]} -gt 0 ]]; then
            print_info "Replacing template monitor names with detected monitors..."

            # Files to update with monitor name replacements
            CONFIG_FILES=(
                "$HOME/.config/hypr/hyprland.conf"
                "$HOME/.config/hypr/hypridle.conf"
                "$HOME/.config/hypr/hyprpaper.conf"
                "$HOME/.config/hypr/hyprlock.conf"
            )

            for config_file in "${CONFIG_FILES[@]}"; do
                if [[ -f "$config_file" ]]; then
                    # Create backup if not already done
                    if [[ ! -f "${config_file}.backup" ]]; then
                        cp "$config_file" "${config_file}.backup"
                    fi

                    # Replace each template monitor with the corresponding detected monitor
                    for ((i=0; i<${#TEMPLATE_MONITORS[@]}; i++)); do
                        if [[ $i -lt ${#DETECTED_MONITORS[@]} ]]; then
                            TEMPLATE="${TEMPLATE_MONITORS[$i]}"
                            DETECTED="${DETECTED_MONITORS[$i]}"

                            if [[ "$TEMPLATE" != "$DETECTED" ]]; then
                                sed -i "s/${TEMPLATE}/${DETECTED}/g" "$config_file"
                                print_info "Replaced $TEMPLATE with $DETECTED in $(basename "$config_file")"
                            fi
                        fi
                    done
                fi
            done

            print_success "Monitor name replacements complete"
        fi
    fi
fi

# FINAL NOTES

echo ""
print_success "Installation complete!"
echo ""
print_info "Next steps:"
echo "  1. Add wallpapers to ~/.config/wallpapers/"
echo "     - Or update .config/hypr/hyprpaper.conf with your wallpaper paths"
echo "  2. Reboot to start using Hyprland"
echo "  3. Update your monitor configuration in .config/hypr/hyprland.conf if needed"
echo "  4. Customize theme colors in .config/hypr/themes/colors.conf"
echo ""
print_warning "Some Hyprland plugins may need to be installed with 'hyprpm update'"
echo ""
