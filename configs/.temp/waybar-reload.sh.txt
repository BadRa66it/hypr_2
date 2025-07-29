#!/bin/bash

WAYBAR_CONFIG_DIR="$HOME/.config/waybar"

# Проверка наличия inotifywait
if ! command -v inotifywait &>/dev/null; then
    echo "❌ inotifywait не найден. Установи пакет: sudo pacman -S inotify-tools"
    exit 1
fi

# Проверка существования директории
if [ ! -d "$WAYBAR_CONFIG_DIR" ]; then
    echo "❌ Директория $WAYBAR_CONFIG_DIR не найдена!"
    exit 1
fi

echo "🔄 Запуск автоперезагрузки waybar при изменении конфигов..."
echo "📁 Отслеживается: $WAYBAR_CONFIG_DIR"
echo "⏹️  Для остановки нажмите Ctrl+C"

reload_waybar() {
    echo "🔄 $(date '+%H:%M:%S') - Конфиг изменен, перезапускаем waybar..."
    pkill -x waybar
    sleep 0.5
    setsid waybar >/dev/null 2>&1 &
    echo "✅ Waybar перезапущен"
}

# Если waybar не запущен — стартуем
if ! pgrep -x waybar >/dev/null; then
    echo "🚀 Запускаем waybar..."
    setsid waybar >/dev/null 2>&1 &
fi

# Watcher
inotifywait -m -r -e modify,create,delete,move \
    --include '\.(json|css)$' \
    "$WAYBAR_CONFIG_DIR" | while read -r directory events filename; do
    reload_waybar
done