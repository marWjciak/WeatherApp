//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 25/12/2019.
//  Copyright © 2019 Marcin Wójciak. All rights reserved.
//

import Foundation

struct WeatherModel: Codable {
    let cityName: String
    let dayForecast: [DayForecast]
    var fromLocation: Bool
    
    struct DayForecast: Codable {
        let conditionID: Int
        let temp: Int
        let description: String
        var _date: String
        var _time: String

        var date: String {
            set {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"

                if let date: Date = dateFormatter.date(from: self._date) {
                    dateFormatter.dateFormat = "E, d MMM"

                    _date = dateFormatter.string(from: date)
                }
            }

            get {
                return _date
            }
        }

        var time: String {
            set {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm:ss"

                if let timeFromDate: Date = dateFormatter.date(from: self._time) {
                    dateFormatter.dateFormat = "HH:mm"

                    _time = dateFormatter.string(from: timeFromDate)
                }
            }

            get {
                return _time
            }

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
}
