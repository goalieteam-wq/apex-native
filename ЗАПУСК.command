#!/bin/bash
# APEX — подготовка проекта к открытию в Xcode. Двойной клик по этому файлу.
cd "$(dirname "$0")"

if ! command -v node >/dev/null 2>&1; then
  osascript -e 'display alert "Сначала нужен Node.js" message "Сейчас откроется nodejs.org — скачай версию LTS и установи её (дальше-дальше-готово), потом запусти меня снова."'
  open https://nodejs.org
  exit 1
fi

echo "Ставлю зависимости (1-2 минуты)..."
if npm install; then
  osascript -e 'display notification "Готово! Открываю Xcode." with title "APEX ✅"'
  open ios/App/App.xcodeproj
else
  osascript -e 'display alert "Ошибка" message "npm install не прошёл. Сделай скриншот окна Терминала и отправь его в чат."'
fi
