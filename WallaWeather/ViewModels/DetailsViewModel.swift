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
            .replaceError(with: DetailsResponseModel(city: DetailsResponseModel.City(name: "Error"), list: []))
            .map { responseModel -> DetailsModel in
                self.format(responseModel: responseModel)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { (dataModel) in
                self.dataModel = dataModel
                self.cityName.send(dataModel.cityName)
                if let firstForecast = dataModel.forecasts.first {
                    self.currentTemperature.send(firstForecast.temperature)
                } else {
                    self.currentTemperature.send("")
                }
                self.refresh.send()
            })
            .store(in: &cancellables)
        }
    }
    
    
    private func format(responseModel:DetailsResponseModel) -> DetailsModel {
        var cityName: String = ""
        var forecasts: [DetailsModel.Forecast] = []
        cityName = responseModel.city?.name ?? ""
        forecasts = responseModel.list.compactMap { forecast -> DetailsModel.Forecast? in
            if let dt = forecast.dt, let temperature = forecast.main?.temp {
                return DetailsModel.Forecast(date: Date(timeIntervalSince1970: dt).formattedDate(), temperature: "\(temperature)℃")
            }
            return nil
        }
        return DetailsModel(cityName: cityName, forecasts: forecasts)
    }
}
