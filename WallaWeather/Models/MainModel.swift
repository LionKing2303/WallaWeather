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
        let cityId: String
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

extension CurrentWeatherResponseModel {
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
    
    func toMainDataModel() -> MainDataModel {
        // Convert response into data for display
        var forecasts = self.list.filter({ (city) -> Bool in
            city.id != nil
        }).map { city -> MainDataModel.Forecast in
            .init(cityId: String(format: "%.0f", city.id!), cityName: city.name ?? "", forecast: "\(city.main?.temp ?? 0.0)℃" )
        }
        forecasts.insert(MainDataModel.Forecast(cityId: "", cityName: "Current Location", forecast: ""), at: 0)
        return MainDataModel(forecasts: forecasts)
    }
}
