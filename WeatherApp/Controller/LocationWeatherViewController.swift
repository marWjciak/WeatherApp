//
//  LocationWeatherViewController.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 17/01/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import CoreLocation
import Network
import SwipeCellKit
import UIKit

class LocationWeatherViewController: UITableViewController, CLLocationManagerDelegate, WeatherManagerDelegate, SwipeTableViewCellDelegate, UITableViewDragDelegate {
    let userDefaults = UserDefaults.standard
    let locationManager = CLLocationManager()
    var weatherManager = WeatherManager()

    var userLocations = [String]()
    var weatherData = [WeatherModel(cityName: K.emptyCityName, dayForecasts: [], fromLocation: true)]
    var locationWithIndexRow: [String: Int] = [:]
    var isLoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: K.LocationWeatherCell.nibName, bundle: nil), forCellReuseIdentifier: K.LocationWeatherCell.identifier)

        turnOnNetworkMonitor()
        defineNetworkStatusControllers()

        weatherManager.delegate = self

        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.delegate = self
        locationManager.requestLocation()

        // move cell
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(loadAllData), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    // check why after reloading data UI blinks

    /*
     reload data in background
     show loading status (non intrusive)
     wait for data before touching table
     update table without UI blink
     check location dissapearing??
     load/reload/update data on table pull down
     **/

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !isLoaded {
            loadAllData()
        }
    }

    @objc func loadAllData() {
        locationManager.requestLocation()
        loadUserData()
        fetchUserData()

        isLoaded = true
    }

    // MARK: - Add User Location

    @IBAction func addLocationPressed(_ sender: UIBarButtonItem) {
        var locationName = UITextField()

        let alert = UIAlertController(title: "Add New User Location", message: "Please type city name", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "City Name"
            locationName = textField
        }

        let addUserLocation = UIAlertAction(title: "Add", style: .default) { _ in

            guard let locationNameString = locationName.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                return
            }

            guard !self.weatherData.contains(where: { (location) -> Bool in
                location.cityName == locationNameString
            }) else { return }

            if !locationNameString.isEmpty {
                self.weatherManager.fetchWeatherData(for: locationNameString)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(cancelAction)
        alert.addAction(addUserLocation)
        alert.preferredAction = addUserLocation
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Location Manager Delegate

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

    // MARK: - Weather Manager Delegate

    func weatherDataDidUpdate(_: WeatherManager, weather: WeatherModel) {
        if weather.fromLocation == true, !weather.cityName.isEmpty {
            weatherData[0] = weather

        } else {
            guard !containCity(weather.cityName) else { return }

            if containsWeatherData(weather) {
                if let cityIndex = locationWithIndexRow[weather.cityName] {
                    weatherData.remove(at: cityIndex)
                    weatherData.insert(weather, at: cityIndex)
                }
            } else {
                weatherData.append(weather)
                DispatchQueue.main.async {
                    let indexPath = IndexPath(row: self.weatherData.count - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }

        saveUserData()

        if !containCity("empty") {
            tableView.reloadData()
        }

    }

    private func containCity(_ cityName: String) -> Bool {
        return weatherData.contains(where: { (data) -> Bool in
            data.cityName == cityName
        })
    }

    private func containsWeatherData(_ weather: WeatherModel) -> Bool {
        if locationWithIndexRow.keys.contains(weather.cityName) {
            return true
        } else {
            return false
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.LocationWeatherCell.identifier, for: indexPath) as! LocationWeatherCell
        cell.configureFor(weatherData[indexPath.row], andDelegate: self)

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if weatherData[indexPath.row].dayForecasts.isEmpty {
            return 0
        }

        return tableView.bounds.size.height / 4
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.LocationWeatherCell.cellDetailsSegue, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! FiveDaysWeatherController

        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.forecasts = weatherData[indexPath.row]
        }
    }

    // MARK: - SwipeTableViewCellDelegate

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let returnedAction: SwipeAction

        if indexPath.row == 0 {
            guard orientation == .left else { return nil }

            let reloadLocationAction = SwipeAction(style: .default, title: "Refresh") { _, indexPath in

                self.tableView.reloadRows(at: [indexPath], with: .left)
                self.locationManager.requestLocation()
            }

            reloadLocationAction.image = UIImage(systemName: "arrow.uturn.right")
            reloadLocationAction.backgroundColor = .blue

            returnedAction = reloadLocationAction

        } else {
            guard orientation == .right else { return nil }

            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { _, indexPath in

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
        weatherData.remove(at: indexPath.row)
        locationWithIndexRow.removeValue(forKey: cellToRemove.cityName)
        saveUserData()
    }

    // MARK: - UITableViewDragDelegates

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

    // MARK: - User Data

    func loadUserData() {
        userLocations = userDefaults.stringArray(forKey: K.userLocationsKey) ?? []

        weatherData = [WeatherModel](repeating: WeatherModel(cityName: K.emptyCityName, dayForecasts: [], fromLocation: false), count: userLocations.count + 1)
        weatherData[0] = WeatherModel(cityName: K.emptyCityName, dayForecasts: [], fromLocation: true)
        print(userLocations)

        locationWithIndexRow = getLocationIndexes(userLocations: userLocations)

        print(locationWithIndexRow)
    }

    func saveUserData() {
        userLocations = []

        for i in 1..<weatherData.count {
            let cityName = weatherData[i].cityName
            let forecast = weatherData[i].dayForecasts

            if !cityName.elementsEqual(K.emptyCityName), !forecast.isEmpty {
                userLocations.append(weatherData[i].cityName)
            }
        }

        userDefaults.set(userLocations, forKey: K.userLocationsKey)
    }

    private func getLocationIndexes(userLocations: [String]) -> [String: Int] {
        var locationsWithIndex: [String: Int] = [:]

        for i in 0..<userLocations.count {
            locationsWithIndex[userLocations[i]] = i + 1
        }

        return locationsWithIndex
    }

    private func fetchUserData() {
        for location in userLocations {
            weatherManager.fetchWeatherData(for: location)
        }
    }

    // MARK: - Network Monitor

    private func turnOnNetworkMonitor() {
        NetworkStatusController.shared.startMonitoring()
    }

    private func turnOffNetworkMonitor() {
        NetworkStatusController.shared.stopMonitoring()
    }

    private func defineNetworkStatusControllers() {
        NetworkStatusController.shared.didStartMonitoringHandler = { () in
            print("Start Monitoring")
        }

        NetworkStatusController.shared.didStopMonitoringHandler = { () in
            print("Stop Monitoring")
        }

        NetworkStatusController.shared.netStatusChangeHandler = { [unowned self] in
            let connectionImage = UIImage(systemName: "wifi.slash")

            if NetworkStatusController.shared.isConnected {
                DispatchQueue.main.async {
                    self.navigationItem.titleView = nil
                }
                self.loadAllData()
            } else {
                DispatchQueue.main.async {
                    let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                    let connectionImageView = UIImageView(image: connectionImage)
                    connectionImageView.center = CGPoint(x: connectionImageView.center.x - 60, y: connectionImageView.center.y)
                    titleView.addSubview(connectionImageView)
                    
                    let label = UILabel(frame: CGRect(x: 30, y: 0, width: 120, height: 24))
                    label.text = "No Connection"
                    label.center = CGPoint(x: label.center.x - 60, y: label.center.y)
                    titleView.addSubview(label)

                    self.navigationItem.titleView = titleView
                    self.navigationItem.titleView?.sizeToFit()
                }
            }
        }
    }
}
