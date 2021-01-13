//
//  Environment.swift
//  WallaWeather
//
//  Created by Arie Peretz on 13/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import Foundation

enum Configuration {
    enum Key: String {
        case API_KEY = "API_KEY"
        case API_BASE_URL = "API_BASE_URL"
    }
    static func value(for key: Key) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key.rawValue) as? String else {
            return nil
        }
        return value
    }
}
