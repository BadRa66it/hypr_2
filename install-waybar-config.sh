#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Логотип
echo -e "${PURPLE}"
cat << "EOF"
╔══════════════════════════════════════╗
║        Waybar Auto Installer         ║
║     Hyprland + Japanese Theme        ║
╚══════════════════════════════════════╝
EOF
echo -e "${NC}"

print_status() {
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

# Проверка Arch Linux
if ! command -v pacman &> /dev/null; then
    print_error "Этот скрипт предназначен для Arch Linux"
    exit 1
fi

print_status "Начинаем установку waybar конфигурации..."

# Создание резервной копии
WAYBAR_DIR="$HOME/.config/waybar"
BACKUP_DIR="$HOME/.config/waybar.backup.$(date +%Y%m%d_%H%M%S)"

if [ -d "$WAYBAR_DIR" ]; then
    print_warning "Найдена существующая конфигурация waybar"
    read -p "Создать резервную копию? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp -r "$WAYBAR_DIR" "$BACKUP_DIR"
        print_success "Резервная копия создана: $BACKUP_DIR"
    fi
fi

# Проверка зависимостей
print_status "Проверка зависимостей..."

# AUR helper detection
AUR_HELPER=""
if command -v yay &> /dev/null; then
    AUR_HELPER="yay"
elif command -v paru &> /dev/null; then
    AUR_HELPER="paru"
else
    print_warning "AUR helper (yay/paru) не найден. Устанавливаем yay..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    AUR_HELPER="yay"
fi

print_success "Используем AUR helper: $AUR_HELPER"

# Список необходимых пакетов
PACMAN_PACKAGES=(
    "waybar"
    "rofi" 
    "networkmanager"
    "libnotify"
    "brightnessctl"
    "pavucontrol"
    "python"
    "python-requests"
    "ttf-jetbrains-mono-nerd"
    "ttf-font-awesome"
    "noto-fonts-cjk"
)

AUR_PACKAGES=(
    "swaylock-effects"
    "brillo"
)

# Установка пакетов из официальных репозиториев
print_status "Установка пакетов из официальных репозиториев..."
for package in "${PACMAN_PACKAGES[@]}"; do
    if ! pacman -Qi "$package" &> /dev/null; then
        print_status "Установка $package..."
        sudo pacman -S --noconfirm "$package"
    else
        print_success "$package уже установлен"
    fi
done

# Установка пакетов из AUR
print_status "Установка пакетов из AUR..."
for package in "${AUR_PACKAGES[@]}"; do
    if ! pacman -Qi "$package" &> /dev/null; then
        print_status "Установка $package из AUR..."
        $AUR_HELPER -S --noconfirm "$package"
    else
        print_success "$package уже установлен"
    fi
done

# Создание структуры директорий
print_status "Создание структуры директорий..."
mkdir -p "$HOME/.config/waybar/scripts/"{network,power-menu/shared}
mkdir -p "$HOME/.local/bin"

# Копирование конфигурационных файлов
print_status "Копирование конфигурационных файлов..."

# Определяем директорию скрипта (где находится этот install скрипт)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Копируем waybar конфиги
if [ -f "$SCRIPT_DIR/waybar/config" ]; then
    cp "$SCRIPT_DIR/waybar/config" "$HOME/.config/waybar/"
    print_success "config скопирован"
fi

if [ -f "$SCRIPT_DIR/waybar/style.css" ]; then
    cp "$SCRIPT_DIR/waybar/style.css" "$HOME/.config/waybar/"
    print_success "style.css скопирован"
fi

# Копируем скрипты
if [ -d "$SCRIPT_DIR/waybar/scripts" ]; then
    cp -r "$SCRIPT_DIR/waybar/scripts/"* "$HOME/.config/waybar/scripts/"
    print_success "скрипты скопированы"
fi

# Копируем waybar-reload в ~/.local/bin
if [ -f "$SCRIPT_DIR/waybar-reload.sh" ]; then
    cp "$SCRIPT_DIR/waybar-reload.sh" "$HOME/.local/bin/"
    chmod +x "$HOME/.local/bin/waybar-reload.sh"
    print_success "waybar-reload.sh установлен"
fi

# Делаем все скрипты исполняемыми
print_status "Настройка разрешений для скриптов..."
find "$HOME/.config/waybar/scripts" -name "*.sh" -exec chmod +x {} \;
find "$HOME/.config/waybar/scripts" -name "*.py" -exec chmod +x {} \;
chmod +x "$HOME/.config/waybar/scripts/rofi-bluetooth" 2>/dev/null

# Добавляем ~/.local/bin в PATH если нужно
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    print_status "Добавление ~/.local/bin в PATH..."
    
    # Определяем shell
    if [ -n "$ZSH_VERSION" ]; then
        SHELL_RC="$HOME/.zshrc"
    else
        SHELL_RC="$HOME/.bashrc"
    fi
    
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
    export PATH="$HOME/.local/bin:$PATH"
    print_success "PATH обновлен"
fi

# Включаем NetworkManager если не запущен
if ! systemctl is-active --quiet NetworkManager; then
    print_status "Включение NetworkManager..."
    sudo systemctl enable --now NetworkManager
    print_success "NetworkManager включен"
fi

# Проверяем конфигурацию
print_status "Проверка конфигурации..."

# Проверяем основные файлы
files_check=(
    "$HOME/.config/waybar/config"
    "$HOME/.config/waybar/style.css"
    "$HOME/.config/waybar/scripts/weather.py"
    "$HOME/.config/waybar/scripts/network/rofi-wifi-menu.sh"
)

all_good=true
for file in "${files_check[@]}"; do
    if [ -f "$file" ]; then
        print_success "✓ $(basename "$file")"
    else
        print_error "✗ $(basename "$file") не найден"
        all_good=false
    fi
done

# Финальные инструкции
echo
echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║                    УСТАНОВКА ЗАВЕРШЕНА!                   ║${NC}"
echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo

if [ "$all_good" = true ]; then
    print_success "Все файлы успешно установлены!"
    echo
    print_status "Для запуска waybar выполните:"
    echo -e "  ${GREEN}waybar &${NC}"
    echo
    print_status "Для автоперезагрузки при изменениях:"
    echo -e "  ${GREEN}waybar-reload.sh${NC}"
    echo
    print_status "Возможности:"
    echo "  • 📶 Клик по Wi-Fi иконке - меню выбора сети"
    echo "  • ⏻ Клик по кнопке питания - меню выключения"
    echo "  • 🔒 Клик по замку - блокировка экрана"
    echo "  • ❄️ Погода обновляется каждые 5 минут"
    echo "  • 雪 Лаунчер приложений"
    echo
    print_warning "Перезапустите терминал или выполните:"
    echo -e "  ${YELLOW}source ~/.bashrc${NC} (или ~/.zshrc для zsh)"
    
    if [ -d "$BACKUP_DIR" ]; then
        echo
        print_status "Резервная копия старой конфигурации:"
        echo "  $BACKUP_DIR"
    fi
else
    print_error "Некоторые файлы не были установлены корректно"
    print_status "Проверьте содержимое директории проекта"
fi

echo
print_status "Документация и обновления:"
echo "  GitHub: https://github.com/ваш-username/waybar-config"
echo