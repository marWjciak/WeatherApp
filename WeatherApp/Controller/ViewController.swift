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
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
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
        
        updateGUI()
    }
}

//MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchField.endEditing(true)
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let cityName = textField.text else {
            print("Error")
            return
        }
        
        if cityName != "" {
            textField.text = ""
            weatherManager.fetchWeatherData(for: cityName)
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
        
        updateGUI()
    }
    
    fileprivate func updateGUI() {
        
        guard let safeWeatherModel = loadedWeatherModel else {
            return
        }
        
        DispatchQueue.main.async {
            self.cityNameField.text = safeWeatherModel.cityName
            self.tempField.text = String(safeWeatherModel.dayForecast[0].temp)
            self.todayIcon.image = UIImage(systemName: safeWeatherModel.dayForecast[0].icon)
            
            self.tomorowLabel.text = String(safeWeatherModel.dayForecast[7].date)
            self.tomorrowTemp.text = String(safeWeatherModel.dayForecast[7].temp)
            self.tomorrowIcon.image = UIImage(systemName: safeWeatherModel.dayForecast[7].icon)
            
            self.afterTomorrowLabel.text = String(safeWeatherModel.dayForecast[15].date)
            self.afterTomorrowTemp.text = String(safeWeatherModel.dayForecast[15].temp)
            self.afterTomorrowIcon.image = UIImage(systemName: safeWeatherModel.dayForecast[15].icon)
        }
    }
}

//MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let lat = String(location.coordinate.latitude)
            let lon = String(location.coordinate.longitude)
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
