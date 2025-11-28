#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if running from dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
print_info "Dotfiles directory: $DOTFILES_DIR"

if [[ ! -f "$DOTFILES_DIR/.zshenv" ]]; then
    print_error "This script must be run from the dotfiles directory!"
    exit 1
fi

# Check if running Arch Linux
if [[ ! -f /etc/arch-release ]]; then
    print_error "This script is designed for Arch Linux!"
    exit 1
fi

print_info "Starting dotfiles installation..."

# ============================================================================
# 1. INSTALL BASE PACKAGES
# ============================================================================

print_info "Installing base packages with pacman..."

PACMAN_PACKAGES=(
    # Hyprland ecosystem
    hyprland
    hyprpaper
    hypridle
    hyprlock
    xdg-desktop-portal-hyprland

    # Desktop UI
    waybar
    wofi
    wlogout

    # Applications
    kitty
    dolphin
    firefox

    # System utilities
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

    # Shell & terminal tools
    zsh
    git
    curl
    jq

    # NVIDIA
    nvidia-utils

    # Fonts
    ttf-font-awesome
    noto-fonts-emoji
    ttf-dejavu
)

sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"
print_success "Base packages installed"

# ============================================================================
# 2. INSTALL AUR HELPER (if not already installed)
# ============================================================================

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

# Detect which AUR helper to use
if command -v yay &> /dev/null; then
    AUR_HELPER="yay"
elif command -v paru &> /dev/null; then
    AUR_HELPER="paru"
fi

print_info "Using AUR helper: $AUR_HELPER"

# ============================================================================
# 3. INSTALL AUR PACKAGES
# ============================================================================

print_info "Installing AUR packages..."

AUR_PACKAGES=(
    hyprshot
    bluetuith
    pamix
    eza
    fastfetch
    pokego
    hyprland-split-monitor-workspaces
)

$AUR_HELPER -S --needed --noconfirm "${AUR_PACKAGES[@]}"
print_success "AUR packages installed"

# ============================================================================
# 4. INSTALL OH-MY-ZSH AND PLUGINS
# ============================================================================

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

# ============================================================================
# 5. CREATE SYMLINKS FOR DOTFILES
# ============================================================================

print_info "Creating symlinks for dotfiles..."

mkdir -p "$HOME/.config"

# Symlink config directories
CONFIG_DIRS=(
    "hypr"
    "waybar"
    "wofi"
    "wlogout"
    "kitty"
    "spotify-player"
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

# ============================================================================
# 6. ADDITIONAL SETUP
# ============================================================================

print_info "Performing additional setup..."

# Create wallpapers directory
mkdir -p "$HOME/Documents/Wallpapers"
print_success "Created wallpapers directory"

# Make scripts executable
chmod +x "$DOTFILES_DIR/.config/hypr/scripts/"*.sh
chmod +x "$DOTFILES_DIR/.config/waybar/scripts/"*.sh
print_success "Made scripts executable"

# Enable NetworkManager and Bluetooth services
print_info "Enabling system services..."
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
print_success "System services enabled"

# Set zsh as default shell
if [[ "$SHELL" != "$(which zsh)" ]]; then
    print_info "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
    print_success "Default shell set to zsh (will take effect on next login)"
else
    print_success "zsh is already the default shell"
fi

# ============================================================================
# FINAL NOTES
# ============================================================================

echo ""
print_success "Installation complete!"
echo ""
print_info "Next steps:"
echo "  1. Add wallpapers to ~/Documents/Wallpapers/"
echo "     - Expected: earth.jpg and uMrsMXh.jpeg"
echo "     - Or update .config/hypr/hyprpaper.conf with your wallpaper paths"
echo "  2. Log out and log back in (or reboot) to start using Hyprland"
echo "  3. Update your monitor configuration in .config/hypr/hyprland.conf if needed"
echo "  4. Customize theme colors in .config/hypr/themes/colors.conf"
echo ""
print_warning "Some Hyprland plugins may need to be installed with 'hyprpm update'"
echo ""
