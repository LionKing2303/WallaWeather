//
//  WallaWeatherTests.swift
//  WallaWeatherTests
//
//  Created by Arie Peretz on 10/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import XCTest
@testable import WallaWeather

class WallaWeatherTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testCurrentWeatherResponseModelToMainDataModel() {
        let weather: CurrentWeatherResponseModel.Weather = .init(icon: "image")
        let main: CurrentWeatherResponseModel.Main = .init(temp: 24)
        let city: CurrentWeatherResponseModel.City = .init(id: 0, name: "Test City", main: main, weather: [weather])
        
        let responseDataModel: CurrentWeatherResponseModel = .init(list: [city])
        let mainDataModel: MainDataModel = responseDataModel.toMainDataModel
        
        let cityId: String = String(format: "%.0f", (responseDataModel.list[0].id)!)
        XCTAssertEqual(cityId, mainDataModel.forecasts[1].cityId)
    }
}
