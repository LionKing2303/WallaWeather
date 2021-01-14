//
//  LargeCityForecastCollectionViewCell.swift
//  WallaWeather
//
//  Created by Arie Peretz on 10/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import UIKit
import Combine

class ForecastCollectionViewCell: UICollectionViewCell {
    
    // MARK: -- Outlets
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var forecast: UILabel!
    
    // MARK: -- Private variables
    private var cityId: String?
    private var cancellables: Set<AnyCancellable> = []
    
    func configure(cityId: String, forecast: MainDataModel.Forecast) {
        self.cityId = cityId
        self.cityName.text = forecast.cityName
        self.forecast.text = forecast.forecast
        if let iconName = forecast.iconName,
           let baseIconsURL = Configuration.value(for: .API_BASE_ICONS_URL),
           let url = URL(string: "http://\(baseIconsURL)/img/wn/\(iconName)@2x.png") {
            // Fetch the icon from server and set it on the uiimage
            URLSession.shared.dataTaskPublisher(for: url)
                .map { UIImage(data: $0.data) }
                .replaceError(with: nil)
                .receive(on: DispatchQueue.main)
                .assign(to: \.image, on: self.icon)
                .store(in: &cancellables)
        } else {
            self.icon.image = nil
        }
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
