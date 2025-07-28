#!/usr/bin/env python

import json
import requests
from datetime import datetime

# Зимние иконки погоды
WEATHER_CODES = {
    '113': '☀️',
    '116': '⛅️',
    '119': '☁️',
    '122': '☁️',
    '143': '🌫',
    '176': '🌦',
    '179': '🌧',
    '182': '🌧',
    '185': '🌧',
    '200': '⛈',
    '227': '🌨',
    '230': '❄️',
    '248': '🌫',
    '260': '🌫',
    '263': '🌦',
    '266': '🌦',
    '281': '🌧',
    '284': '🌧',
    '293': '🌦',
    '296': '🌦',
    '299': '🌧',
    '302': '🌧',
    '305': '🌧',
    '308': '🌧',
    '311': '🌧',
    '314': '🌧',
    '317': '🌧',
    '320': '🌨',
    '323': '🌨',
    '326': '🌨',
    '329': '❄️',
    '332': '❄️',
    '335': '❄️',
    '338': '❄️',
    '350': '🌧',
    '353': '🌦',
    '356': '🌧',
    '359': '🌧',
    '362': '🌧',
    '365': '🌧',
    '368': '🌨',
    '371': '❄️',
    '374': '🌧',
    '377': '🌧',
    '386': '⛈',
    '389': '🌩',
    '392': '⛈',
    '395': '❄️'
}

# Японские названия погодных условий
WEATHER_TRANSLATIONS = {
    "Fog": "霧",
    "Frost": "霜",
    "Overcast": "曇り",
    "Rain": "雨",
    "Snow": "雪",
    "Sunshine": "晴れ",
    "Thunder": "雷",
    "Wind": "風"
}

data = {}

try:
    weather = requests.get("https://wttr.in/?format=j1").json()
    
    def format_time(time):
        return time.replace("00", "").zfill(2)
    
    def format_temp(temp):
        return (temp+"°").ljust(3)
    
    def format_chances(hour):
        chances = {
            "chanceoffog": "Fog",
            "chanceoffrost": "Frost",
            "chanceofovercast": "Overcast",
            "chanceofrain": "Rain",
            "chanceofsnow": "Snow",
            "chanceofsunshine": "Sunshine",
            "chanceofthunder": "Thunder",
            "chanceofwindy": "Wind"
        }
        
        conditions = []
        for event in chances.keys():
            if int(hour[event]) > 0:
                jp_condition = WEATHER_TRANSLATIONS.get(chances[event], chances[event])
                conditions.append(f"{jp_condition} {hour[event]}%")
        return ", ".join(conditions)
    
    # Основной текст
    data['text'] = WEATHER_CODES[weather['current_condition'][0]['weatherCode']] + \
        " "+weather['current_condition'][0]['FeelsLikeC']+"°"
    
    # Подсказка
    data['tooltip'] = f"<b>天気: {weather['current_condition'][0]['weatherDesc'][0]['value']} {weather['current_condition'][0]['temp_C']}°C</b>\n"
    data['tooltip'] += f"体感温度: {weather['current_condition'][0]['FeelsLikeC']}°C\n"
    data['tooltip'] += f"風速: {weather['current_condition'][0]['windspeedKmph']}km/h\n"
    data['tooltip'] += f"湿度: {weather['current_condition'][0]['humidity']}%\n"
    
    for i, day in enumerate(weather['weather']):
        data['tooltip'] += f"\n<b>"
        if i == 0:
            data['tooltip'] += "今日, "
        if i == 1:
            data['tooltip'] += "明日, "
        data['tooltip'] += f"{day['date']}</b>\n"
        data['tooltip'] += f"最高 {day['maxtempC']}° 最低 {day['mintempC']}° "
        data['tooltip'] += f"日出 {day['astronomy'][0]['sunrise']} 日没 {day['astronomy'][0]['sunset']}\n"
        
        for hour in day['hourly']:
            if i == 0:
                if int(format_time(hour['time'])) < datetime.now().hour-2:
                    continue
            data['tooltip'] += f"{format_time(hour['time'])}時 {WEATHER_CODES[hour['weatherCode']]} {format_temp(hour['FeelsLikeC'])} {hour['weatherDesc'][0]['value']}, {format_chances(hour)}\n"

except Exception as e:
    data['text'] = "❄️ N/A"
    data['tooltip'] = "天気情報を取得できません"

print(json.dumps(data))