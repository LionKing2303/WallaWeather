//
//  DetailsModel.swift
//  WallaWeather
//
//  Created by Arie Peretz on 12/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import Foundation

// MARK: City Screen Data Model
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

// MARK: City Screen Server Response Model
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

extension DetailsResponseModel {
    // NOTE: This extension is used for converting it to the city screen data model
    func toDetailsModel() -> DetailsModel {
        var cityName: String = ""
        var forecasts: [DetailsModel.Forecast] = []
        cityName = self.city?.name ?? ""
        forecasts = self.list.compactMap { forecast -> DetailsModel.Forecast? in
            if let dt = forecast.dt, let temperature = forecast.main?.temp {
                return DetailsModel.Forecast(date: Date(timeIntervalSince1970: dt).formattedDate(), temperature: "\(temperature)℃")
            }
            return nil
        }
        return DetailsModel(cityName: cityName, forecasts: forecasts)
    }
}
