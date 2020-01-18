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
        
        userLocations = userDefaults.stringArray(forKey: "UserLocations")!
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
            if self.userLocations.contains(locationName.text!) {
                return
            }
            
            self.userLocations.append(locationName.text!)
            self.userDefaults.set(self.userLocations, forKey: "UserLocations")
            if let locationNameString = locationName.text {
                self.weatherManager.fetchWeatherData(for: locationNameString)
            }
            
            //            self.tableView.reloadData()
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
    
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
