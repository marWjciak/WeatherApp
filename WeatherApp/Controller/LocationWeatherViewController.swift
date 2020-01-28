//
//  LocationWeatherViewController.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 17/01/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import UIKit
import CoreLocation
import SwipeCellKit

class LocationWeatherViewController: UITableViewController, CLLocationManagerDelegate, WeatherManagerDelegate, SwipeTableViewCellDelegate, UITableViewDragDelegate {
    
    let userDefaults = UserDefaults.standard
    let locationManager = CLLocationManager()
    var weatherManager = WeatherManager()
    var addingData = false
    
    var userLocations = [String]()
    var weatherData = [WeatherModel(cityName: "empty", dayForecast: [], fromLocation: true)]
    var locationWithIndexRow: [String: Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 0
        
        tableView.register(UINib(nibName: "LocationWeatherCell", bundle: nil), forCellReuseIdentifier: "LocationWeatherCell")
        
        weatherManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.delegate = self
        locationManager.requestLocation()
        
        // move cell
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        
        loadUserData()
    }
    
    //MARK: - Add User Location
    
    @IBAction func addLocationPressed(_ sender: UIBarButtonItem) {
        
        addingData = true
        
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
        
        weatherManager.fetchWeatherData(latitude: lat, longitude: lon)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Cannot get current location, \(error)")
    }
    
    //MARK: - Weather Manager Delegate
    
    func weatherDataDidUpdate(_: WeatherManager, weather: WeatherModel) {
        if weather.fromLocation == true {

            weatherData[0] = weather

        } else {
            
            let containsWeatherData = weatherData.contains { (element) -> Bool in
                if element.cityName == weather.cityName {
                    return true
                } else {
                    return false
                }
            }
            
            if !containsWeatherData {
                if let cityIndex = locationWithIndexRow[weather.cityName] {
                    weatherData.remove(at: cityIndex)
                    weatherData.insert(weather, at: cityIndex)
                } else {
                    weatherData.append(weather)
                }
                
                if addingData {
                    DispatchQueue.main.async {
                        let indexPath = IndexPath(row: self.weatherData.count - 1, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                    addingData = false
                }
                saveUserData()
            }
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return weatherData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationWeatherCell", for: indexPath) as! LocationWeatherCell
        
        cell.delegate = self
        
        let cellRow = self.weatherData[indexPath.row]
        
        if !cellRow.dayForecast.isEmpty {

            DispatchQueue.main.async {
                cell.weatherImage.image = UIImage(systemName: cellRow.dayForecast[0].icon)
                cell.currentTemp.text = String(cellRow.dayForecast[0].temp)
                cell.cityName.text = cellRow.cityName
                cell.weatherDescription.text = cellRow.dayForecast[0].description
                cell.isFromLocationImage.isHidden = !cellRow.fromLocation
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if weatherData[indexPath.row].dayForecast.isEmpty {
            return 0
        } else {
            return tableView.bounds.size.height / 4
        }
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
    
    //MARK: - SwipeTableViewCellDelegate
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let returnedAction: SwipeAction
        
        if indexPath.row == 0 {
            guard orientation == .left else { return nil }
            
            let reloadLocationAction = SwipeAction(style: .default, title: "Refresh") { (action, indexPath) in
                
                self.tableView.reloadRows(at: [indexPath], with: .left)
                self.locationManager.requestLocation()
            }
            
            reloadLocationAction.image = UIImage(systemName: "arrow.uturn.right")
            reloadLocationAction.backgroundColor = .blue
            
            returnedAction = reloadLocationAction
            
        } else {
            guard orientation == .right else { return nil }
            
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                
                let cellToRemove = self.weatherData[indexPath.row]
                
                self.removeSelectedCell(cellToRemove, indexPath)
            }
            
            deleteAction.image = UIImage(systemName: "trash")
            
            returnedAction = deleteAction
        }
        
        return [returnedAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        
        if orientation == .right {
            options.expansionStyle = .destructive
        } else {
            options.expansionStyle = .destructive(automaticallyDelete: false)
        }
        
        return options
    }
    
    func removeSelectedCell(_ cellToRemove: WeatherModel, _ indexPath: IndexPath) {
        self.userLocations.removeAll { (name) -> Bool in
            name == cellToRemove.cityName
        }

        self.weatherData.remove(at: indexPath.row)
        saveUserData()
        
    }
    
    //MARK: - UITableViewDragDelegates
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        
        if destinationIndexPath.row != 0 {
            let item = weatherData[sourceIndexPath.row]
            weatherData.remove(at: sourceIndexPath.row)
            weatherData.insert(item, at: destinationIndexPath.row)
            
            saveUserData()
        } else {
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        return indexPath.row != 0 ? [UIDragItem(itemProvider: NSItemProvider())] : []
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }

        return true
    }

    //MARK: - User Data
    
    func loadUserData() {
        
        userLocations = userDefaults.stringArray(forKey: "UserLocations") ?? []
        
        weatherData = [WeatherModel](repeating: WeatherModel(cityName: "", dayForecast: [], fromLocation: false), count: userLocations.count + 1)
        weatherData[0] = WeatherModel(cityName: "empty", dayForecast: [], fromLocation: true)
        print(userLocations)
        
        
        for i in 0..<userLocations.count {
            locationWithIndexRow[userLocations[i]] = i + 1
        }
        
        print(locationWithIndexRow)
        
        for location in userLocations {
            weatherManager.fetchWeatherData(for: location)
        }
    }
    
    func saveUserData() {
        userLocations = []
        
        for i in 1..<weatherData.count {
            userLocations.append(weatherData[i].cityName)
        }
        
        userDefaults.set(userLocations, forKey: "UserLocations")
    }
}
