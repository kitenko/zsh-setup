#!/bin/sh
# MIT License (MIT)
# Below is the modified script in English for macOS only, with comments and a reference to the original file. This script was modified from the original script at:
# https://github.com/kitenko/zsh-in-docker/blob/master/zsh-in-docker.sh
# (Copyright notice omitted for brevity)
#
# This script installs Oh-My-Zsh and configures it with the specified theme and plugins on macOS.
# Supported arguments:
#   -t <theme>         Specify the theme (default: powerlevel10k)
#   -p <plugin>        Specify a plugin; you can provide multiple plugins (name or URL)
#   -a <append_line>   Additional line to be appended to .zshrc
#   -x                 Disable dependency installation
#
# Example usage:
# bash install.sh -t gnzh \
#    -p git -p ssh-agent -p 'history-substring-search' \
#    -a 'bindkey "\$terminfo[kcuu1]" history-substring-search-up' \
#    -a 'bindkey "\$terminfo[kcud1]" history-substring-search-down' \
#    -p https://github.com/zsh-users/zsh-autosuggestions \
#    -p https://github.com/zsh-users/zsh-completions \
#    -p https://github.com/esc/conda-zsh-completion \
#    -p https://github.com/romkatv/zsh-defer.git \
#    -p https://github.com/zdharma-continuum/fast-syntax-highlighting
#
# Original script: https://github.com/kitenko/zsh-in-docker/blob/master/zsh-in-docker.sh

set -e

THEME=default
PLUGINS=""
ZSHRC_APPEND=""
INSTALL_DEPENDENCIES=true

# Parse command-line options
while getopts ":t:p:a:x" opt; do
    case ${opt} in
        t)  THEME=$OPTARG
            ;;
        p)  PLUGINS="${PLUGINS}$OPTARG "
            ;;
        a)  ZSHRC_APPEND="$ZSHRC_APPEND\n$OPTARG"
            ;;
        x)  INSTALL_DEPENDENCIES=false
            ;;
        \?)
            echo "Invalid option: $OPTARG" 1>&2
            ;;
        :)
            echo "Invalid option: $OPTARG requires an argument" 1>&2
            ;;
    esac
done
shift $((OPTIND -1))

echo
echo "Installing Oh-My-Zsh with:"
echo "  THEME   = $THEME"
echo "  PLUGINS = $PLUGINS"
echo

# Ensure the script runs only on macOS
if [ "$(uname)" != "Darwin" ]; then
    echo "Error: This script is intended for macOS (Darwin) only."
    exit 1
fi

# Function to install dependencies using Homebrew on macOS
install_dependencies() {
    echo "###### Installing dependencies for macOS"
    # Do not run as root since Homebrew does not support that
    if [ "$(id -u)" = "0" ]; then
        echo "Error: Do not run this script as root on macOS."
        exit 1
    fi
    if which brew >/dev/null 2>&1; then
        brew update
        brew install git curl zsh
    else
        echo "Homebrew not found. Please install Homebrew: https://brew.sh/"
        exit 1
    fi
}

# Function to generate the .zshrc template
zshrc_template() {
    _HOME=$1;
    _THEME=$2; shift; shift
    _PLUGINS=$*;
    
    # If theme is default, set it to powerlevel10k/powerlevel10k
    if [ "$_THEME" = "default" ]; then
        _THEME="powerlevel10k/powerlevel10k"
    fi

    cat <<EOM
export LANG='en_US.UTF-8'
export LANGUAGE='en_US:en'
export LC_ALL='en_US.UTF-8'
[ -z "\$TERM" ] && export TERM=xterm-256color

##### Zsh/Oh-My-Zsh Configuration
export ZSH="$_HOME/.oh-my-zsh"

ZSH_THEME="${_THEME}"
plugins=($_PLUGINS)

EOM
    # Append any additional lines provided via -a options
    printf "$ZSHRC_APPEND"
    printf "\nsource \$ZSH/oh-my-zsh.sh\n"
}

# Function to output a basic Powerlevel10k configuration
powerlevel10k_config() {
    cat <<EOM
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_to_last"
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(user dir vcs status)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
POWERLEVEL9K_STATUS_OK=false
POWERLEVEL9K_STATUS_CROSS=true
EOM
}

# Install dependencies if enabled
if [ "$INSTALL_DEPENDENCIES" = true ]; then
    install_dependencies
fi

cd /tmp

# Install Oh-My-Zsh if not already installed
if [ ! -d "$HOME"/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
fi

# Generate plugin list and clone plugins
plugin_list=""
for plugin in $PLUGINS; do
    if echo "$plugin" | grep -E '^http.*' >/dev/null; then
        plugin_name=$(basename "$plugin")
        # Remove the .git extension if present
        plugin_name=$(echo "$plugin_name" | sed 's/\.git$//')
        PLUGIN_DIR="$HOME/.oh-my-zsh/custom/plugins/$plugin_name"
        if [ -d "$PLUGIN_DIR" ]; then
            echo "Removing existing plugin directory: $PLUGIN_DIR"
            rm -rf "$PLUGIN_DIR"
        fi
        git clone "$plugin" "$PLUGIN_DIR"
    else
        plugin_name=$plugin
    fi
    plugin_list="${plugin_list}$plugin_name "
done

# Process theme if it is specified as a URL
if echo "$THEME" | grep -E '^http.*' >/dev/null; then
    theme_repo=$(basename "$THEME")
    THEME_DIR="$HOME/.oh-my-zsh/custom/themes/$theme_repo"
    if [ -d "$THEME_DIR" ]; then
        echo "Removing existing theme directory: $THEME_DIR"
        rm -rf "$THEME_DIR"
    fi
    git clone "$THEME" "$THEME_DIR"
    theme_name=$(cd "$THEME_DIR"; ls *.zsh-theme | head -1)
    theme_name="${theme_name%.zsh-theme}"
    THEME="$theme_repo/$theme_name"
fi

# Generate .zshrc using the template
zshrc_template "$HOME" "$THEME" "$plugin_list" > "$HOME"/.zshrc

# If the theme is default (or powerlevel10k/powerlevel10k), install Powerlevel10k and append its config
if [ "$THEME" = "default" ] || [ "$THEME" = "powerlevel10k/powerlevel10k" ]; then
    THEME_DIR="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    if [ -d "$THEME_DIR" ]; then
        echo "Removing existing Powerlevel10k directory: $THEME_DIR"
        rm -rf "$THEME_DIR"
    fi
    git clone --depth 1 https://github.com/romkatv/powerlevel10k "$THEME_DIR"
    powerlevel10k_config >> "$HOME"/.zshrc
fi

echo "Installation complete! Please restart your terminal."