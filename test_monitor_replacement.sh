#!/usr/bin/env bash

# Test script to simulate monitor replacement
# This creates temporary copies and shows what would change

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

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Create temp directory for output
TEMP_DIR=$(mktemp -d)
echo "Created temp directory: $TEMP_DIR"
echo ""

# Get monitor data
MONITOR_DATA=$(hyprctl monitors -j)

if [[ -z "$MONITOR_DATA" ]] || [[ "$MONITOR_DATA" == "[]" ]]; then
    print_warning "No monitors detected"
    exit 1
fi

MONITOR_COUNT=$(echo "$MONITOR_DATA" | jq 'length')
print_info "Found $MONITOR_COUNT monitor(s)"

# Build array of detected monitors
DETECTED_MONITORS=()
for ((i=0; i<MONITOR_COUNT; i++)); do
    MONITOR_NAME=$(echo "$MONITOR_DATA" | jq -r ".[$i].name")
    WIDTH=$(echo "$MONITOR_DATA" | jq -r ".[$i].width")
    HEIGHT=$(echo "$MONITOR_DATA" | jq -r ".[$i].height")
    REFRESH=$(echo "$MONITOR_DATA" | jq -r ".[$i].refreshRate")
    DETECTED_MONITORS+=("$MONITOR_NAME")
    print_info "  Monitor $((i+1)): $MONITOR_NAME (${WIDTH}x${HEIGHT}@${REFRESH}Hz)"
done

echo ""
echo "=== MONITOR MAPPING ==="
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

CHANGES_MADE=false

for config_file in "${CONFIG_FILES[@]}"; do
    if [[ -f "$config_file" ]]; then
        basename_file=$(basename "$config_file")
        print_info "Processing $basename_file..."

        # Copy original to temp directory
        cp "$config_file" "$TEMP_DIR/${basename_file}.original"
        cp "$config_file" "$TEMP_DIR/${basename_file}.modified"

        # Perform replacements on the modified copy
        FILE_CHANGED=false
        for ((i=0; i<${#TEMPLATE_MONITORS[@]}; i++)); do
            if [[ $i -lt ${#DETECTED_MONITORS[@]} ]]; then
                TEMPLATE="${TEMPLATE_MONITORS[$i]}"
                DETECTED="${DETECTED_MONITORS[$i]}"

                if [[ "$TEMPLATE" != "$DETECTED" ]]; then
                    # Count occurrences before replacement
                    COUNT=$(grep -o "$TEMPLATE" "$TEMP_DIR/${basename_file}.modified" 2>/dev/null | wc -l)

                    if [[ $COUNT -gt 0 ]]; then
                        sed -i "s/${TEMPLATE}/${DETECTED}/g" "$TEMP_DIR/${basename_file}.modified"
                        echo "    - Replaced $COUNT instance(s) of $TEMPLATE with $DETECTED"
                        FILE_CHANGED=true
                        CHANGES_MADE=true
                    fi
                fi
            fi
        done

        if [[ "$FILE_CHANGED" == false ]]; then
            echo "    - No changes needed"
            rm "$TEMP_DIR/${basename_file}.modified"
            rm "$TEMP_DIR/${basename_file}.original"
        fi
    else
        print_warning "$config_file not found, skipping..."
    fi
done

echo ""

if [[ "$CHANGES_MADE" == true ]]; then
    print_success "Simulation complete! Results saved to: $TEMP_DIR"
    echo ""
    echo "=== COMPARISON ==="
    for file in "$TEMP_DIR"/*.modified; do
        if [[ -f "$file" ]]; then
            basename_file=$(basename "$file" .modified)
            echo ""
            echo "--- $basename_file ---"
            echo "Original lines with monitor references:"
            grep -n "DP-[0-9]" "$TEMP_DIR/${basename_file}.original" 2>/dev/null || echo "  (none)"
            echo ""
            echo "Modified lines with monitor references:"
            grep -n "DP-[0-9]\|HDMI-[0-9]" "$TEMP_DIR/${basename_file}.modified" 2>/dev/null || echo "  (none)"
        fi
    done

    echo ""
    echo "=== FULL DIFF ==="
    for file in "$TEMP_DIR"/*.modified; do
        if [[ -f "$file" ]]; then
            basename_file=$(basename "$file" .modified)
            echo ""
            echo "--- Diff for $basename_file ---"
            diff -u "$TEMP_DIR/${basename_file}.original" "$TEMP_DIR/${basename_file}.modified" || true
        fi
    done
else
    print_info "No replacements needed - monitors already match!"
    rm -rf "$TEMP_DIR"
    echo "Temp directory cleaned up (no changes to show)"
fi

echo ""
echo "Temp directory: $TEMP_DIR"
echo "Files will be kept for your review. Delete manually when done."
