#!/bin/bash

# Убедитесь, что вы запускаете скрипт с правами суперпользователя
if [[ "$EUID" -ne 0 ]]; then
 echo "Пожалуйста, запустите скрипт от имени суперпользователя (sudo)."
 exit 1
fi

# Установка nala, если он не установлен
if ! dpkg -l | grep -q nala; then
 echo "Установка пакетного менеджера nala..."
 apt update
 apt install -y nala
else
 echo "Пакетный менеджер nala уже установлен."
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
 echo " exec startx" >> "$profile_file"
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
 nala update
 nala install -y xserver-xorg-core xinit budgie-desktop alacritty
else
 echo "Пакет budgie-desktop уже установлен."
fi

# Установка тем
echo "Установка тем..."
THEMES_DIR="/home/$username/.themes"
THEME_REPO="https://github.com/vinceliuice/Orchis-theme.git"

mkdir -p "$THEMES_DIR"
if [[ ! -d "$THEMES_DIR/Orchis-theme" ]]; then
 git clone "$THEME_REPO" "$THEMES_DIR/Orchis-theme"
 cd "$THEMES_DIR/Orchis-theme"
 bash ./install.sh -c dark -s compact --tweaks dracula --round 1
 cd - # Вернуться в исходную директорию
fi

# Выполнение дополнительных скриптов
echo "Выполнение дополнительных скриптов..."
for script in onlyoffice-install-debian.sh wifi-macbookpro.sh; do
 if [[ -f "$script" ]]; then
  source "$script"
 else
  echo "Файл $script не найден, пропускаем."
 fi
done

# Установка необходимых пакетов, если они не установлены
required_packages=("xserver-xorg-core" "xinit" "budgie-desktop" "pcmanfm" "file-roller" "rofi" "libxcb-cursor0" "libxcb-xinerama0" "alacritty")

for package in "${required_packages[@]}"; do
 if ! dpkg -l | grep -q "$package"; then
   echo "Установка пакета $package..."
   nala update
   nala install -y "$package"
 else
   echo "Пакет $package уже установлен."
 fi
done

# Очистка
echo "Очистка устаревших пакетов..."
nala autopurge -y

# Завершение
echo "Настройка завершена. Пожалуйста, перезагрузите систему."
