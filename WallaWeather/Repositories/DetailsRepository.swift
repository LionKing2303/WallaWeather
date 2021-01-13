//
//  DetailsRepository.swift
//  WallaWeather
//
//  Created by Arie Peretz on 12/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import Foundation
import Combine

protocol DetailsRepository {
    func fetchDetails(for location: UserLocation) -> Future<DetailsResponseModel,APIClient.APIError>
}

class ServiceDetailsRepository: DetailsRepository {
    func fetchDetails(for location: UserLocation) -> Future<DetailsResponseModel,APIClient.APIError> {
        Future { promise in
            APIClient.shared.fetchFiveDaysForecast(location: location) { result in
                switch result {
                case .success(let responseModel):
                    promise(.success(responseModel))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }
}
