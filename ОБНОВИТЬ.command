#!/bin/bash
# APEX — обновление приложения до последней версии. Двойной клик по этому файлу.
# Скачивает свежий код с GitHub, обновляет проект и открывает Xcode (дальше — кнопка ▶).
DIR="$HOME/apex-native"

if ! command -v node >/dev/null 2>&1; then
  osascript -e 'display alert "Сначала нужен Node.js" message "Скачай версию LTS с nodejs.org, установи и запусти меня снова."'
  open https://nodejs.org
  exit 1
fi

if [ -d "$DIR/.git" ]; then
  cd "$DIR" || exit 1
  echo "Проверяю обновления..."
  if ! git pull --ff-only; then
    echo "Локальная копия разошлась с сервером — скачаю заново."
    cd "$HOME" && rm -rf "$DIR"
  fi
fi

if [ ! -d "$DIR/.git" ]; then
  echo "Скачиваю проект с GitHub (только в первый раз)..."
  git clone https://github.com/goalieteam-wq/apex-native.git "$DIR" || {
    osascript -e 'display alert "Не удалось скачать проект" message "Проверь интернет и запусти ещё раз. Не помогает — скриншот этого окна в чат."'
    exit 1
  }
fi

cd "$DIR"
echo "Ставлю зависимости и синхронизирую (1-2 минуты)..."
if npm install && npx cap sync ios; then
  osascript -e 'display notification "Обновлено! Открываю Xcode — жми ▶." with title "APEX ✅"'
  open ios/App/App.xcodeproj
else
  osascript -e 'display alert "Ошибка" message "Установка зависимостей не прошла. Сделай скриншот этого окна и отправь в чат."'
fi
