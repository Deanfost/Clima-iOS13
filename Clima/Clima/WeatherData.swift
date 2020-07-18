//
//  WeatherData.swift
//  Clima
//
//  Created by Dean Foster on 7/17/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

struct WeatherData: Decodable {
    let name: String
    let main: Main
    let weather: [WeatherItem]
}

struct Main: Decodable {
    let temp: Double
}

struct WeatherItem: Decodable {
    let description: String
    let id: Int
}
