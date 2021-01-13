//
//  FutureForecastTableViewCell.swift
//  WallaWeather
//
//  Created by Arie Peretz on 13/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import UIKit

class FutureForecastTableViewCell: UITableViewCell {

    static var identifier: String {
        "FutureForecastTableViewCell"
    }
    
    // MARK: -- Outlets
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var forecast: UILabel!
    
    
    func configure(date: String, forecast: String) {
        self.date.text = date
        self.forecast.text = forecast
    }
 
    
}
