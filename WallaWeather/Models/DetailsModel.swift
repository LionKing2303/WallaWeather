//
//  DetailsModel.swift
//  WallaWeather
//
//  Created by Arie Peretz on 12/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import Foundation

struct DetailsModel {
    let cityName: String
    let forecasts: [Forecast]
}

extension DetailsModel {
    struct Forecast {
        let date: String
        let temperature: String
    }
}

struct DetailsResponseModel: Codable {
    let city: City?
    let list: [Forecast]
}

extension DetailsResponseModel {
    struct City: Codable {
        let name: String?
    }
}

extension DetailsResponseModel {
    struct Forecast: Codable {
        let dt: Double? // Date
        let main: Main?
    }
}

extension DetailsResponseModel {
    struct Main: Codable {
        let temp: Double?
    }
}
