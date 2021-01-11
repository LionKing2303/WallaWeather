//
//  MainViewModel.swift
//  WallaWeather
//
//  Created by Arie Peretz on 10/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import Foundation
import Combine

class MainViewModel: ObservableObject {
    var dataModel: MainDataModel = MainDataModel(forecasts: [
        MainDataModel.Forecast(cityName: "Jerusalem", forecast: "1 - 3"),
        MainDataModel.Forecast(cityName: "Jerusalem", forecast: "1 - 3"),
        MainDataModel.Forecast(cityName: "Jerusalem", forecast: "1 - 3"),
        MainDataModel.Forecast(cityName: "Jerusalem", forecast: "1 - 3")
    ])
    var repository: Repository
    var refresh = PassthroughSubject<Void,Never>()
    
    init(repository: Repository) {
        self.repository = repository
        self.repository.fetchForecasts { (dataModel) in
            self.dataModel = dataModel
            DispatchQueue.main.async {
                self.refresh.send()
            }
        }
    }
}
