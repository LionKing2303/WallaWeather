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
    
    func set(forecast: MainDataModel.Forecast) {
        self.cityName.text = forecast.cityName
        self.forecast.text = forecast.forecast
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
