//
//  Configuration.swift
//  WallaWeather
//
//  Created by Arie Peretz on 13/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import Foundation

// MARK: Used for fetching the secret API key and API base url from configuration files
enum Configuration {
    enum Key: String {
        case API_KEY = "API_KEY"
        case API_BASE_URL = "API_BASE_URL"
        case API_BASE_ICONS_URL = "API_BASE_ICONS_URL"
    }
    static func value(for key: Key) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key.rawValue) as? String else {
            return nil
        }
        return value
    }
}
