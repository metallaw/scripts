### simple python script to determine if today is a (german) bank holiday
### makes use of the api provided by feiertage-api.de
### May be useful for cost savings in cloud environments

import json
import requests
import datetime

# determine current time
now = datetime.datetime.now()

# specify the state. Valid parameters: BW, BY, BE, BB, HB, HH, HE, MV, NI, NW, RP, SL, SN, ST, SH, TH
state = "BY"

# Holidays to exclude since they are no bank holidays when located in Munich
holidays_exclude = ("Augsburger Friedensfest", "Buß- und Bettag")

# Build request URL
holiday_api = "https://feiertage-api.de/api/?jahr=%d&nur_land=%s" % (now.year, state)

# Check if current day is a holiday
def holiday_match_today():
    holiday_days = []
    # Request the URL
    try:
        holiday_request = requests.get(holiday_api)
        holiday_check = json.loads(holiday_request.text)
        # Remove holidays to exclude from the dict
        for holiday in holidays_exclude:
            if holiday in holiday_check:
                del holiday_check[holiday]
    except:
        print("ERROR: API currently not available")
        return 0
    for i in holiday_check:
        holiday_days.append(holiday_check[i]['datum'])
    if now.date() in holiday_days:
        print("today is a holiday :)")
        return 1
    else:
        print("today is not a holiday :(")
        return 0

holiday_match_today()
