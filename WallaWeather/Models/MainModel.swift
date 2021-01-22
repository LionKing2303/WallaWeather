//
//  MainModel.swift
//  WallaWeather
//
//  Created by Arie Peretz on 10/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import Foundation

// MARK: Main Screen Data Model
struct MainDataModel {
    let forecasts: [Forecast]
}

extension MainDataModel {
    struct Forecast {
        let cityId: String
        let cityName: String
        let forecast: String
        let iconName: String?
    }
}

// MARK: Main Screen Server Response Model
struct CurrentWeatherResponseModel: Codable {
    let list: [City]
    
    // NOTE: This computed variable is used for converting to the main screen data model
    var toMainDataModel: MainDataModel {
        // Convert response into data for display
        var forecasts = self.list.filter({ (city) -> Bool in
            city.id != nil
        }).map { city -> MainDataModel.Forecast in
            if let temperature = city.main?.temp {
                return MainDataModel.Forecast(cityId: String(format: "%.0f", city.id!), cityName: city.name ?? "", forecast: "\(temperature)℃", iconName: city.weather.first?.icon)
            }
            return MainDataModel.Forecast(cityId: String(format: "%.0f", city.id!), cityName: city.name ?? "", forecast: "", iconName: city.weather.first?.icon)
        }
        forecasts.insert(MainDataModel.Forecast(cityId: "", cityName: "Current Location", forecast: "", iconName: nil), at: 0)
        return MainDataModel(forecasts: forecasts)
    }
}

extension CurrentWeatherResponseModel {
    struct City: Codable {
        let id: Double?
        let name: String?
        let main: Main?
        let weather: [Weather]
    }
}

extension CurrentWeatherResponseModel {
    struct Main: Codable {
        let temp: Double?
    }
}

extension CurrentWeatherResponseModel {
    struct Weather: Codable {
        let icon: String?
    }
}

extension CurrentWeatherResponseModel {
    // NOTE: This extension is used for caching the model
    @UserDefaultsBacked<Data?>(key: "walla.weather.cache", defaultValue: nil) private static var cache
    @UserDefaultsBacked<Date?>(key: "walla.weather.cache.date", defaultValue: nil) private static var cacheDate

    static func cached() -> CurrentWeatherResponseModel? {
        guard let cacheData = cache else { return nil }
        let data = try? JSONDecoder().decode(CurrentWeatherResponseModel.self, from: cacheData)
        return data
    }
    
    static func cachedDate() -> Date? {
        CurrentWeatherResponseModel.cacheDate
    }
    
    func doCache() {
        if let data = try? JSONEncoder().encode(self) {
            CurrentWeatherResponseModel.cache = data
            CurrentWeatherResponseModel.cacheDate = Date()
        }
    }
}
