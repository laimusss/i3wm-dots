#!/bin/bash

set -e # Завершить скрипт при любой ошибке

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
 echo " exec startx" >> "$profile_file"
 echo "fi" >> "$profile_file"
fi

# Создание файла ~/.xinitrc для запуска i3
xinitrc_file="/home/$username/.xinitrc"

if [[ ! -f "$xinitrc_file" ]]; then
 echo "$xinitrc_file не существует, создаю новый файл."
 touch "$xinitrc_file"
fi

if ! grep -q "i3" "$xinitrc_file"; then
 echo "exec i3" > "$xinitrc_file"
fi

# Установка необходимых пакетов
echo "Установка необходимых пакетов..."
apt update
apt install -y \
 git curl \
 xserver-xorg-core xinit \
 i3 \
 lxappearance \
 thunar thunar-archive-plugin \
 dialog acpi acpid gvfs-backends arandr \
 alacritty \
 pulseaudio pavucontrol \
 bluez \
 feh \
 network-manager xfce4-power-manager rofi dunst polybar picom unzip playerctl scrot xdg-user-dirs-gtk \
 libxcb-cursor0 libxcb-xinerama0 \
 curl ffmpeg mpv micro nala moc \
 fonts-font-awesome fonts-firacode \
 slim

# Включение системных служб
echo "Включение необходимых системных служб..."
systemctl enable acpid
systemctl enable bluetooth

# Обновление пользовательских директорий
echo "Обновление пользовательских директорий..."
xdg-user-dirs-update

# Выполнение дополнительных скриптов
echo "Выполнение дополнительных скриптов..."
for script in onlyoffice-install-debian.sh wifi-macbookpro.sh zen-browser-install.sh; do
 if [[ -f "$script" ]]; then
  source "$script"
 else
  echo "Файл $script не найден, пропускаем."
 fi
done

# Установка тем
echo "Установка тем..."
THEMES_DIR="/home/$username/.themes"
THEME_REPO="https://github.com/vinceliuice/Orchis-theme.git"

mkdir -p "$THEMES_DIR"
if [[ ! -d "$THEMES_DIR/Orchis-theme" ]]; then
 git clone --depth=1 "$THEME_REPO" "$THEMES_DIR/Orchis-theme"
 cd "$THEMES_DIR/Orchis-theme"
 sudo bash ./install.sh -c dark -s compact --tweaks dracula --round 1
 cd - # Вернуться в исходную директорию
fi

# Копирование конфигурационных файлов
echo "Копирование конфигурационных файлов..."
CONFIG_DIR="$HOME/i3wm-dots"
for config_item in 90-touchpad.conf moc .xinitrc .Xresources; do
 if [[ -e "$CONFIG_DIR/$config_item" ]]; then
  sudo cp -f "$CONFIG_DIR/$config_item" "/etc/X11/xorg.conf.d/" || cp -f "$CONFIG_DIR/$config_item" ~
 fi
done

# Копирование директорий конфигурации
for dir in moc alacritty dunst i3 polybar rofi; do
 if [[ -d "$CONFIG_DIR/$dir" ]]; then
  cp -rp "$CONFIG_DIR/$dir" ~/.config/
 fi
done

# Очистка
echo "Очистка устаревших пакетов..."
sudo apt autoremove -y

# Завершение
echo "Настройка завершена! Пожалуйста, перезагрузите компьютер!"
