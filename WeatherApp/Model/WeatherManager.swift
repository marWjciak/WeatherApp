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
    func weatherDataDidRemove(_: WeatherManager, location _: String) {
        // this is an empty implementation to allow method to be optional
    }
}

let rawURL = "https://api.openweathermap.org/data/2.5/forecast?appid=ae70447edd3ebdbaca972a829ab5765c&units=metric" // &lang=pl"
class WeatherManager {
    var delegates = MulticastDelegate<WeatherManagerDelegate>()

    func fetchWeatherData(for cities: [String]) {
        let urls = prepareUrls(for: cities)

        performWeatherRequest(with: urls, fromLocation: false)
    }

    private func prepareUrls(for names: [String]) -> [String] {
        var urls: [String] = []

        names.forEach { name in
            let cityNameForRequest = name.prepareNameToRequest()
            let url = rawURL + "&q=\(cityNameForRequest)"

            urls.append(url)
        }
        return urls
    }

    func fetchWeatherData(latitude: String, longitude: String, fromLocation: Bool = false) {
        let urlString = "\(rawURL)&lat=\(latitude)&lon=\(longitude)"
        if let lat = Double(latitude), let lon = Double(longitude) {
            performWeatherRequest(with: [urlString], fromLocation: fromLocation, latitude: lat, longitude: lon)
        }
    }

    func removeWeatherData(for data: String) {
        delegates.invoke(invocation: { delegate in
            delegate.weatherDataDidRemove(self, location: data)
        })
    }

    fileprivate func setCoordsFromMap(in weatherModel: WeatherModel, with latitude: Double, and longitude: Double) {
        if latitude != 0, longitude != 0 {
            weatherModel.latitude = latitude
            weatherModel.longitude = longitude
        }
    }

    private func performWeatherRequest(with urls: [String], fromLocation: Bool, latitude: Double = 0, longitude: Double = 0) {
        let fetchGroup = DispatchGroup()
        var weatherModels: [WeatherModel] = []

        for url in urls {
            fetchGroup.enter()

            AF.request(url)
                .validate()
                .response { response in
                    guard let responseData = response.data else { return }
                    let responseModel = WeatherResponse(data: responseData, fromLocation: fromLocation)
                    guard let weatherModel = responseModel.parseJSON() else { return }

                    self.setCoordsFromMap(in: weatherModel, with: latitude, and: longitude)
                    weatherModels.append(weatherModel)
                    fetchGroup.leave()
                }
            fetchGroup.notify(queue: .main) {
                self.invokeWeatherDataUpdate(with: weatherModels)
            }
        }
    }

    private func invokeWeatherDataUpdate(with weatherModels: [WeatherModel]) {
        weatherModels.forEach { model in
            self.delegates.invoke(invocation: { delegate in
                delegate.weatherDataDidUpdate(self, weather: model)
            })
        }
    }
}

extension String {
    func prepareNameToRequest() -> String {
        let removedSpaces = trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "%20")

        let removedDiacritics = removedSpaces.lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
            .replacingOccurrences(of: "ł", with: "l")

        return removedDiacritics
    }
}
