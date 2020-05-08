//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 25/12/2019.
//  Copyright © 2019 Marcin Wójciak. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

protocol WeatherManagerDelegate: class {
    func weatherDataDidUpdate(_: WeatherManager, weather: WeatherModel)
    func weatherDataDidRemove(_: WeatherManager, location: String)
}

extension WeatherManagerDelegate {
    func weatherDataDidRemove(_: WeatherManager, location: String) {
        // this is an empty implementation to allow method to be optional
    }
}

let rawURL = "https://api.openweathermap.org/data/2.5/forecast?appid=ae70447edd3ebdbaca972a829ab5765c&units=metric" //&lang=pl"
class WeatherManager {
    var delegates = MulticastDelegate<WeatherManagerDelegate>()

    // change to send locations in array and send async request for all locations
    func fetchWeatherData(for city: String) {
        let cityNameForRequest = prepareNameToRequest(for: city)
        
        let URL = rawURL + "&q=\(cityNameForRequest)"
        
        performWeatherRequest(with: URL, fromLocation: false, latitude: 0, longitude: 0)
    }
    
    func fetchWeatherData(latitude: String, longitude: String, fromLocation: Bool) {
        let urlString = "\(rawURL)&lat=\(latitude)&lon=\(longitude)"
        if let lat = Double(latitude), let lon = Double(longitude) {
            performWeatherRequest(with: urlString, fromLocation: fromLocation, latitude: lat, longitude: lon)
        }
    }

    func removeWeatherData(for data: String) {
        delegates.invoke(invocation: { delegate in delegate.weatherDataDidRemove(self, location: data) })
    }
    
    private func prepareNameToRequest(for cityName: String) -> String {
        let removedSpaces = cityName.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "%20")
        let removedDiacritics = removedSpaces.lowercased().folding(options: .diacriticInsensitive, locale: .current).replacingOccurrences(of: "ł", with: "l")
        
        return removedDiacritics
    }
    
    private func performWeatherRequest(with url: String, fromLocation: Bool, latitude: Double, longitude: Double) {
        Alamofire.request(url).response { responseData in
            
            if let weatherData = responseData.data {
                let responseModel = WeatherResponse(data: weatherData, fromLocation: fromLocation)
                guard let weatherModel = responseModel.parseJSON() else {
                    return
                }

                if latitude != 0 && longitude != 0 {
                    weatherModel.latitude = latitude
                    weatherModel.longitude = longitude
                }

                self.delegates.invoke(invocation: { delegate in delegate.weatherDataDidUpdate(self, weather: weatherModel) })
            }
        }
    }
}
