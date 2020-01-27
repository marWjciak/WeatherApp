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
}

struct WeatherManager {
    let rawURL = "https://api.openweathermap.org/data/2.5/forecast?appid=ae70447edd3ebdbaca972a829ab5765c&units=metric"
    var delegate: WeatherManagerDelegate?
    
    func fetchWeatherData(for city: String) {
        
        let cityNameForRequest = prepareNameToRequest(for: city)
        
        let URL = rawURL + "&q=\(cityNameForRequest)"
        
        performWeatherRequest(with: URL, fromLocation: false)
    }
    
    func fetchWeatherData(latitude: String, longitude: String) {
        let urlString = "\(rawURL)&lat=\(latitude)&lon=\(longitude)"
        performWeatherRequest(with: urlString, fromLocation: true)
    }
    
    private func prepareNameToRequest(for cityName: String) -> String {
        
        let removedSpaces = cityName.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "%20")
        let removedDiacritics = removedSpaces.lowercased().folding(options: .diacriticInsensitive, locale: .current).replacingOccurrences(of: "ł", with: "l")
        
        return removedDiacritics
    }
    
    func performWeatherRequest(with url: String, fromLocation: Bool) {
        Alamofire.request(url).response { (responseData) in
            if let weatherData = responseData.data {
                guard var weatherModel = self.parseJSON(with: weatherData) else {
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
            let date = String(dateTime[0])
            let time = String(dateTime[1])
            
            dayForecast.append(WeatherModel.DayForecast(conditionID: condId, temp: temp, description: description, date: date, time: time))
        }
        
        return WeatherModel(cityName: cityNameValue, dayForecast: dayForecast, fromLocation: false)
    }
    
//    func reformatDate(in value: String) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        let date: Date? = dateFormatter.date(from: value)
//
//        dateFormatter.dateFormat = "E, d MMM"
//        
//        return dateFormatter.string(from: date!)
//    }
    
//    func reformatTime(in value: String) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "HH:mm:ss"
//        let timeFromDate: Date? = dateFormatter.date(from: value)
//
//        dateFormatter.dateFormat = "HH:mm"
//        
//        return dateFormatter.string(from: timeFromDate!)
//    }
}
