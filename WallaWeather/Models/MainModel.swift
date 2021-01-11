//
//  MainModel.swift
//  WallaWeather
//
//  Created by Arie Peretz on 10/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import Foundation

struct MainDataModel {
    let forecasts: [Forecast]
}

extension MainDataModel {
    struct Forecast {
        let cityName: String
        let forecast: String
    }
}

struct CurrentWeatherResponseModel: Codable {
    let list: [City]
}

extension CurrentWeatherResponseModel {
    struct City: Codable {
        let id: Double?
        let name: String?
        let main: Main?
    }
}

extension CurrentWeatherResponseModel {
    struct Main: Codable {
        let temp: Double?
    }
}
