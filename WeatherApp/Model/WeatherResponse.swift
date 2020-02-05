//
//  ResponseData.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 28/01/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import Foundation
import SwiftyJSON

struct WeatherResponse {
    let data: Data
    let fromLocation: Bool

    func parseJSON() -> WeatherModel? {
        let data = JSON(self.data)

        return WeatherModel(data, fromLocation: self.fromLocation)
    }
}
