//
//  Utilities.swift
//  WallaWeather
//
//  Created by Arie Peretz on 11/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import Foundation

@propertyWrapper struct UserDefaultsBacked<Value> {
    let key: String
    let defaultValue: Value
    var storage: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            let value = storage.value(forKey: key) as? Value
            return value ?? defaultValue
        }
        set {
            storage.setValue(newValue, forKey: key)
        }
    }
}
