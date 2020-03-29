//
//  MapViewController.swift
//  WeatherApp
//
//  Created by Marcin Wójciak on 06/03/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import CoreLocation
import Foundation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!

    let regionRadius: CLLocationDistance = 1000
    var currentLocation: CLLocation?
    var locationList: [String]?
    var weatherData: [WeatherModel]?
    let forecastPinManager = ForecastPinManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(systemName: "list.dash"), style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = backButton

        NotificationCenter.default.addObserver(self, selector: #selector(dismissView), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addPoint(_:)), name: NSNotification.Name("addPoint"), object: nil)

        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(longGesture:)))
        mapView.addGestureRecognizer(longGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        currentLocation = Locations.shared.currentLocation
        weatherData = boxLocation(Locations.shared.globalWeatherData).value

        loadAllLocations()
    }

    private func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    private func centerMapOnCurrentLocation() {
        if let location = currentLocation {
            let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }

    @objc private func back() {
        if let topView = navigationController?.viewControllers[0].view {
            UIView.transition(from: view,
                              to: topView,
                              duration: 0.5,
                              options: UIView.AnimationOptions.transitionFlipFromRight,
                              completion: nil)
        }
        dismissView()
    }

    @objc private func longPressAction(longGesture: UILongPressGestureRecognizer) {
        let point = longGesture.location(in: mapView)
        let pointCoords = mapView.convert(point, toCoordinateFrom: mapView)

        forecastPinManager.addLocationOnMap(coordinates: CLLocationCoordinate2D(latitude: pointCoords.latitude, longitude: pointCoords.longitude))
    }

    @objc private func dismissView() {
        navigationController?.popViewController(animated: false)
    }

    // MARK: - Pin Methods

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Placemark"
        let forecastAnnotation = annotation as! ForecastPin

        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            annotationView.annotation = forecastAnnotation

            return annotationView
        } else {
            let annotationView = MKPinAnnotationView(annotation: forecastAnnotation, reuseIdentifier: identifier)
            annotationView.canShowCallout = true
            annotationView.isEnabled = true

            if let safeImage = forecastAnnotation.image {
                let annotationImage = UIImage(systemName: safeImage)?
                    .withConfiguration(UIImage.SymbolConfiguration(weight: .regular))
                    .withTintColor(K.color, renderingMode: .alwaysTemplate)
                let size = CGSize(width: 40, height: 40)
                annotationView.image = UIGraphicsImageRenderer(size: size).image { _ in
                    annotationImage?.draw(in: CGRect(origin: .zero, size: size))
                }
            }

            if let removeButton = forecastAnnotation.button {
                annotationView.rightCalloutAccessoryView = removeButton
            }

            return annotationView
        }
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation else { return }
        if let cityName = annotation.title {
            mapView.removeAnnotation(annotation)

            NotificationCenter.default.post(name: NSNotification.Name("removeLocation"), object: nil, userInfo: ["city": cityName as Any])
        }
    }

    @objc private func addSavedLocations() {
        mapView.removeAnnotations(mapView.annotations)
        weatherData = boxLocation(Locations.shared.globalWeatherData).value
        forecastPinManager.delegate = navigationController?.viewControllers[0] as! LocationWeatherViewController
        guard let locations = weatherData, !locations.contains(where: { (location) -> Bool in
            location.cityName == "empty"
        }) else { return }

        for location in locations {
            guard let annotation = forecastPinManager.createForecastAnnotation(for: location) else { return }
            mapView.addAnnotation(annotation)
        }
    }

    @objc private func loadAllLocations() {
        addSavedLocations()
        centerMapOnCurrentLocation()
    }

    @objc private func addPoint(_ notification: NSNotification) {
        let weather = notification.userInfo?["pin"] as! WeatherModel
        guard let annotation = forecastPinManager.createForecastAnnotation(for: weather) else { return }
        mapView.addAnnotation(annotation)
    }

    // MARK: - Location

    private func getLocation(for city: String, completitionHandler: @escaping (CLPlacemark?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(city) { placemarks, error in
            guard error == nil else {
                completitionHandler(nil)
                return
            }

            if let placemark = placemarks?[0] {
                completitionHandler(placemark)
            }
        }
    }
}
