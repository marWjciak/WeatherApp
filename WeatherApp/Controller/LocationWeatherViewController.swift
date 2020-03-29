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

class LocationWeatherViewController: UITableViewController, CLLocationManagerDelegate, WeatherManagerDelegate, SwipeTableViewCellDelegate, UITableViewDragDelegate, ForecastPinManagerDelegate {
    let userDefaults = UserDefaults.standard
    let locationManager = CLLocationManager()
    var weatherManager = WeatherManager()
    var forecastPinManager = ForecastPinManager()

    var userLocations = [String]()
    var weatherData = [WeatherModel(cityName: K.emptyCityName, dayForecasts: [], fromLocation: true)]
    var locationWithIndexRow: [String: Int] = [:]
    var isLoaded = false

    @IBAction func mapButtonAction(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: K.LocationWeatherCell.listToMap, sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: K.LocationWeatherCell.nibName, bundle: nil), forCellReuseIdentifier: K.LocationWeatherCell.identifier)

        configureTableViewRefreshAction()
        turnOnNetworkMonitor()
        defineNetworkStatusControllers()

        weatherManager.delegate = self
        forecastPinManager.delegate = self

        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.delegate = self
        locationManager.requestLocation()

        // move cell
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(loadAllData), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeLocation(_ :)), name: NSNotification.Name("removeLocation"), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !isLoaded {
            loadAllData()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        if LoadingIndicator.isRunning {
            DispatchQueue.main.async {
                LoadingIndicator.update()
            }
        }
    }

    @objc func loadAllData() {
        DispatchQueue.main.async {
            if !self.refreshControl!.isRefreshing {
                LoadingIndicator.start(on: self.view)
            } else {
                self.refreshControl?.beginRefreshing()
            }
        }
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

    @objc private func addLocationFromMap(_ notification: NSNotification) {
        if let coords = notification.userInfo as NSDictionary? {
            if let latitude = coords["lat"] as? String, let longitude = coords["long"] as? String{
                weatherManager.fetchWeatherData(latitude: latitude, longitude: longitude, fromLocation: false)
            }
        }
    }

    @objc private func removeLocation(_ notification: NSNotification) {
        if let userData = notification.userInfo as NSDictionary? {
            let cityName = userData["city"] as! String
            print(cityName)

            let indexToRemove = weatherData.firstIndex { data -> Bool in
                data.cityName == cityName
            }

            if let index = indexToRemove {
                removeSelectedCell(weatherData[index], index)
            }

            tableView.reloadData()
        }
    }

    // MARK: - Location Manager Delegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }

        let lat = String(location.coordinate.latitude)
        let lon = String(location.coordinate.longitude)
        Locations.shared.currentLocation = location

        weatherManager.fetchWeatherData(latitude: lat, longitude: lon, fromLocation: true)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Cannot get current location, \(error)")
    }

    // MARK: - Weather Manager Delegate

    func weatherDataDidUpdate(_: WeatherManager, weather: WeatherModel) {
        if weather.fromLocation == true, !weather.cityName.isEmpty {
            weatherData[0] = weather

        } else {
            guard !containCity(weather.cityName, weather.latitude, weather.longitude) else { return }

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

        if !containsCityName("empty") {
            DispatchQueue.main.async {
                if self.refreshControl!.isRefreshing {
                    self.refreshControl?.endRefreshing()
                } else {
                    LoadingIndicator.stop()
                }
            }
            tableView.reloadData()
        }
        NotificationCenter.default.post(name: NSNotification.Name("addPoint"), object: nil, userInfo: ["pin" : weather])
    }

    private func containCity(_ cityName: String, _ latitude: Double, _ longitude: Double) -> Bool {
        return containsCityName(cityName) || containsCoordinates(latitude, longitude)
    }

    private func containsCityName(_ cityName: String) -> Bool {
        return weatherData.contains(where: { (data) -> Bool in
            data.cityName == cityName
        })
    }

    private func containsCoordinates(_ lat: Double, _ lon: Double) -> Bool {
        return weatherData.contains { (data) -> Bool in
            data.latitude == lat && data.longitude == lon
        }
    }

    private func containsWeatherData(_ weather: WeatherModel) -> Bool {
        if locationWithIndexRow.keys.contains(weather.cityName) {
            return true
        } else {
            return false
        }
    }

    // MARK: - TableView Data Source

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

        return tableView.bounds.size.height / 5
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.LocationWeatherCell.cellDetailsSegue, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case K.LocationWeatherCell.cellDetailsSegue:
                let destinationVC = segue.destination as! FiveDaysWeatherController

                if let indexPath = tableView.indexPathForSelectedRow {
                    destinationVC.forecasts = weatherData[indexPath.row]
                }
            case K.LocationWeatherCell.listToMap:
                UIView.transition(from: self.view,
                                  to: segue.destination.view,
                                          duration: 0.5,
                                          options: UIView.AnimationOptions.transitionFlipFromLeft,
                                          completion: nil)
            default:
                return
        }
    }

    // MARK: - TableView Actions

    private func configureTableViewRefreshAction() {
        let refreshControl = UIRefreshControl()
        let attributes = [NSAttributedString.Key.foregroundColor: K.color]
        refreshControl.attributedTitle = NSAttributedString(string: "Forecast Updating...", attributes: attributes)

        refreshControl.addTarget(self, action: #selector(loadAllData), for: .valueChanged)

        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.backgroundView = refreshControl
        }
    }

    // MARK: - SwipeTableViewCellDelegate

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let returnedAction: SwipeAction

        guard orientation == .right, indexPath.row != 0 else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { _, indexPath in

            let cellToRemove = self.weatherData[indexPath.row]

            self.removeSelectedCell(cellToRemove, indexPath.row)
        }

        deleteAction.image = UIImage(systemName: "trash")

        returnedAction = deleteAction

        return [returnedAction]
    }

    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive

        return options
    }

    func removeSelectedCell(_ cellToRemove: WeatherModel, _ row: Int) {
        weatherData.remove(at: row)
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

        Locations.shared.globalWeatherData = weatherData
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

    //MARK: - Forecast Pin Delegate

    func newLocationDidAdd(_: ForecastPinManager, with coords: CLLocationCoordinate2D) {
        let lat = String(coords.latitude)
        let lon = String(coords.longitude)
        weatherManager.fetchWeatherData(latitude: lat, longitude: lon, fromLocation: false)
    }
}
