//
//  MainRepository.swift
//  WallaWeather
//
//  Created by Arie Peretz on 11/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import Foundation

enum CityIdentifier: String {
    case Jerusalem = "281184"
    case TelAviv = "293397"
    case Haifa = "294800"
    case Eilat = "295277"
}

protocol Repository {
    func fetchForecasts(completion: @escaping (MainDataModel)->Void)
}

class MainRepository: Repository {
    
    func fetchForecasts(completion: @escaping (MainDataModel) -> Void) {
        let cityIdentifiers: [CityIdentifier] = [
            .Jerusalem,
            .TelAviv,
            .Haifa,
            .Eilat
        ]
        Agent.shared.fetchCurrentWeather(cityIdentifiers: cityIdentifiers) { (result) in
            switch result {
            case .success(let responseModel):
                let forecasts = responseModel.list.map { city -> MainDataModel.Forecast in
                    .init(cityName: city.name ?? "", forecast: "\(city.main?.temp ?? 0.0)℃" )
                }
                completion(MainDataModel(forecasts: forecasts))
            case .failure(let error):
                completion(MainDataModel(forecasts: []))
            }
        }
    }
    
    
}

class Agent {
    
    enum APIError: Error {
        case invalidEndpoint
        case serverError
        case parsingError
    }
    
    private let API_KEY = "7bd45e491e54e8bddc935e01cf8ffed3"
    private let baseURL = "https://api.openweathermap.org"
    
    private enum Endpoint: String {
        case currentWeatherGroup = "/data/2.5/group"
    }
    private enum Method: String {
        case GET
    }
    
    static let shared: Agent = Agent()
    
    func fetchCurrentWeather(cityIdentifiers: [CityIdentifier], completion: @escaping (Result<CurrentWeatherResponseModel,APIError>)->Void) {
        let parameters: [String:String] = [
            "id": cityIdentifiers.map { $0.rawValue }.joined(separator: ",")
        ]
        self.fetch(parameters: parameters,endpoint: .currentWeatherGroup, method: .GET, completion: completion)
    }
    
    private func fetch<T:Codable>(parameters: [String:String], endpoint: Endpoint, method: Method, completion: @escaping (Result<T,APIError>)->Void) {
        
        // Build URL
        let path = "\(baseURL)\(endpoint.rawValue)"
        guard let baseUrl = URL(string: path) else {
            completion(.failure(.invalidEndpoint))
            return
        }
        
        // Build Query Parameters
        var components: URLComponents? = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)
        components?.queryItems = parameters.map { (key,value) in
            URLQueryItem(name: key, value: value)
        }
        components?.queryItems?.append(URLQueryItem(name: "appid", value: API_KEY))
        components?.queryItems?.append(URLQueryItem(name: "units", value: "metric"))
        guard let url = components?.url else {
            completion(.failure(.invalidEndpoint))
            return
        }
        
        // Build Request
        var request: URLRequest = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
