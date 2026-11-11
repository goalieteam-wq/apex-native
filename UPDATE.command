#!/bin/bash
# APEX — обновление приложения до последней версии. Двойной клик по этому файлу.
# Скачивает свежий код с GitHub, обновляет проект и открывает Xcode (дальше — кнопка ▶).
DIR="$HOME/apex-native"
REPO="https://github.com/goalieteam-wq/apex-native.git"

if ! command -v node >/dev/null 2>&1; then
  osascript -e 'display alert "Сначала нужен Node.js" message "Скачай версию LTS с nodejs.org, установи и запусти меня снова."'
  open https://nodejs.org
  exit 1
fi

if [ -d "$DIR/.git" ]; then
  cd "$DIR" || exit 1
  echo "Проверяю обновления..."
  if ! git pull --ff-only; then
    echo "Локальная копия разошлась с сервером — скачаю заново (старую сохраню в резерв)."
    cd "$HOME" && mv "$DIR" "$DIR-backup-$(date +%m%d-%H%M)"
  fi
fi

if [ ! -d "$DIR" ]; then
  echo "Скачиваю проект с GitHub (только в первый раз)..."
  git clone "$REPO" "$DIR" || {
    osascript -e 'display alert "Не удалось скачать проект" message "Проверь интернет и запусти ещё раз. Не помогает — скриншот этого окна в чат."'
    exit 1
  }
elif [ ! -d "$DIR/.git" ]; then
  echo "Нашёл старую папку приложения — обновляю код, настройки Xcode не трогаю..."
  TMP="$HOME/apex-native-fresh"
  rm -rf "$TMP"
  if ! git clone --depth 1 "$REPO" "$TMP"; then
    osascript -e 'display alert "Не удалось скачать обновление" message "Проверь интернет и запусти ещё раз. Не помогает — скриншот этого окна в чат."'
    exit 1
  fi
  cp -R "$TMP/www" "$DIR/"
  for f in package.json package-lock.json capacitor.config.json README-RUS.txt ОБНОВИТЬ.command UPDATE.command; do
    [ -f "$TMP/$f" ] && cp "$TMP/$f" "$DIR/"
  done
  # картинки нативной заставки и иконки (настройки Xcode — подпись — не трогаем)
  if [ -d "$DIR/ios/App/App/Assets.xcassets" ] && [ -d "$TMP/ios/App/App/Assets.xcassets" ]; then
    rm -rf "$DIR/ios/App/App/Assets.xcassets"
    cp -R "$TMP/ios/App/App/Assets.xcassets" "$DIR/ios/App/App/"
    echo "Обновил картинки заставки и иконки."
  fi
  rm -rf "$TMP"
fi

cd "$DIR"
# чиним право запуска у скриптов (после скачивания браузер его снимает)
chmod +x "$DIR"/*.command 2>/dev/null
echo "Ставлю зависимости и синхронизирую (1-2 минуты)..."
if npm install && npx cap sync ios; then
  # Кнопка «APEX ОБНОВИТЬ» на Рабочем столе: свежая копия без блокировок Gatekeeper.
  # С этого момента обновление = двойной клик по ней (правый клик → Открыть).
  if cp "$DIR/ОБНОВИТЬ.command" "$HOME/Desktop/APEX ОБНОВИТЬ.command" 2>/dev/null; then
    chmod +x "$HOME/Desktop/APEX ОБНОВИТЬ.command" 2>/dev/null
    echo "На Рабочем столе теперь кнопка «APEX ОБНОВИТЬ» — больше ничего скачивать не нужно."
  fi
  osascript -e 'display notification "Обновлено! На Рабочем столе кнопка APEX. Открываю Xcode — жми ▶." with title "APEX ✅"'
  open ios/App/App.xcodeproj
else
  osascript -e 'display alert "Ошибка" message "Установка зависимостей не прошла. Сделай скриншот этого окна и отправь в чат."'
fi
