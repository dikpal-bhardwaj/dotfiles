#!/usr/bin/env python3

import json
import sys
import urllib.request


def get_icon(wmo_code):
    # WMO Weather interpretation codes (WW)
    # Used by OpenMeteo
    weather_icons = {
        0: "",  # Clear sky
        1: "🌤",  # Mainly clear
        2: "⛅",  # Partly cloudy
        3: "☁️",  # Overcast
        45: "🌫",  # Fog
        48: "🌫",  # Depositing rime fog
        51: "🌦",  # Drizzle: Light
        53: "🌦",  # Drizzle: Moderate
        55: "🌦",  # Drizzle: Dense intensity
        56: "🌧",  # Freezing Drizzle: Light
        57: "🌧",  # Freezing Drizzle: Dense
        61: "🌧",  # Rain: Slight
        63: "🌧",  # Rain: Moderate
        65: "🌧",  # Rain: Heavy
        66: "🌧",  # Freezing Rain: Light
        67: "🌧",  # Freezing Rain: Heavy
        71: "🌨",  # Snow fall: Slight
        73: "❄️",  # Snow fall: Moderate
        75: "❄️",  # Snow fall: Heavy
        77: "🌨",  # Snow grains
        80: "🌦",  # Rain showers: Slight
        81: "🌧",  # Rain showers: Moderate
        82: "🌧",  # Rain showers: Violent
        85: "🌨",  # Snow showers: Slight
        86: "❄️",  # Snow showers: Heavy
        95: "⛈",  # Thunderstorm: Slight or moderate
        96: "🌩",  # Thunderstorm with slight hail
        99: "🌩",  # Thunderstorm with heavy hail
    }
    return weather_icons.get(wmo_code, "")


def get_location():
    # Get location based on IP
    try:
        with urllib.request.urlopen("http://ip-api.com/json/") as response:
            return json.loads(response.read().decode())
    except:
        return None


def get_weather():
    try:
        # 1. Get Location
        loc_data = get_location()
        if not loc_data:
            raise Exception("Could not fetch location")

        lat = loc_data["lat"]
        lon = loc_data["lon"]
        city = loc_data["city"]

        # 2. Get Weather from OpenMeteo (No API key required)
        weather_url = f"https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current_weather=true&temperature_unit=celsius"

        with urllib.request.urlopen(weather_url) as response:
            weather_data = json.loads(response.read().decode())

        current = weather_data["current_weather"]
        temp_c = int(current["temperature"])
        wmo_code = current["weathercode"]
        wind_speed = current["windspeed"]

        # Formatting
        icon = get_icon(wmo_code)
        temp_formatted = f"+{temp_c}" if temp_c > 0 else f"{temp_c}"

        text_output = f"{icon} {temp_formatted}°C"
        tooltip = f"<b>{city}</b>\nTemperature: {temp_c}°C\nWind: {wind_speed} km/h\n(Source: Open-Meteo)"

        print(json.dumps({"text": text_output, "tooltip": tooltip, "class": "weather"}))

    except Exception as e:
        sys.stderr.write(f"Error: {e}\n")
        print(json.dumps({"text": " N/A", "tooltip": "Offline"}))


if __name__ == "__main__":
    get_weather()
