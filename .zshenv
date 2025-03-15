# Command not found handler
function command_not_found_handler {
    local purple='\e[1;35m' bright='\e[0;1m' green='\e[1;32m' reset='\e[0m'
    printf 'zsh: command not found: %s\n' "$1"
    local entries=( ${(f)"$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$1")"} )
    if (( ${#entries[@]} > 0 )); then
        printf "${bright}$1${reset} may be found in the following packages:\n"
        local pkg
        for entry in "${entries[@]}"; do
            local fields=( ${(0)entry} )
            if [[ "$pkg" != "${fields[2]}" ]]; then
                printf "${purple}%s/${bright}%s ${green}%s${reset}\n" "${fields[1]}" "${fields[2]}" "${fields[3]}"
            fi
            printf '    /%s\n' "${fields[4]}"
            pkg="${fields[2]}"
        done
    fi
    return 127
}

function load_zsh_plugins {
    # Oh-my-zsh installation path
    zsh_paths=(
        "$HOME/.oh-my-zsh"
        "/usr/local/share/oh-my-zsh"
        "/usr/share/oh-my-zsh"
    )
    for zsh_path in "${zsh_paths[@]}"; do [[ -d $zsh_path ]] && export ZSH=$zsh_path && break; done
    # Load Plugins
    plugins+=( "${plugins[@]}"git zsh-256color zsh-autosuggestions zsh-syntax-highlighting)
    # Deduplicate plugins
    plugins=("${plugins[@]}")
    plugins=($(printf "%s\n" "${plugins[@]}" | sort -u))

    # Loads om-my-zsh
    [[ -r $ZSH/oh-my-zsh.sh ]] && source $ZSH/oh-my-zsh.sh
}

# Install packages from both Arch and AUR
function in {
    local -a inPkg=("$@")
    local -a arch=()
    local -a aur=()

    for pkg in "${inPkg[@]}"; do
    if pacman -Si "${pkg}" &>/dev/null; then
    arch+=("${pkg}")
    else
    aur+=("${pkg}")
    fi
    done

    if [[ ${#arch[@]} -gt 0 ]]; then
    sudo pacman -S "${arch[@]}"
    fi

    if [[ ${#aur[@]} -gt 0 ]]; then
    ${aurhelper} -S "${aur[@]}"
    fi
}

# Function to handle initialization errors
function handle_init_error {
    if [[ $? -ne 0 ]]; then
        echo "Error during initialization. Please check your configuration."
    fi
}


function no_such_file_or_directory_handler {
    local red='\e[1;31m' reset='\e[0m'
    printf "${red}zsh: no such file or directory: %s${reset}\n" "$1"
    return 127
}


# cleaning up home folder
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CONFIG_DIR="${XDG_CONFIG_DIR:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_DATA_DIRS="${XDG_DATA_DIRS:-$XDG_DATA_HOME:/usr/local/share:/usr/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_DESKTOP_DIR="${XDG_DESKTOP_DIR:-$HOME/Desktop}"
XDG_DOWNLOAD_DIR="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
XDG_TEMPLATES_DIR="${XDG_TEMPLATES_DIR:-$HOME/Templates}"
XDG_PUBLICSHARE_DIR="${XDG_PUBLICSHARE_DIR:-$HOME/Public}"
XDG_DOCUMENTS_DIR="${XDG_DOCUMENTS_DIR:-$HOME/Documents}"
XDG_MUSIC_DIR="${XDG_MUSIC_DIR:-$HOME/Music}"
XDG_PICTURES_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}"
XDG_VIDEOS_DIR="${XDG_VIDEOS_DIR:-$HOME/Videos}"
LESSHISTFILE=${LESSHISTFILE:-/tmp/less-hist}
PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"

# wget
WGETRC="${XDG_CONFIG_HOME}/wgetrc"
SCREENRC="$XDG_CONFIG_HOME"/screen/screenrc

export XDG_CONFIG_HOME XDG_CONFIG_DIR XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME XDG_DESKTOP_DIR XDG_DOWNLOAD_DIR \
XDG_TEMPLATES_DIR XDG_PUBLICSHARE_DIR XDG_DOCUMENTS_DIR XDG_MUSIC_DIR XDG_PICTURES_DIR XDG_VIDEOS_DIR WGETRC SCREENRC 



if [ -t 1 ];then
    # We are loading the prompt on start so users can see the prompt immediately
    # Powerlevel10k theme path
    P10k_THEME=${P10k_THEME:-/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme}
    [[ -r $P10k_THEME ]] && source $P10k_THEME

    # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

    # Detect AUR wrapper and cache it for faster subsequent loads
    aur_cache_file="/tmp/.aurhelper.zshrc"
    if [[ -f $aur_cache_file ]]; then
        aurhelper=$(<"$aur_cache_file")
    else
        if pacman -Qi yay &>/dev/null; then
            aurhelper="yay"
        elif pacman -Qi paru &>/dev/null; then
            aurhelper="paru"
        fi
        echo "$aurhelper" > "$aur_cache_file"
    fi

    # Roll a N-sided dice
    roll=$((RANDOM % 15 + 1))

    case $roll in
        1)
            pokego --no-title -name shinx -s
            ;;
        2)
            pokego --no-title -name bulbasaur -s
            ;;
        3)
            pokego --no-title -name turtwig -s
            ;;
        4)
            pokego --no-title -name pikachu -s
            ;;
        5)
            pokego --no-title -name magikarp -s
            ;;
        6)
            pokego --no-title -name ponyta -s
            ;;
        7)
            pokego --no-title -name darkrai -s
            ;;
        8)
            pokego --no-title -name mudkip -s
            ;;
        9)
            pokego --no-title -name squirtle -s
            ;;
        10)
            pokego --no-title -name chimchar -s
            ;;
        11)
            pokego --no-title -name staryu -s
            ;;
        12)
            pokego --no-title -name jigglypuff -s
            ;;
        13)
            pokego --no-title -name dratini -s
            ;;
        14)
            pokego --no-title -name electrode -s
            ;;
        *)
            pokego --no-title -name roselia -s
            ;;
    esac

    # Helpful aliases
    if [[ -x "$(which eza)" ]]; then
        alias ls='eza' \
            l='eza -lh --icons=auto' \
            ll='eza -lha --icons=auto --sort=name --group-directories-first' \
            ld='eza -lhD --icons=auto' \
            lt='eza --icons=auto --tree'
    fi

    alias c='clear' \
        un='$aurhelper -Rns' \
        up='$aurhelper -Syu' \
        pl='$aurhelper -Qs' \
        pa='$aurhelper -Ss' \
        pc='$aurhelper -Sc' \
        po='$aurhelper -Qtdq | $aurhelper -Rns -' \
        vc='code' \
        fastfetch='fastfetch --logo-type kitty' \
        ..='cd ..' \
        ...='cd ../..' \
        .3='cd ../../..' \
        .4='cd ../../../..' \
        .5='cd ../../../../..' \
        mkdir='mkdir -p' # Always mkdir a path (this doesn't inhibit functionality to make a single dir)


    # Load plugins
    load_zsh_plugins

fi
