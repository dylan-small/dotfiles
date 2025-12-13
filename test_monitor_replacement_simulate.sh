#!/usr/bin/env bash

# Test script to simulate monitor replacement with FAKE monitors
# This shows what would happen if you had HDMI-1 and DP-1 instead

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Create temp directory for output
TEMP_DIR=$(mktemp -d)
echo "Created temp directory: $TEMP_DIR"
echo ""

print_info "SIMULATING monitors: HDMI-1 and DP-1 (not your real setup)"

# SIMULATE detected monitors
DETECTED_MONITORS=("HDMI-1" "DP-1")

echo ""
echo "=== SIMULATED MONITOR MAPPING ==="
TEMPLATE_MONITORS=("DP-2" "DP-3")

for ((i=0; i<${#TEMPLATE_MONITORS[@]}; i++)); do
    if [[ $i -lt ${#DETECTED_MONITORS[@]} ]]; then
        TEMPLATE="${TEMPLATE_MONITORS[$i]}"
        DETECTED="${DETECTED_MONITORS[$i]}"
        if [[ "$TEMPLATE" != "$DETECTED" ]]; then
            echo "  $TEMPLATE -> $DETECTED (WILL REPLACE)"
        else
            echo "  $TEMPLATE -> $DETECTED (NO CHANGE)"
        fi
    fi
done

echo ""
echo "=== SIMULATING REPLACEMENTS ==="

# Files to process
CONFIG_FILES=(
    "$HOME/.config/hypr/hyprland.conf"
    "$HOME/.config/hypr/hypridle.conf"
    "$HOME/.config/hypr/hyprpaper.conf"
    "$HOME/.config/hypr/hyprlock.conf"
)

for config_file in "${CONFIG_FILES[@]}"; do
    if [[ -f "$config_file" ]]; then
        basename_file=$(basename "$config_file")
        print_info "Processing $basename_file..."

        # Copy original to temp directory
        cp "$config_file" "$TEMP_DIR/${basename_file}.original"
        cp "$config_file" "$TEMP_DIR/${basename_file}.modified"

        # Perform replacements on the modified copy
        for ((i=0; i<${#TEMPLATE_MONITORS[@]}; i++)); do
            if [[ $i -lt ${#DETECTED_MONITORS[@]} ]]; then
                TEMPLATE="${TEMPLATE_MONITORS[$i]}"
                DETECTED="${DETECTED_MONITORS[$i]}"

                if [[ "$TEMPLATE" != "$DETECTED" ]]; then
                    # Count occurrences before replacement
                    COUNT=$(grep -o "$TEMPLATE" "$TEMP_DIR/${basename_file}.modified" 2>/dev/null | wc -l)

                    if [[ $COUNT -gt 0 ]]; then
                        sed -i "s/${TEMPLATE}/${DETECTED}/g" "$TEMP_DIR/${basename_file}.modified"
                        echo "    ✓ Replaced $COUNT instance(s) of $TEMPLATE with $DETECTED"
                    fi
                fi
            fi
        done
    fi
done

echo ""
print_success "Simulation complete! Results saved to: $TEMP_DIR"

echo ""
echo "=== SIDE-BY-SIDE COMPARISON ==="
for file in "$TEMP_DIR"/*.modified; do
    if [[ -f "$file" ]]; then
        basename_file=$(basename "$file" .modified)
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "FILE: $basename_file"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        echo ""
        echo "BEFORE (lines with monitor references):"
        grep -n "DP-[0-9]\|HDMI-[0-9]" "$TEMP_DIR/${basename_file}.original" 2>/dev/null | head -10 || echo "  (none)"

        echo ""
        echo "AFTER (lines with monitor references):"
        grep -n "DP-[0-9]\|HDMI-[0-9]" "$TEMP_DIR/${basename_file}.modified" 2>/dev/null | head -10 || echo "  (none)"
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "DETAILED DIFF OUTPUT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for file in "$TEMP_DIR"/*.modified; do
    if [[ -f "$file" ]]; then
        basename_file=$(basename "$file" .modified)
        echo ""
        echo "=== $basename_file ==="
        diff -u --color=always "$TEMP_DIR/${basename_file}.original" "$TEMP_DIR/${basename_file}.modified" || true
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_success "Temp files location: $TEMP_DIR"
echo "You can review the modified files in the temp directory."
echo "Files will be kept for your review. Delete manually when done:"
echo "  rm -rf $TEMP_DIR"
echo ""
