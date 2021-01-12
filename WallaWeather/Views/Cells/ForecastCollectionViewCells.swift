//
//  LargeCityForecastCollectionViewCell.swift
//  WallaWeather
//
//  Created by Arie Peretz on 10/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import UIKit

class ForecastCollectionViewCell: UICollectionViewCell {
    
    // MARK: -- Outlets
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var forecast: UILabel!
    
    // MARK: -- Private variables
    private var cityId: String?
    
    func set(cityId: String, forecast: MainDataModel.Forecast) {
        self.cityId = cityId
        self.cityName.text = forecast.cityName
        self.forecast.text = forecast.forecast
    }
    
    func getCityId() -> String? {
        cityId
    }
}

class LargeCityForecastCollectionViewCell: ForecastCollectionViewCell {
    static var identifier: String {
        "LargeCityForecastCollectionViewCell"
    }
}

class CompactCityForecastCollectionViewCell: ForecastCollectionViewCell {
    static var identifier: String {
        "CompactCityForecastCollectionViewCell"
    }
}
