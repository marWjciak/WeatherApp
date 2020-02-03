//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 25/12/2019.
//  Copyright © 2019 Marcin Wójciak. All rights reserved.
//

import Foundation
import SwiftyJSON

class WeatherModel: Codable {

    let cityName: String
    var dayForecasts: [DayForecast]
    var fromLocation: Bool

    init?(_ location: JSON, fromLocation: Bool) {

        guard location["cod"].stringValue == "200" else { return nil }

        self.fromLocation = fromLocation
        self.cityName = location["city"]["name"].stringValue
        self.dayForecasts = []

        location["list"].arrayValue.forEach { (day) in
            let dayForecast = DayForecast(day)
            self.dayForecasts.append(dayForecast)
        }
    }

    init(cityName: String, dayForecasts: [DayForecast], fromLocation: Bool) {
        self.cityName = cityName
        self.dayForecasts = dayForecasts
        self.fromLocation = fromLocation
    }
}

class DayForecast: Codable {
    let conditionID: Int
    let temp: Int
    let description: String
    var date: String
    var time: String

    init(_ day: JSON){
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

        return dateFormatter.string(from: date)
    }

    var formattedTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        guard let timeFromDate: Date = dateFormatter.date(from: self.time) else {
            return self.time
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
