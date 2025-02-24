# 🚀 zsh-setup

This repository contains a script for the automatic installation and configuration of Oh‑My‑Zsh with a specified theme and plugins. The script has been modified for macOS 🍏 and includes handling for existing directories (removing and re-cloning plugins and themes). In addition, instructions are provided for using the original script for Linux 🐧 or Docker containers 🐳.

---

## 📜 Table of Contents
- [✨ Features](#features)
- [🍏 Usage on macOS](#usage-on-macos)
- [🐧 Usage on Linux / in Containers](#usage-on-linux--in-containers)
- [⚙️ Script Arguments](#script-arguments)
- [📦 Dockerfile Integration](#dockerfile-integration)
- [📝 Original Script](#original-script)

---

## ✨ Features

- **🍏 macOS Only (Modified Script)**  
  The macOS script uses Homebrew 🍺 to install dependencies (`git`, `curl`, `zsh`) and automatically removes any existing plugin and theme directories before re-cloning them.

- **🐧 Original Script for Linux / Containers**  
  For Linux systems and Docker containers, you can use the original script which configures Oh‑My‑Zsh with support for various distributions (`apt`, `yum`, `apk`, etc.).

- **⚙️ Argument Support**  
  The script accepts arguments for specifying the theme, plugins, additional lines to append to the configuration, and a flag to disable dependency installation.

- **🔗 Reference to the Original Script**  
  This modification is based on the original script available at:  
  [Original zsh-in-docker.sh](https://github.com/kitenko/zsh-in-docker/blob/master/zsh-in-docker.sh)

---

## 🍏 Usage on macOS

1. **Clone the repository and navigate into the directory:**

   ```sh
   git clone https://github.com/yourusername/zsh-setup.git
   cd zsh-setup
   ```

2. **Make the script executable:**

   ```sh
   chmod +x install.sh
   ```

3. **Run the script as a regular (non-root) user with the desired arguments.**  
   Example:

   ```sh
   bash install.sh -t gnzh \
       -p git -p ssh-agent -p 'history-substring-search' \
       -a 'bindkey "\$terminfo[kcuu1]" history-substring-search-up' \
       -a 'bindkey "\$terminfo[kcud1]" history-substring-search-down' \
       -p https://github.com/zsh-users/zsh-autosuggestions \
       -p https://github.com/zsh-users/zsh-completions \
       -p https://github.com/esc/conda-zsh-completion \
       -p https://github.com/romkatv/zsh-defer.git \
       -p https://github.com/zdharma-continuum/fast-syntax-highlighting
   ```

4. **🔄 Restart your terminal.**  
   After installation, a new `.zshrc` file will be created in your home directory. Open a new terminal or run:

   ```sh
   exec zsh
   ```

---

## 🐧 Usage on Linux / in Containers

For Linux systems and containers, you can use the **original script** (for example, [zsh-in-docker.sh](https://github.com/kitenko/zsh-in-docker/blob/master/zsh-in-docker.sh)) as follows:


---

## ⚙️ Script Arguments

- **`-t <theme>` 🎨**  
  Specifies the theme. By default, if not provided, the script sets the theme to `powerlevel10k/powerlevel10k`.

- **`-p <plugin>` 🔌**  
  Specifies a plugin. You can provide multiple `-p` options. A plugin can be given as a simple name (e.g., `git`) or as a URL (e.g., `https://github.com/zsh-users/zsh-autosuggestions`).

- **`-a <append_line>` 📝**  
  An additional line to be appended to the generated `.zshrc` file. This is useful for adding custom key bindings or other settings.

- **`-x` ❌**  
  Disables dependency installation. Useful if you have already installed the required software.

---

## 📦 Dockerfile Integration

You can also integrate the installation directly into your Dockerfile. For example, add the following command to your Dockerfile:

```dockerfile
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.1/zsh-in-docker.sh)" -- \
    -t gnzh \
    -p git -p ssh-agent -p 'history-substring-search' \
    -a 'bindkey "\$terminfo[kcuu1]" history-substring-search-up' \
    -a 'bindkey "\$terminfo[kcud1]" history-substring-search-down' \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/esc/conda-zsh-completion \
    -p https://github.com/romkatv/zsh-defer.git \
    -p https://github.com/zdharma-continuum/fast-syntax-highlighting
```

This command will configure your Docker container with your custom Zsh settings during the image build.

---

## 📝 Original Script

The original script that this version was modified from can be found here:  
[Original zsh-in-docker.sh](https://github.com/kitenko/zsh-in-docker/blob/master/zsh-in-docker.sh)

---

This README explains how to use the modified macOS installation script as well as how to use the original script for Linux or Docker containers. Enjoy your enhanced Zsh experience! 🎉
