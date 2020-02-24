//
//  K.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 04/02/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import Foundation

struct K {
    static let userLocationsKey = "UserLocations"
    static let emptyCityName = "empty"

    struct WeatherCell {
        static let nibName = "WeatherCell"
        static let identifier = "WeatherReusableCell"
    }

    struct LocationWeatherCell {
        static let nibName = "LocationWeatherCell"
        static let identifier = "LocationWeatherCell"
        static let cellDetailsSegue = "mainToDetailWeather"
    }
}
