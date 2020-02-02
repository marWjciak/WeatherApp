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

let rawURL = "https://api.openweathermap.org/data/2.5/forecast?appid=ae70447edd3ebdbaca972a829ab5765c&units=metric&lang=pl"
struct WeatherManager {
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

//                let json = JSON(weatherData)
//
//                if json != JSON.null {
//                    print(json)
//                }

                let responseModel = WeatherResponse(data: weatherData, fromLocation: fromLocation)
                guard let weatherModel = responseModel.parseJSON() else {
                    return
                }

                self.delegate?.weatherDataDidUpdate(self, weather: weatherModel)
            }
        }
    }
}
