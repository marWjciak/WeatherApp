//
//  LocationWeatherViewController.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 17/01/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import UIKit
import CoreLocation

class LocationWeatherViewController: UITableViewController, CLLocationManagerDelegate, WeatherManagerDelegate {
    
    let userDefaults = UserDefaults.standard
    let locationManager = CLLocationManager()
    var weatherManager = WeatherManager()
    
    var userLocations = [String]()
    var weatherData = [WeatherModel]()
    
    override func viewWillAppear(_ animated: Bool) {
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "LocationWeatherCell", bundle: nil), forCellReuseIdentifier: "LocationWeatherCell")
        
        weatherManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.delegate = self
        locationManager.requestLocation()
        
        if userLocations.count == 0 {
            userLocations = userDefaults.stringArray(forKey: "UserLocations") ?? []
        }
        print(userLocations)
        
        for location in userLocations {
            weatherManager.fetchWeatherData(for: location)
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    
    //MARK: - Add User Location
    
    @IBAction func addLocationPressed(_ sender: UIBarButtonItem) {
        
        var locationName = UITextField()
        
        let alert = UIAlertController(title: "Add New User Location", message: "Please type city name", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "City Name"
            locationName = textField
        }
        
        let addUserLocation = UIAlertAction(title: "Add", style: .default) { (addAction) in
            
            guard let locationNameString = locationName.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                return
            }
            
            guard !self.userLocations.contains(locationNameString) else {
                return
            }
            
            if locationNameString != "" {
                self.userLocations.append(locationNameString)
                self.userDefaults.set(self.userLocations, forKey: "UserLocations")
            
                self.weatherManager.fetchWeatherData(for: locationNameString)
            }
            
        }
        
        alert.addAction(addUserLocation)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Location Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        let lat = String(location.coordinate.latitude)
        let lon = String(location.coordinate.longitude)
        
        weatherManager.fetchWeather(latitude: lat, longitude: lon)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Cannot get current location, \(error)")
    }
    
    
    //MARK: - Weather Manager Delegate
    
    func weatherDataDidUpdate(_: WeatherManager, weather: WeatherModel) {
        if weather.fromLocation == true {
            weatherData.insert(weather, at: 0)
        } else {
            weatherData.append(weather)
        }
        
        self.tableView.reloadData()
    }
    
    func weatherDataDidFailUpdate(_: WeatherManager, fromLocation: Bool) {
        if !fromLocation {
            userLocations.removeLast()
            userDefaults.set(userLocations, forKey: "UserLocations")
        }
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return weatherData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationWeatherCell", for: indexPath) as! LocationWeatherCell
        let cellRow = self.weatherData[indexPath.row]
        
        DispatchQueue.main.async {
            cell.weatherImage.image = UIImage(systemName: cellRow.dayForecast[0].icon)
            cell.currentTemp.text = String(cellRow.dayForecast[0].temp)
            cell.cityName.text = cellRow.cityName
            cell.weatherDescription.text = cellRow.dayForecast[0].description
            cell.isFromLocationImage.isHidden = !cellRow.fromLocation
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "mainToDetailWeather", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! FiveDaysWeatherController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.forecasts = weatherData[indexPath.row]
        }
        
    }
    
}
