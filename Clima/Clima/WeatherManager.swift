//
//  WeatherManager.swift
//  Clima
//
//  Created by Dean Foster on 7/16/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func weatherManager(_ manager: WeatherManager, didGetWeather weather: WeatherModel)
    func weatherManager(_ manager: WeatherManager, didFailWithError error: Error)
}

struct WeatherManager {
    var delegate: WeatherManagerDelegate?
    private var baseComponents: URLComponents!
    
    init() {
        baseComponents = URLComponents()
        baseComponents.scheme = "https"
        baseComponents.host = "api.openweathermap.org"
        baseComponents.path = "/data/2.5/weather"
        baseComponents.queryItems = [
            URLQueryItem(name: "appid", value: "d0e47b3ae04e396b8b1067f549418ddb"),
            URLQueryItem(name: "units", value: "imperial")
        ]
    }
    
    func fetchWeather(cityName: String) {
        var components = baseComponents
        components!.queryItems!.append(URLQueryItem(name: "q", value: cityName))
        guard let urlString = components?.string else {
            fatalError("Invalid URL!")
        }
        
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longtiude: CLLocationDegrees) {
        let latString = latitude.description
        let lonString = longtiude.description
        var components = baseComponents
        components!.queryItems!.append(URLQueryItem(name: "lat", value: latString))
        components!.queryItems!.append(URLQueryItem(name: "lon", value: lonString))
        
        guard let urlString = components?.string else {
            fatalError("Invalid URL!")
        }
        
        performRequest(with: urlString)
    }
    
    private func performRequest(with urlString: String) {
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL!")
        }
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                self.delegate?.weatherManager(self, didFailWithError: error!)
                return
            }
            
            if let data = data {
                if let weather = self.parseJSON(data) {
                    DispatchQueue.main.async {
                        self.delegate?.weatherManager(self, didGetWeather: weather)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    private func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            return WeatherModel(conditionID: id, cityName: name, temperature: temp)
            
        } catch {
            delegate?.weatherManager(self, didFailWithError: error)
            return nil
        }
    }
}
