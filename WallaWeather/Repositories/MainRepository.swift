//
//  MainRepository.swift
//  WallaWeather
//
//  Created by Arie Peretz on 11/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import Foundation
import Combine

enum CityIdentifier: String {
    case Jerusalem = "281184"
    case TelAviv = "293397"
    case Haifa = "294801"
    case Eilat = "295277"
}

protocol MainRepository {
    func fetchForecasts() -> Future<CurrentWeatherResponseModel?,APIClient.APIError>
}

class MockMainRepository: MainRepository {
    func fetchForecasts() -> Future<CurrentWeatherResponseModel?,APIClient.APIError> {
        Future { promise in
            let forecasts = (1...10).map { index in
                Double(index)
            }.map { index in
                CurrentWeatherResponseModel.City(id: index, name: "City \(Int(index))", main: CurrentWeatherResponseModel.Main(temp: Double(15+index)))
            }
            promise(.success(CurrentWeatherResponseModel(list: forecasts)))
        }
    }
}

class ServiceMainRepository: MainRepository {
    
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
                    responseModel.doCache()
                    promise(.success(responseModel))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }
    
    
}

