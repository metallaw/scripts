### simple python script to determine if today is a (german) bank holiday
### makes use of the api provided by feiertage-api.de
### May be useful for cost savings in cloud environments

import os
import json
import requests
import datetime

# determine current time
now = datetime.datetime.now()

# specify the state. Valid parameters: BW, BY, BE, BB, HB, HH, HE, MV, NI, NW, RP, SL, SN, ST, SH, TH e.g. STATE=BY
state = str(os.environ.get('STATE'))
print(state)

# Holidays to exclude since they are no bank holidays when located in Munich e.g. HOLIDAYS_EXCLUDE='["Augsburger Friedensfest", "Buß- und Bettag"]'
holidays_exclude = json.loads(os.environ['HOLIDAYS_EXCLUDE'])
print(holidays_exclude)

# Build request URL
holiday_api = "https://feiertage-api.de/api/?jahr=%d&nur_land=%s" % (now.year, state)

# Check if current day is a holiday
def holiday_match_today():
    holiday_days = []
    # Request the URL
    try:
        holiday_request = requests.get(holiday_api)
        holiday_result = json.loads(holiday_request.text)
        # Remove holidays to exclude from the dict
        for holiday in holidays_exclude:
            if holiday in holiday_result:
                del holiday_result[holiday]
    except:
        print("ERROR: API currently not available")
        return 0
    for i in holiday_result:
        holiday_days.append(holiday_result[i]['datum'])
    if now.strftime("%Y-%m-%d") in holiday_days:
        print("today is a holiday :)")
        return 1
    else:
        print("today is not a holiday :(")
        return 0

# do stuff when today is a holiday e.g. shutdown ec2 instances
if holiday_match_today():
    print("do something")
