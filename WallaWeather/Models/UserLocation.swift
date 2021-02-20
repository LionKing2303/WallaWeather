//
//  UserLocation.swift
//  WallaWeather
//
//  Created by Arie Peretz on 19/02/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import CoreLocation

// NOTE: Used to get details about a city id or a specific location
struct UserLocation {
    enum LocationType {
        case id
        case location
    }
    
    let type: LocationType
    let cityId: String?
    let location: CLLocation?
}
