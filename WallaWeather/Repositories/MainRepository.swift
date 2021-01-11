//
//  MainRepository.swift
//  WallaWeather
//
//  Created by Arie Peretz on 11/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import Foundation

enum CityIdentifier: String {
    case Jerusalem = "281184"
    case TelAviv = "293397"
    case Haifa = "294801"
    case Eilat = "295277"
}

protocol Repository {
    func fetchForecasts(completion: @escaping (CurrentWeatherResponseModel)->Void)
}

class MockRepository: Repository {
    func fetchForecasts(completion: @escaping (CurrentWeatherResponseModel) -> Void) {
        let forecasts = (1...10).map { index in
            Double(index)
        }.map { index in
            CurrentWeatherResponseModel.City(id: index, name: "City \(Int(index))", main: CurrentWeatherResponseModel.Main(temp: Double(15+index)))
        }
        completion(CurrentWeatherResponseModel(list: forecasts))
    }
}

class MainRepository: Repository {
    
    func fetchForecasts(completion: @escaping (CurrentWeatherResponseModel) -> Void) {
        let cityIdentifiers: [CityIdentifier] = [
            .Jerusalem,
            .TelAviv,
            .Haifa,
            .Eilat
        ]
        APIClient.shared.fetchCurrentWeather(cityIdentifiers: cityIdentifiers) { (result) in
            switch result {
            case .success(let responseModel):
                
                completion(responseModel)
            case .failure:
                completion(CurrentWeatherResponseModel(list: []))
            }
        }
    }
    
    
}

