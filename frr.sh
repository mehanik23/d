#!/bin/bash

# Скрипт для настройки FRR (HQ-RTR) с подтверждением использования интерфейса tun/gre
# Чёткий скрипт для чётких пацанчиков 🐧✨

clear
echo "🚀 Начинаем настройку FRR (HQ-RTR). Готовься к магии! 🌟"

# Обновление системы и установка FRR
echo "🔄 Обновляем пакеты и устанавливаем FRR..."
sudo apt update -y && sudo apt install frr -y

# Настройка демонов FRR
echo "🔧 Включаем ospfd в конфигурацию демонов..."
sudo sh -c "echo 'ospfd=yes' >> /etc/frr/daemons"

# Включение и перезапуск службы FRR
echo "🔄 Включаем и перезапускаем FRR..."
sudo systemctl enable --now frr
sudo systemctl restart frr

# Интерактивная настройка через vtysh
echo "🔧 Запускаем настройку через vtysh..."
sudo vtysh <<EOF
configure terminal

router ospf
 passive-interface default

# Сети для OSPF
 network 192.168.100.0/26 area 0
 network 192.168.100.64/28 area 0
 network 10.10.12.1/30 area 0

# Аутентификация для area 0
 area 0 authentication

# Точка останова для tun/gre
echo "⚠️ Вы хотите настроить интерфейс tun/gre? (y/n)"
read confirm_tun

if [ "\$confirm_tun" = "y" ]; then
 interface tun1(gre)
  no ip ospf network broadcast
  no ip ospf passive
  ip ospf authentication
  ip ospf authentication-key password
 fi

write
exit
EOF

# Перезапуск FRR после изменений
echo "🔄 Перезапускаем FRR для применения изменений..."
sudo systemctl restart frr

# Показ текущей конфигурации
echo "📋 Текущая конфигурация:"
sudo vtysh -c "show running-config"

echo "🎉 Готово! Теперь твой FRR настроен как часы. Поцелуй в лобик тебе обеспечен! 💋"
