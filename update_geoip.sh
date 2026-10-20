#!/bin/bash

# Список стран, файлы которых лежат в /opt/zona/
COUNTRIES=("ru" "by" "ua" "nl" "fi" "kz" "other")

echo "Удаляем старые временные списки..."
ipset destroy allowed_countries_tmp 2>/dev/null

echo "Создаем временный список..."
ipset create allowed_countries_tmp hash:net maxelem 300000 2>/dev/null
ipset flush allowed_countries_tmp

# Цикл обходит каждую страну из списка COUNTRIES
for country in "${COUNTRIES[@]}"; do
    echo "Обработка локальной зоны: ${country}"
    
    # Путь к файлу, как вы и задумали
    ZONE_FILE="/opt/zona/${country}.zone"
    
    if [ -f "$ZONE_FILE" ]; then
        while read -r line; do
            # Пропускаем пустые строки и комментарии
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            # Добавляем IP-подсеть во временный ipset
            ipset add allowed_countries_tmp "$line" 2>/dev/null
        done < "$ZONE_FILE"
        
        # Переводим код страны в верхний регистр для красивого вывода (ru -> RU)
        COUNTRY_UPPER=$(echo "$country" | tr '[:lower:]' '[:upper:]')
        echo "Зона ${COUNTRY_UPPER} успешно загружена!"
    else
        echo "ВНИМАНИЕ: Файл ${ZONE_FILE} не найден, пропускаем эту страну."
    fi
done

# Добавляем системные исключения, чтобы сервер не заблокировал сам себя
ipset add allowed_countries_tmp 127.0.0.1 2>/dev/null

# Если основного списка еще нет, создаем его
ipset create allowed_countries hash:net maxelem 300000 2>/dev/null

echo "Переключаем списки..."
ipset swap allowed_countries_tmp allowed_countries
ipset destroy allowed_countries_tmp

echo "Списки гео-зон успешно обновлены из локальных файлов!"
