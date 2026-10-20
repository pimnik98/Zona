#!/bin/bash

# Проверяем, передан ли IP-адрес в качестве аргумента
if [ -z "$1" ]; then
    echo -e "\e[31m❌ Ошибка:\e[0m Укажите IP-адрес для проверки."
    echo -e "Пример использования: \e[36mcheckip 8.8.8.8\e[0m"
    exit 1
fi

IP="$1"

# Проверяем, существует ли вообще список в памяти
if ! sudo ipset list allowed_countries &>/dev/null; then
    echo -e "\e[31mКРИТИЧЕСКАЯ ОШИБКА:\e[0m Список 'allowed_countries' не найден в ipset!"
    exit 2
fi

# Выполняем проверку IP по подсетям
if sudo ipset test allowed_countries "$IP" &>/dev/null; then
    echo -e "\e[32m✅ ДОСТУП РАЗРЕШЕН\e[0m ($IP присутствует в подсетях белого списка)"
    exit 0
else
    echo -e "\e[31m❌ ДОСТУП ЗАБЛОКИРОВАН\e[0m ($IP отсутствует в базе, сервер для него offline)"
    exit 1
fi
