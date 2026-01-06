#!/bin/bash
#
# system-cleanup.sh
# Debian / DietPi maintenance & cleanup script
#
# Author: Janne Heinikangas
# Repo: https://github.com/KAYTTAJA/system-cleanup
# License: MIT / Free use

set -e

# --- ROOT CHECK ---
if [[ "$EUID" -ne 0 ]]; then
  echo "❌ Tämä skripti täytyy ajaa rootina (sudo)."
  exit 1
fi

echo "🧹 Järjestelmän huolto alkaa..."
echo "--------------------------------------"

# --- MEMORY BEFORE ---
echo "📊 Muistitilanne ennen:"
free -h
echo

# --- APT HOUSEKEEPING ---
echo "📦 Poistetaan tarpeettomat paketit..."
apt-get autoremove -y
apt-get autoremove --purge -y

echo "🧼 Tyhjennetään APT cache..."
apt-get clean
apt-get autoclean

# --- JOURNAL CLEANUP ---
echo "📜 Siivotaan systemd journal (2 viikkoa)..."
journalctl --vacuum-time=2weeks

# --- TEMP FILES ---
echo "🗑️ Tyhjennetään /tmp ja /var/tmp..."
rm -rf /tmp/* /var/tmp/*

# --- USER CACHES ---
echo "🗂️ Tyhjennetään käyttäjäcachet..."
find /home -type d -name ".cache" -exec rm -rf {}/* \; 2>/dev/null || true

# --- RAM CACHE FLUSH ---
echo "🧠 Tyhjennetään RAM cache (drop_caches)..."
sync
echo 3 > /proc/sys/vm/drop_caches

# --- OPTIONAL: SWAP TRIM ---
if swapon --summary | grep -q "^"; then
  echo "💾 Swap käytössä – kierrätetään swap..."
  swapoff -a
  swapon -a
fi

# --- OPTIONAL: LOG ROTATE ---
echo "🔄 Ajetaan logrotate..."
logrotate -f /etc/logrotate.conf || true

# --- MEMORY AFTER ---
echo
echo "📊 Muistitilanne jälkeen:"
free -h

echo
echo "✅ Järjestelmän huolto valmis!"
