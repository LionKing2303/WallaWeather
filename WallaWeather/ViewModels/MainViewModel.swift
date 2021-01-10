//
//  MainViewModel.swift
//  WallaWeather
//
//  Created by Arie Peretz on 10/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import Combine

class MainViewModel: ObservableObject {
    var dataModel: MainDataModel = MainDataModel(forecasts: [
        MainDataModel.Forecast(cityName: "Jerusalem", forecast: "1 - 3"),
        MainDataModel.Forecast(cityName: "Jerusalem", forecast: "1 - 3"),
        MainDataModel.Forecast(cityName: "Jerusalem", forecast: "1 - 3"),
        MainDataModel.Forecast(cityName: "Jerusalem", forecast: "1 - 3")
    ])
    var layout: Layout = .grid
    @Published var layoutSwitchAsset: String = Layout.grid.asset()
    
    func switchLayout() {
        if layout == .list { layout = .grid }
        else if layout == .grid { layout = .list }
        
    }
}
