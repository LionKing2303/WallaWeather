//
//  APIClient.swift
//  WallaWeather
//
//  Created by Arie Peretz on 11/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import Foundation

// Configure the default cities that we want to fetch data for by id.
enum CityIdentifier: String {
    case Jerusalem = "281184"
    case TelAviv = "293397"
    case Haifa = "294801"
    case Eilat = "295277"
}

class APIClient {
    
    // Define the possible server errors
    enum APIError: Error {
        case invalidEndpoint
        case serverError
        case parsingError
        case missingParameters
    }
    
    // Define the endpoints used
    private enum Endpoint: String {
        case currentWeatherGroup = "/data/2.5/group"
        case forecastFiveDays = "/data/2.5/forecast"
    }
    private enum Method: String {
        case GET
    }
    // Define the keys used on server reqeusts
    private enum Keys: String {
        case appId = "appid" // Base parameter on all server requests
        case units = "units" // Base parameter on all server requests
        case id = "id"
        case latitude = "lat"
        case longitude = "lon"
    }
    // Define hard-coded key values on server requests
    private enum Value: String {
        case metric = "metric"
    }
    static let shared: APIClient = APIClient()
    
    // Make service request for the main screen
    func fetchCurrentWeather(cityIdentifiers: [CityIdentifier], completion: @escaping (Result<CurrentWeatherResponseModel,APIError>)->Void) {
        let parameters: [String:String] = [
            Keys.id.rawValue: cityIdentifiers.map { $0.rawValue }.joined(separator: ",")
        ]
        self.fetch(parameters: parameters,endpoint: .currentWeatherGroup, method: .GET, completion: completion)
    }
    
    // Make service request for the city screen
    func fetchFiveDaysForecast(location: UserLocation, completion: @escaping (Result<DetailsResponseModel,APIError>)->Void) {
        var parameters: [String:String] = [:]
        // Set the relevant parameters according to the location type
        if location.type == .id, let cityId = location.cityId {
            parameters.updateValue(cityId, forKey: Keys.id.rawValue)
        } else if location.type == .location, let location = location.location {
            parameters.updateValue("\(location.coordinate.latitude)", forKey: Keys.latitude.rawValue)
            parameters.updateValue("\(location.coordinate.longitude)", forKey: Keys.longitude.rawValue)
        } else {
            // If we don't have the location parameters then we send a missing parameters error
            completion(.failure(.missingParameters))
        }
        self.fetch(parameters: parameters,endpoint: .forecastFiveDays, method: .GET, completion: completion)
    }
    
    // Make a service request on a selected endpoint, method and parameters
    private func fetch<T:Codable>(parameters: [String:String], endpoint: Endpoint, method: Method, completion: @escaping (Result<T,APIError>)->Void) {
        
        // Build URL path
        guard let baseURL = Configuration.value(for: .API_BASE_URL), let baseUrl = URL(string: "https://\(baseURL)\(endpoint.rawValue)") else {
            completion(.failure(.invalidEndpoint))
            return
        }
        
        // Build query parameters
        var components: URLComponents? = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)
        components?.queryItems = parameters.map { (key,value) in
            URLQueryItem(name: key, value: value)
        }
        // Append query base parameters
        components?.queryItems?.append(URLQueryItem(name: Keys.appId.rawValue, value: Configuration.value(for: .API_KEY)))
        components?.queryItems?.append(URLQueryItem(name: Keys.units.rawValue, value: Value.metric.rawValue))
        guard let url = components?.url else {
            completion(.failure(.invalidEndpoint))
            return
        }
        
        // Build request
        var request: URLRequest = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Execute request
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                completion(.failure(.serverError))
                return
            }
            
            do {
                guard let data = data else {
                    completion(.failure(.serverError))
                    return
                }
                let model = try JSONDecoder().decode(T.self, from: data)
                completion(.success(model))
            } catch {
                completion(.failure(.parsingError))
                return
            }
        }
        task.resume()
    }
}
