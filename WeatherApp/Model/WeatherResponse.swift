//
//  WeatherResponse.swift
//  WeatherApp
//
//  Created on 25/01/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import Foundation

struct WeatherResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case city
        case dayForecasts = "list"
    }

    let city: CityInfoResponse
    let dayForecasts: [DayForecastResponse]

    init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            city = try container.decode(CityInfoResponse.self, forKey: .city)
            dayForecasts = try container.decode([DayForecastResponse].self, forKey: .dayForecasts)
        } catch let error {
            fatalError("Could not decode response.\nError: \(error)")
        }
    }
}

struct CityInfoResponse: Decodable {
    let name: String
}

struct DayForecastResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case timestamp = "dt"
        case main
        case conditions = "weather"
    }

    let date: Date
    let main: MainParametersResponse
    let conditions: [WeatherConditionResponse]

    init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let timestamp = try container.decode(TimeInterval.self, forKey: .timestamp)
            date = Date(timeIntervalSince1970: timestamp) // GMT
            main = try container.decode(MainParametersResponse.self, forKey: .main)
            conditions = try container.decode([WeatherConditionResponse].self, forKey: .conditions)
        } catch let error {
            fatalError("Could not decode response.\nError: \(error)")
        }
    }
}

struct MainParametersResponse: Decodable {
    let temp: Double
}

struct WeatherConditionResponse: Decodable {
    let id: Int
    let description: String
}

