#!/bin/bash

# Путь к конфигу waybar
WAYBAR_CONFIG_DIR="$HOME/.config/waybar"

echo "🔄 Запуск автоперезагрузки waybar при изменении конфигов..."
echo "📁 Отслеживается: $WAYBAR_CONFIG_DIR"
echo "⏹️  Для остановки нажмите Ctrl+C"

# Функция перезапуска waybar
reload_waybar() {
    echo "🔄 $(date '+%H:%M:%S') - Конфиг изменен, перезапускаем waybar..."
    pkill waybar
    sleep 0.5
    waybar & disown
    echo "✅ Waybar перезапущен"
}

# Запускаем waybar если не запущен
if ! pgrep waybar > /dev/null; then
    echo "🚀 Запускаем waybar..."
    waybar & disown
fi

# Отслеживаем изменения в конфигах
inotifywait -m -e modify,create,delete,move \
    --include '\.(json|css)$' \
    "$WAYBAR_CONFIG_DIR" | while read -r directory events filename; do
    reload_waybar
done