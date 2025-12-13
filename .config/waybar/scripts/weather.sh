#!/usr/bin/env bash

LAT="33.803577" 
LON="-84.416846" 

WEATHER_DATA=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current_weather=true&daily=sunrise,sunset&timezone=auto&temperature_unit=fahrenheit")

TEMP=$(echo "$WEATHER_DATA" | jq -r '.current_weather.temperature')
WEATHER_CODE=$(echo "$WEATHER_DATA" | jq -r '.current_weather.weathercode')
SUNRISE=$(echo "$WEATHER_DATA" | jq -r '.daily.sunrise[0]')
SUNSET=$(echo "$WEATHER_DATA" | jq -r '.daily.sunset[0]')
CURRENT_TIME=$(date +"%Y-%m-%dT%H:%M")

if [[ "$CURRENT_TIME" > "$SUNRISE" && "$CURRENT_TIME" < "$SUNSET" ]]; then
  DAY_NIGHT="day"
else
  DAY_NIGHT="night"
fi

case "$WEATHER_CODE" in
  0)
    if [[ "$DAY_NIGHT" == "day" ]]; then
      WEATHER_ICON="<span color='#e2912d'></span>" # Sun
    else
      WEATHER_ICON="<span color='#797979'></span>"  # Moon
    fi
    ;;
  1|2|3) 
    if [[ "$DAY_NIGHT" == "day" ]]; then
      WEATHER_ICON="" # Sun cloudy
    else
      WEATHER_ICON=""  # Moon cloudy
    fi
    ;;
  45|48) WEATHER_ICON="<span color='#696577'></span>" ;;  # Fog
  51|53|55|56|57) WEATHER_ICON="<span color='#166afc'></span>" ;;  # Drizzle
  61|63|65|66|67) WEATHER_ICON="<span color='#166afc'></span>" ;;  # Rain
  71|73|75|77) WEATHER_ICON="<span color='#91f7ee'></span>" ;;  # Snow
  80|81|82) WEATHER_ICON="<span color='#166afc'></span>" ;;  # Rain showers
  85|86) WEATHER_ICON="<span color='#91f7ee'></span>" ;;  # Snow showers
  95|96|99) WEATHER_ICON="<span color='#e6ed28'></span>" ;;  # Thunderstorm
  *) WEATHER_ICON="<span color='#797979'></span>" ;;  # Default (Cloudy)
esac

# Output formatted weather
echo "| $TEMP°F $WEATHER_ICON  |"