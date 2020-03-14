//
//  K.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 04/02/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import Foundation
import UIKit

struct K {
    static let userLocationsKey = "UserLocations"
    static let emptyCityName = "empty"

    static var color = UIColor { (traitCollection) -> UIColor in
        switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.white
            default:
                return UIColor.black
        }
    }

    struct WeatherCell {
        static let nibName = "WeatherCell"
        static let identifier = "WeatherReusableCell"
    }

    struct LocationWeatherCell {
        static let nibName = "LocationWeatherCell"
        static let identifier = "LocationWeatherCell"
        static let cellDetailsSegue = "mainToDetailWeather"
        static let listToMap = "fromListToMap"
    }

    struct Assets {
        static let upperColor = "upperColor"
        static let lowerColor = "lowerColor"
        static let background = "background"
        
    }
}
