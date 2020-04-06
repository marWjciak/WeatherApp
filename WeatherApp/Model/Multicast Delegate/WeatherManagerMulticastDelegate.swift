//
//  WeatherManagerMulticastDelegate.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 04/04/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import Foundation

class WeatherManagerMulticastDelegate: WeatherManagerDelegate {
    private let multicast = MulticastDelegate<WeatherManagerDelegate>()

    init(_ delegates: [WeatherManagerDelegate]) {
        delegates.forEach(multicast.add)
    }

    func weatherDataDidUpdate(_ manager: WeatherManager, weather: WeatherModel) {
        multicast.invoke { $0.weatherDataDidUpdate(manager, weather: weather) }
    }
}
