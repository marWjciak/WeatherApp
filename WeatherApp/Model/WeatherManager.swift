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

protocol WeatherManagerDelegate {
    func weatherDataDidUpdate(_: WeatherManager, weather: WeatherModel)
    func weatherDataDidFailUpdate(_: WeatherManager, fromLocation: Bool)
}

struct WeatherManager {
    let rawURL = "https://api.openweathermap.org/data/2.5/forecast?appid=ae70447edd3ebdbaca972a829ab5765c&units=metric"
    var delegate: WeatherManagerDelegate?
    
    func fetchWeatherData(for city: String) {
        let URL = rawURL + "&q=\(city)"
        
        performWeatherRequest(with: URL, fromLocation: false)
    }
    
    func fetchWeather(latitude: String, longitude: String) {
        let urlString = "\(rawURL)&lat=\(latitude)&lon=\(longitude)"
        performWeatherRequest(with: urlString, fromLocation: true)
    }
    
    func performWeatherRequest(with url: String, fromLocation: Bool) {
        Alamofire.request(url).response { (responseData) in
            if let weatherData = responseData.data {
                guard var weatherModel = self.parseJSON(with: weatherData) else {
                    
                    self.delegate?.weatherDataDidFailUpdate(self, fromLocation: fromLocation)
                    return
                }
                
                weatherModel.fromLocation = fromLocation
                self.delegate?.weatherDataDidUpdate(self, weather: weatherModel)
            }
        }
    }
    
    func parseJSON(with weatherData: Data) -> WeatherModel? {
        let data = JSON(weatherData)
        
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
            let date = reformatDate(in: String(dateTime[0]))
            let time = reformatTime(in: String(dateTime[1]))
            
            dayForecast.append(WeatherModel.DayForecast(conditionID: condId, temp: temp, description: description, date: date, time: time))
        }
        
        return WeatherModel(cityName: cityNameValue, dayForecast: dayForecast, fromLocation: false)
    }
    
    func reformatDate(in value: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM"

        let date: Date? = dateFormatterGet.date(from: value)
        
        return dateFormatter.string(from: date!)
    }
    
    func reformatTime(in value: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "HH:mm:ss"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        let timeFromDate: Date? = dateFormatterGet.date(from: value)
        
        return dateFormatter.string(from: timeFromDate!)
    }
}
