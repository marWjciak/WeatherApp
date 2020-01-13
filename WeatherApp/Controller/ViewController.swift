//
//  ViewController.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 24/12/2019.
//  Copyright © 2019 Marcin Wójciak. All rights reserved.
//

import UIKit
import CoreLocation


class ViewController: UIViewController {

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var tempField: UILabel!
    @IBOutlet weak var cityNameField: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var todayIcon: UIImageView!
    
    // tomorrow
    @IBOutlet weak var tomorowLabel: UILabel!
    @IBOutlet weak var tomorrowIcon: UIImageView!
    @IBOutlet weak var tomorrowTemp: UILabel!
    
    // day after tomorrow
    @IBOutlet weak var afterTomorrowLabel: UILabel!
    @IBOutlet weak var afterTomorrowIcon: UIImageView!
    @IBOutlet weak var afterTomorrowTemp: UILabel!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    var loadedWeatherModel: WeatherModel?
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("WeatherProperty.plist")
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadFromPropertyList()
        
        weatherManager.delegate = self
        searchField.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.requestLocation()
        
    }

    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchField.endEditing(true)
    }
    @IBAction func fiveDayForecastPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "MainToForecast", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! FiveDaysWeatherController
        
        if let safeWeatherModel = loadedWeatherModel {
            destinationVC.forecasts = safeWeatherModel
        }
    }
    
    //MARK: - Property List Functions

    func saveToPropertyList() {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(loadedWeatherModel)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error during encoding, \(error)")
        }
    }
    
    func loadFromPropertyList() {
        
        guard let data = try? Data(contentsOf: dataFilePath!) else {
            return
        }
        
        let decoder = PropertyListDecoder()
        
        do {
           loadedWeatherModel = try decoder.decode(WeatherModel.self, from: data)
        } catch {
            print("Error during decoding, \(error)")
        }
        
        guard let checkedWeatherModel = loadedWeatherModel else {
            return
        }
        updateGUI(checkedWeatherModel)
    }
}

//MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchField.endEditing(true)
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let cityName = textField.text {
            textField.text = ""
            
            
            weatherManager.fetchWeatherData(for: cityName)
        } else {
            print("Error")
        }
    }
}

//MARK: - WeatherManagerDelegate

extension ViewController: WeatherManagerDelegate {
    
    func weatherDataDidUpdate(_: WeatherManager, weather: WeatherModel) {
        if weather.dayForecast.count == 0 {
            return
        }
        
        loadedWeatherModel = weather
        saveToPropertyList()
        
        updateGUI(loadedWeatherModel!)
    }
    
    fileprivate func updateGUI(_ weather: WeatherModel) {
        DispatchQueue.main.async {
            self.cityNameField.text = weather.cityName
            self.tempField.text = String(weather.dayForecast[0].temp)
            self.todayIcon.image = UIImage(systemName: weather.dayForecast[0].icon)
            
            self.tomorowLabel.text = String(weather.dayForecast[7].date)
            self.tomorrowTemp.text = String(weather.dayForecast[7].temp)
            self.tomorrowIcon.image = UIImage(systemName: weather.dayForecast[7].icon)
            
            self.afterTomorrowLabel.text = String(weather.dayForecast[15].date)
            self.afterTomorrowTemp.text = String(weather.dayForecast[15].temp)
            self.afterTomorrowIcon.image = UIImage(systemName: weather.dayForecast[15].icon)
        }
    }
}

//MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
