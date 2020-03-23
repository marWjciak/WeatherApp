//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 25/12/2019.
//  Copyright © 2019 Marcin Wójciak. All rights reserved.
//

import Foundation
import SwiftyJSON

/*
 {
 "cod": "200",
 "message": 0,
 "cnt": 40,
 "list": [
   {
     "dt": 1580882400,
     "main": {
       "temp": 1.85,
       "feels_like": -3.43,
       "temp_min": 1.56,
       "temp_max": 1.85,
       "pressure": 1010,
       "sea_level": 1010,
       "grnd_level": 978,
       "humidity": 96,
       "temp_kf": 0.29
     },
     "weather": [
       {
         "id": 600,
         "main": "Snow",
         "description": "słabe opady śniegu",
         "icon": "13n"
       }
     ],
     "clouds": {
       "all": 100
     },
     "wind": {
       "speed": 4.99,
       "deg": 354
     },
     "snow": {
       "3h": 0.56
     },
     "sys": {
       "pod": "n"
     },
     "dt_txt": "2020-02-05 06:00:00"
   },
    .
    .
    .
   ],
   "city": {
     "id": 3094802,
     "name": "Kraków",
     "coord": {
       "lat": 50.0833,
       "lon": 19.9167
     },
     "country": "PL",
     "population": 755050,
     "timezone": 3600,
     "sunrise": 1580882957,
     "sunset": 1580917156
   }
 }
 */

class WeatherModel: Codable {
    let cityName: String
    var latitude: Double
    var longitude: Double
    var dayForecasts: [DayForecast]
    var fromLocation: Bool

    init?(_ location: JSON, fromLocation: Bool) {
        guard location["cod"].stringValue == "200" else { return nil }

        self.fromLocation = fromLocation
        self.cityName = location["city"]["name"].stringValue
        self.latitude = location["city"]["coord"]["lat"].doubleValue
        self.longitude = location["city"]["coord"]["lon"].doubleValue
        self.dayForecasts = []

        location["list"].arrayValue.forEach { day in
            let dayForecast = DayForecast(day)
            self.dayForecasts.append(dayForecast)
        }
    }

    init(cityName: String, dayForecasts: [DayForecast], fromLocation: Bool) {
        self.cityName = cityName
        self.dayForecasts = dayForecasts
        self.fromLocation = fromLocation
        self.latitude = 0
        self.longitude = 0
    }
}

class DayForecast: Codable {
    let conditionID: Int
    let temp: Int
    let description: String
    var date: String
    var time: String

    init(_ day: JSON) {
        self.temp = day["main"]["temp"].intValue
        self.conditionID = day["weather"][0]["id"].intValue
        self.description = day["weather"][0]["description"].stringValue
        let dateTime = day["dt_txt"].stringValue.split(separator: " ")
        self.date = String(dateTime[0])
        self.time = String(dateTime[1])
    }

    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date: Date = dateFormatter.date(from: self.date) else {
            return self.date
        }

        dateFormatter.dateFormat = "E, d MMM"
//        dateFormatter.locale = NSLocale(localeIdentifier: "pl_PL") as Locale

        return dateFormatter.string(from: date)
    }

    var formattedTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        guard let timeFromDate: Date = dateFormatter.date(from: time) else {
            return time
        }

        dateFormatter.dateFormat = "HH:mm"

        return dateFormatter.string(from: timeFromDate)
    }

    var icon: String {
        switch conditionID {
            case 200..<232:
                return "cloud.bolt"
            case 300..<321:
                return "cloud.drizzle"
            case 500, 501, 520, 521:
                return "cloud.rain"
            case 511:
                return "snow"
            case 502, 503, 504, 522, 531:
                return "cloud.heavyrain"
            case 600..<622:
                return "cloud.snow"
            case 700..<800:
                return "cloud.fog"
            case 800:
                return "sun.max"
            case 801:
                return "cloud.sun"
            case 802...804:
                return "cloud"
            default:
                return "icloud.slash"
        }
    }
}
