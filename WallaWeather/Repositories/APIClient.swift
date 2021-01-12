//
//  APIClient.swift
//  WallaWeather
//
//  Created by Arie Peretz on 11/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import Foundation

class APIClient {
    
    enum APIError: Error {
        case invalidEndpoint
        case serverError
        case parsingError
    }
    
    private let APP_ID = "7bd45e491e54e8bddc935e01cf8ffed3"
    private let UNITS = "metric"
    private let baseURL = "https://api.openweathermap.org"
    
    private enum Endpoint: String {
        case currentWeatherGroup = "/data/2.5/group"
        case forecastFiveDays = "/data/2.5/forecast"
    }
    private enum Method: String {
        case GET
    }
    
    static let shared: APIClient = APIClient()
    
    func fetchCurrentWeather(cityIdentifiers: [CityIdentifier], completion: @escaping (Result<CurrentWeatherResponseModel,APIError>)->Void) {
        let parameters: [String:String] = [
            "id": cityIdentifiers.map { $0.rawValue }.joined(separator: ",")
        ]
        self.fetch(parameters: parameters,endpoint: .currentWeatherGroup, method: .GET, completion: completion)
    }
    
    func fetchFiveDaysForecast(cityId: String, completion: @escaping (Result<DetailsResponseModel,APIError>)->Void) {
        let parameters: [String:String] = [
            "id": cityId
        ]
        self.fetch(parameters: parameters,endpoint: .forecastFiveDays, method: .GET, completion: completion)
    }
    
    private func fetch<T:Codable>(parameters: [String:String], endpoint: Endpoint, method: Method, completion: @escaping (Result<T,APIError>)->Void) {
        
        // Build URL path
        let path = "\(baseURL)\(endpoint.rawValue)"
        guard let baseUrl = URL(string: path) else {
            completion(.failure(.invalidEndpoint))
            return
        }
        
        // Build query parameters
        var components: URLComponents? = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)
        components?.queryItems = parameters.map { (key,value) in
            URLQueryItem(name: key, value: value)
        }
        // Append query base parameters
        components?.queryItems?.append(URLQueryItem(name: "appid", value: APP_ID))
        components?.queryItems?.append(URLQueryItem(name: "units", value: UNITS))
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
