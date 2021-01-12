//
//  MainViewModel.swift
//  WallaWeather
//
//  Created by Arie Peretz on 10/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import Foundation
import Combine

class MainViewModel {
    var dataModel: MainDataModel = MainDataModel(forecasts: [])
    var repository: MainRepository
    @UserDefaultsBacked<String>(key: "walla.weather.layout", defaultValue: Layout.list.rawValue)
       var layout
    
    // MARK: -- Publishers
    var refresh = PassthroughSubject<Void,Never>()
    var layoutAsset = CurrentValueSubject<String?,Never>(nil)
    var lastUpdate = PassthroughSubject<String?,Never>()
    
    // MARK: -- Private variables
    private var cancellables: Set<AnyCancellable> = []

    init(repository: MainRepository) {
        self.repository = repository
        self.layoutAsset.send(Layout(rawValue: self.layout)?.asset())
    }
    
    func fetchForecasts() {
        self.repository.fetchForecasts()
            .replaceError(with: CurrentWeatherResponseModel.cached())
            .replaceNil(with: CurrentWeatherResponseModel(list: []))
            .map { responseModel in
                self.format(responseModel: responseModel)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { (dataModel) in
                self.dataModel = dataModel
                self.refresh.send()
                self.displayLastUpdate()
            })
            .store(in: &cancellables)
    }
    
    private func format(responseModel:CurrentWeatherResponseModel) -> MainDataModel {
        // Convert response into data for display
        let forecasts = responseModel.list.filter({ (city) -> Bool in
            city.id != nil
        }).map { city -> MainDataModel.Forecast in
            .init(cityId: String(format: "%.0f", city.id!), cityName: city.name ?? "", forecast: "\(city.main?.temp ?? 0.0)℃" )
        }
        return MainDataModel(forecasts: forecasts)
    }
    
    private func displayLastUpdate() {
        // Display last update date if available
        if let lastUpdateDate = CurrentWeatherResponseModel.cachedDate() {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            self.lastUpdate.send("Last update: \(formatter.string(from: lastUpdateDate))")
        } else {
            self.lastUpdate.send("Last update: -")
        }
    }
    
    func toggleLayout() {
        guard let layout = Layout(rawValue: layout) else { return }
        var asset: String?
        if layout == .list {
            self.layout = Layout.grid.rawValue
            asset = Layout.grid.asset()
        }
        else if layout == .grid {
            self.layout = Layout.list.rawValue
            asset = Layout.list.asset()
        }
        layoutAsset.send(asset)
    }
    
    func getLayout() -> Layout {
        return Layout(rawValue: self.layout) ?? .list
    }
}
