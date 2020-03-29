//
//  ForecastPinManager.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 26/03/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import Foundation
import MapKit

protocol ForecastPinManagerDelegate {
    func newLocationDidAdd(_: ForecastPinManager, with coords: CLLocationCoordinate2D)
}

class ForecastPinManager {
    var delegate: ForecastPinManagerDelegate?

    func createForecastAnnotation(for weatherModel: WeatherModel) -> ForecastPin? {
        let coords = CLLocationCoordinate2D(latitude: weatherModel.latitude, longitude: weatherModel.longitude)
        let cityName = weatherModel.cityName
        let temp = weatherModel.dayForecasts[0].temp
        let weatherIcon = weatherModel.dayForecasts[0].icon
        let fromLocation = weatherModel.fromLocation

        let annotation = ForecastPin(title: cityName,
                                     subtitle: "\(temp)°C",
                                     coordinate: coords,
                                     image: weatherIcon)

        if !fromLocation {
            let removeButton = UIButton(type: .custom)
            removeButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            removeButton.setImage(UIImage(systemName: "trash"), for: .normal)
            removeButton.tintColor = .red
            annotation.button = removeButton
        }

        return annotation
    }

    func addLocationOnMap(coordinates: CLLocationCoordinate2D) {
        delegate?.newLocationDidAdd(self, with: coordinates)
    }
}
