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
    var cityName = PassthroughSubject<String?,Never>()
    
    // MARK: -- Private variables
    private var cityId: String?
    private var cancellables: Set<AnyCancellable> = []

    init(cityId: String, repository: DetailsRepository) {
        self.cityId = cityId
        self.repository = repository
        fetchFiveDaysForecast()
    }
    
    func fetchFiveDaysForecast() {
        if let cityId = self.cityId {
            self.repository.fetchDetails(for: cityId)
            .print()
            .replaceError(with: DetailsResponseModel(city: DetailsResponseModel.City(name: ""), list: []))
            .map { responseModel in
                DetailsModel(cityName: responseModel?.city?.name ?? "")
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { (dataModel) in
                self.dataModel = dataModel
                self.cityName.send(dataModel.cityName)
            })
            .store(in: &cancellables)
        }
    }
}
