//
//  Locations.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 08/03/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import Foundation
import CoreLocation

class WeatherData {
    static let shared = WeatherData()

    var currentLocation: CLLocation?
    var globalWeatherData: [WeatherModel]?
    var weatherManager = WeatherManager()

    private init() { }
}
