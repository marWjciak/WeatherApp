//
//  ResponseData.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 28/01/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import Foundation
import SwiftyJSON


struct WeatherResponse {
    let data: Data

    func parseJSON() -> WeatherModel? {
        let data = JSON(self.data)

        if data["cod"].stringValue != "200" {
            return nil
        }

        let cityNameValue = data["city"]["name"].stringValue

        var dayForecast: [WeatherModel.DayForecast] = []

        data["list"].arrayValue.forEach { (day) in
            let temp = day["main"]["temp"].intValue
            let condId = day["weather"][0]["id"].intValue
            let description = day["weather"][0]["description"].stringValue
            let dateTime = day["dt_txt"].stringValue.split(separator: " ")
            let date = String(dateTime[0])
            let time = String(dateTime[1])

            dayForecast.append(WeatherModel.DayForecast(conditionID: condId, temp: temp, description: description, date: date, time: time))
        }

        return WeatherModel(cityName: cityNameValue, dayForecast: dayForecast, fromLocation: false)
    }
}
