//
//  ForecastPin.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 08/03/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import Foundation
import MapKit

class ForecastPin: MKPointAnnotation {
    var image: String?
    var button: UIButton?

    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, image: String, button: UIButton? = nil) {
        super.init()
        super.title = title
        super.subtitle = subtitle
        super.coordinate = coordinate
        self.image = image
        self.button = button
    }
}
