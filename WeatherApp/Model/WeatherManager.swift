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

protocol WeatherManagerDelegate: class {
    func weatherDataDidUpdate(_: WeatherManager, weather: WeatherModel)
}

struct WeatherManager {
    let rawURL = "https://api.openweathermap.org/data/2.5/forecast?appid=ae70447edd3ebdbaca972a829ab5765c&units=metric"
    weak var delegate: WeatherManagerDelegate?

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

    private func performWeatherRequest(with url: String, fromLocation: Bool) {
        Alamofire.request(url).response { (response) in
            guard let data = response.data else {
                return
            }

            guard let model = self.mapDataToModel(data, fromLocation: fromLocation) else {
                return
            }

            self.delegate?.weatherDataDidUpdate(self, weather: model)
        }
    }

    private func mapDataToModel(_ data: Data, fromLocation: Bool) -> WeatherModel? {
        guard let responseModel = try? JSONDecoder().decode(WeatherResponse.self, from: data) else {
            return nil
        }

        return WeatherModel(weatherResponse: responseModel, fromLocation: fromLocation)
    }
}
