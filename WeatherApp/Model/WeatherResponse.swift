//
//  ResponseData.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 28/01/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import Foundation
import SwiftyJSON

/*
 {
   "city" : {
     "country" : "PL",
     "name" : "Warsaw",
     "sunset" : 1580310923,
     "population" : 1000000,
     "sunrise" : 1580278939,
     "timezone" : 3600,
     "coord" : {
       "lon" : 21.011800000000001,
       "lat" : 52.229799999999997
     },
     "id" : 756135
   },
   "message" : 0,
   "cod" : "200",
   "cnt" : 40,
   "list" : [
     {
       "weather" : [
         {
           "main" : "Clouds",
           "id" : 804,
           "description" : "overcast clouds",
           "icon" : "04n"
         }
       ],
       "main" : {
         "grnd_level" : 985,
         "sea_level" : 999,
         "pressure" : 999,
         "temp_max" : 0.93999999999999995,
         "temp_min" : 0.62,
         "feels_like" : -5.21,
         "temp_kf" : 0.32000000000000001,
         "temp" : 0.93999999999999995,
         "humidity" : 78
       },
       "dt" : 1580277600,
       "sys" : {
         "pod" : "n"
       },
       "clouds" : {
         "all" : 100
       },
       "dt_txt" : "2020-01-29 06:00:00",
       "wind" : {
         "speed" : 5.4699999999999998,
         "deg" : 238
       }
     },
        .
        .
        .
   ]
 }
 */

struct WeatherResponse {
    let data: Data
    let fromLocation: Bool

    func parseJSON() -> WeatherModel? {
        let data = JSON(self.data)

        return WeatherModel(data, fromLocation: self.fromLocation)
    }
}
