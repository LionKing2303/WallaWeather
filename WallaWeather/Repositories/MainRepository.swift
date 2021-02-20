//
//  MainRepository.swift
//  WallaWeather
//
//  Created by Arie Peretz on 11/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import Foundation
import Combine



protocol MainRepository {
    func fetchForecasts() -> Future<CurrentWeatherResponseModel?,APIClient.APIError>
}

class MockMainRepository: MainRepository {
    // Mock the main screen data
    func fetchForecasts() -> Future<CurrentWeatherResponseModel?,APIClient.APIError> {
        Future { promise in
            let forecasts = (1...10).map { index in
                Double(index)
            }.map { index in
                CurrentWeatherResponseModel.City(id: index, name: "City \(Int(index))", main: CurrentWeatherResponseModel.Main(temp: Double(15+index)), weather: [])
            }
            promise(.success(CurrentWeatherResponseModel(list: forecasts)))
        }
    }
}

class ServiceMainRepository: MainRepository {
    // Fetch the main screen data from server
    func fetchForecasts() -> Future<CurrentWeatherResponseModel?,APIClient.APIError> {
        Future { promise in
            let cityIdentifiers: [CityIdentifier] = [
                .Jerusalem,
                .TelAviv,
                .Haifa,
                .Eilat
            ]
            APIClient.shared.fetchCurrentWeather(cityIdentifiers: cityIdentifiers) { (result) in
                switch result {
                case .success(let responseModel):
                    responseModel.doCache() // Perform caching
                    promise(.success(responseModel))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }
    
    
}

