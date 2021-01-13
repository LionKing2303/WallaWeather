//
//  DetailsViewModel.swift
//  WallaWeather
//
//  Created by Arie Peretz on 12/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import Foundation
import Combine

class DetailsViewModel {
    var dataModel: DetailsModel?
    var repository: DetailsRepository
    
    // MARK: -- Publishers
    var refresh = PassthroughSubject<Void,Never>()
    var cityName = PassthroughSubject<String?,Never>()
    var currentTemperature = PassthroughSubject<String?,Never>()
    
    // MARK: -- Private variables
    private var cancellables: Set<AnyCancellable> = []

    init(location: UserLocation, repository: DetailsRepository) {
        self.repository = repository
        fetchFiveDaysForecast(for: location)
    }
    
    func fetchFiveDaysForecast(for location: UserLocation) {
        self.repository.fetchDetails(for: location)
            .catch { error -> Just<DetailsResponseModel> in
                if error == APIClient.APIError.missingParameters {
                    return Just(DetailsResponseModel(city: DetailsResponseModel.City(name: "Please share location"), list: []))
                }
                return Just(DetailsResponseModel(city: DetailsResponseModel.City(name: "Error"), list: []))
            }
            .map { responseModel -> DetailsModel in
                responseModel.toDetailsModel()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] dataModel in
                self?.dataModel = dataModel
                self?.cityName.send(dataModel.cityName)
                if let firstForecast = dataModel.forecasts.first {
                    self?.currentTemperature.send(firstForecast.temperature)
                } else {
                    self?.currentTemperature.send("")
                }
                self?.refresh.send()
            })
            .store(in: &cancellables)
    }
}
