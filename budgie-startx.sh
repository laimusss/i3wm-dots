#!/bin/bash

# Убедитесь, что вы запускаете скрипт с правами суперпользователя
if [[ "$EUID" -ne 0 ]]; then
  echo "Пожалуйста, запустите скрипт от имени суперпользователя (sudo)."
  exit 1
fi

# Запрос имени пользователя для автоматического входа
read -p "Введите имя пользователя для автоматического входа: " username

# Создание директории и конфигурационного файла для автологина
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat << EOF > /etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
Type=simple
ExecStart=
ExecStart=-/sbin/agetty --autologin $username --noclear %I 38400 linux
EOF

# Настройка автоматического запуска X-сессии в ~/.profile
profile_file="/home/$username/.profile"

if [[ ! -f "$profile_file" ]]; then
  echo "$profile_file не существует, создаю новый файл."
  touch "$profile_file"
fi

if ! grep -q "startx" "$profile_file"; then
  echo "# Запуск X-сессии автоматически, если она еще не запущена" >> "$profile_file"
  echo "if [[ -z \"\$DISPLAY\" ]] && [[ \$(tty) = /dev/tty1 ]]; then" >> "$profile_file"
  echo "  exec startx" >> "$profile_file"
  echo "fi" >> "$profile_file"
fi

# Создание файла ~/.xinitrc для запуска Budgie
xinitrc_file="/home/$username/.xinitrc"

if [[ ! -f "$xinitrc_file" ]]; then
  echo "$xinitrc_file не существует, создаю новый файл."
  touch "$xinitrc_file"
fi

if ! grep -q "budgie-desktop" "$xinitrc_file"; then
  echo "exec budgie-desktop" > "$xinitrc_file"
fi

# Установка пакета budgie-desktop, если он не установлен
if ! dpkg -l | grep -q budgie-desktop; then
  echo "Установка пакета budgie-desktop..."
  apt update
  apt install -y budgie-desktop
else
  echo "Пакет budgie-desktop уже установлен."
fi

# Завершение
echo "Настройка завершена. Пожалуйста, перезагрузите систему."
