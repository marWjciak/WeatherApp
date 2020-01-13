//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 25/12/2019.
//  Copyright © 2019 Marcin Wójciak. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation

protocol WeatherManagerDelegate {
    func weatherDataDidUpdate(_: WeatherManager, weather: WeatherModel)
}

struct WeatherManager {
    let rawURL = "https://api.openweathermap.org/data/2.5/forecast?appid=ae70447edd3ebdbaca972a829ab5765c&units=metric"
    var delegate: WeatherManagerDelegate?
    
    func fetchWeatherData(for city: String) {
        let URL = rawURL + "&q=\(city)"
        
        performWeatherRequest(with: URL)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(rawURL)&lat=\(latitude)&lon=\(longitude)"
        performWeatherRequest(with: urlString)
    }
    
    func performWeatherRequest(with url: String) {
        Alamofire.request(url).response { (responseData) in
            if let weatherData = responseData.data {
                self.delegate?.weatherDataDidUpdate(self, weather: self.parseJSON(with: weatherData))
            }
        }
    }
    
    func parseJSON(with weatherData: Data) -> WeatherModel {
        let data = JSON(weatherData)
        
        let cityNameValue = data["city"]["name"].stringValue
        
        var dayForecast: [WeatherModel.DayForecast] = []
        data["list"].arrayValue.forEach { (day) in
            let temp = day["main"]["temp"].intValue
            let condId = day["weather"][0]["id"].intValue
            let description = day["weather"][0]["description"].stringValue
            let date = day["dt_txt"].stringValue
            
            let reformatedDate = reformatDate(with: date)
            
            dayForecast.append(WeatherModel.DayForecast(conditionID: condId, temp: temp, description: description, date: reformatedDate))
        }
        
        return WeatherModel(cityName: cityNameValue, dayForecast: dayForecast)
    }
    
    func reformatDate(with value: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM"

        let date: Date? = dateFormatterGet.date(from: value)
        
        return dateFormatter.string(from: date!)
    }
}
