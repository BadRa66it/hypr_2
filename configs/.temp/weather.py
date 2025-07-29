#!/usr/bin/env python3

import json
import requests

# Иконки погоды
WEATHER_CODES = {
    '113': '☀️', '116': '⛅', '119': '☁️', '122': '☁️', '143': '🌫',
    '176': '🌦', '179': '🌧', '182': '🌧', '185': '🌧', '200': '⛈',
    '227': '🌨', '230': '❄️', '248': '🌫', '260': '🌫', '263': '🌦',
    '266': '🌦', '281': '🌧', '284': '🌧', '293': '🌦', '296': '🌦',
    '299': '🌧', '302': '🌧', '305': '🌧', '308': '🌧', '311': '🌧',
    '314': '🌧', '317': '🌧', '320': '🌨', '323': '🌨', '326': '🌨',
    '329': '❄️', '332': '❄️', '335': '❄️', '338': '❄️', '350': '🌧',
    '353': '🌦', '356': '🌧', '359': '🌧', '362': '🌧', '365': '🌧',
    '368': '🌨', '371': '❄️', '374': '🌧', '377': '🌧', '386': '⛈',
    '389': '🌩', '392': '⛈', '395': '❄️'
}

data = {}

try:
    weather = requests.get("https://wttr.in/?format=j1", timeout=5).json()
    
    current = weather['current_condition'][0]
    
    # Основной текст (иконка + температура)
    icon = WEATHER_CODES.get(current['weatherCode'], '❄️')
    temp = current['FeelsLikeC']
    data['text'] = f"{icon} {temp}°"
    
    # Tooltip только на 2 дня
    tooltip = f"<b>現在の天気</b>\n"
    tooltip += f"🌡️ {current['temp_C']}°C (体感 {current['FeelsLikeC']}°C)\n"
    tooltip += f"💨 {current['windspeedKmph']}km/h\n"
    tooltip += f"💧 {current['humidity']}%\n\n"
    
    # Прогноз на 2 дня
    for i in range(2):
        day = weather['weather'][i]
        day_name = "今日" if i == 0 else "明日"
        
        tooltip += f"<b>{day_name} ({day['date']})</b>\n"
        tooltip += f"🔼 {day['maxtempC']}° 🔽 {day['mintempC']}°\n"
        
        # Только ключевые часы для каждого дня
        key_hours = ['06', '12', '18'] if i == 0 else ['06', '12', '18']
        for hour_data in day['hourly']:
            hour = hour_data['time'].zfill(4)[:2]
            if hour in key_hours:
                hour_icon = WEATHER_CODES.get(hour_data['weatherCode'], '❄️')
                tooltip += f"{hour}時 {hour_icon} {hour_data['FeelsLikeC']}°\n"
        
        tooltip += "\n" if i == 0 else ""
    
    data['tooltip'] = tooltip.strip()

except Exception as e:
    data['text'] = "❄️ N/A"
    data['tooltip'] = f"天気情報エラー: {str(e)}"

print(json.dumps(data, ensure_ascii=False))