#!/bin/bash
# METEORITES FALLS

# DevOpsEng Martino @2026
# feel free to use or transform this script

# Zkontroluj, zda byl zadán soubor
file=$1
if [ -z "$file" ]; then
    echo "Použití: $0 <soubor.json>"
    exit 1
fi

# Ověř, že soubor existuje
if [ ! -f "$file" ]; then
    echo "Soubor $file neexistuje!"
    exit 1
fi

echo "Meteorite landings"
echo "=================="

# Hlavička výpisu seznamu a správně naformátovaný jq příkaz
# Vypíše všechny záznamy hezky přehledně :)
# jq -r '.[] | "Name: \(.name) | Mass: \(.mass) | Year: \(.year)"' "$file"


# Příkaz jq '. | length' vezme hlavní pole v JSONu a vrátí počet prvků, které obsahuje.
# Výsledek se uloží do proměnné $total_count a následně se vypíše.
# Pokud bychom chtěli pouze čisté číslo bez celého skriptu přímo v terminálu:
# spustit příkaz => jq '. | length' meteorite_landings.json

# Spočítá celkový počet prvků v poli (veškerý počet záznamů v poli)
total_count=$(jq '. | length' "$file")
echo "Celkový počet záznamů: $total_count"
echo "---------------------"

# Jak se jmenuje a jaká je hmotnost nejhmotnějšího meteoritu v tomto souboru dat?
# jq -r 'max_by(.mass | tonumber) | "Nejhmotnější meteorit: \(.name) (\(.mass) g)"' "$file"

# Najde nejhmotnější meteorit
# Využívá 'tonumber', kdyby byla hmotnost v JSONu uložena jako text

# max_meteorite=$(jq -r 'max_by(.mass | tonumber) | "Jméno: \(.name) | Hmotnost: \(.mass)"' "$file")
# hlásilo chybu

# Zde funkční a opravený výstup
# Obyč výstup bez oddělovače tisíců
max_meteorite=$(jq -r 'map(select(.mass != null)) | max_by(.mass | tonumber) | "Jméno: \(.name) | Hmotnost: \(.mass)"' "$file")
# Výstup s oddělovači tisíců - příznak "g" - global
# max_meteorite=$(jq -r 'map(select(.mass != null)) | max_by(.mass | tonumber) | "Jméno: \(.name) | Hmotnost: \(.mass)" | sub("(?<=[0-9])(?=([0-9]{3})+(?![0-9]))"; "."; "g")' "$file")
echo "Nejhmotnější meteorit  -> $max_meteorite"
echo "---------------------"

# Najde nejčastější rok dopadu (bere pouze první 4 znaky z pole .year)
most_common_year=$(jq -r 'map(select(.year != null)) | group_by(.year[0:4]) | map({year: .[0].year[0:4], count: length}) | max_by(.count) | "\(.year) (počet dopadů: \(.count))"' "$file")
echo "Nejčastější rok dopadu -> $most_common_year"
echo "----------------------"

# select(.year != null): Ignoruje záznamy, které rok nemají vyplněný..year[0:4]
# Ořízne text data a vytáhne z něj pouze samotný rok (první 4 znaky).group_by(...)
# Seskupí meteority podle tohoto čtyřmístného roku.map({year: ..., count: length})
# Přetransformuje skupiny na objekty, kde máme konkrétní rok a počet meteoritů,
# které v daném roce spadly.max_by(.count)
# Vybere objekt s nejvyšším počtem.

# Spočítá průměrnou hmotnost všech meteoritů: printf("%.2f", .) => zaokrouhleno na dvě desetinná místa
# Nefunguje kvůli nižší verzi jq 1.6 => musí se upgradovat na vyšší verzi alespoň jq 1.7
# avg_mass=$(jq -r 'map(select(.mass != null) | .mass | tonumber) | (add / length) | printf("%.2f", .)' "$file" 2>/dev/null || jq -r 'map(select(.mass != null) | .mass | tonumber) | (add / length)' "$file")
avg_mass=$(jq -r 'map(select(.mass != null) | .mass | tonumber) | (add / length)' "$file")
echo "Průměrná hmotnost meteoritu -> $avg_mass"
echo "---------------------------"

# Hlavička výpisu seznamu (jen čistý výpis všech záznamů v poli)
# jq -r '.[] | "Name: \(.name) | Mass: \(.mass // "N/A") | Year: \(.year // "N/A")"' "$file"
