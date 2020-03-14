//
//  Locations.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 08/03/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import Foundation
import CoreLocation

class Locations {
    static let shared = Locations()
    var array: [String]?
    var currentLocation: CLLocation?
    var globalWeatherData: [WeatherModel]?
}

class boxLocation<T> {
    let value: T

    init(_ value: T) {
        self.value = value
    }
}
