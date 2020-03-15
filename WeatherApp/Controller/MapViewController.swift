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

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(systemName: "list.dash"), style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = backButton

        NotificationCenter.default.addObserver(self, selector: #selector(loadAllLocations), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addSavedLocations), name: NSNotification.Name("reloadPinedLocations"), object: nil)

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
        navigationController?.popViewController(animated: false)
    }

    @objc private func longPressAction(longGesture: UILongPressGestureRecognizer) {
        let point = longGesture.location(in: mapView)
        let pointCoords = mapView.convert(point, toCoordinateFrom: mapView)
        let coordData: [String : String] = ["lat" : String(pointCoords.latitude),
                                            "long" : String(pointCoords.longitude)]

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addLocationFromMap"), object: nil, userInfo: coordData)

    }

    // MARK: - Pin Methods

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Placemark"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true

        } else {
            annotationView?.annotation = annotation
        }

        let forecastAnnotation = annotation as! ForecastPin
        if let safeImage = forecastAnnotation.image {
            let annotationImage = UIImage(systemName: safeImage)?
                .withConfiguration(UIImage.SymbolConfiguration(weight: .regular))
                .withTintColor(K.color, renderingMode: .alwaysTemplate)
            let size = CGSize(width: 40, height: 40)
            annotationView?.image = UIGraphicsImageRenderer(size: size).image { _ in
                annotationImage?.draw(in: CGRect(origin: .zero, size: size))
            }
        }

        return annotationView
    }

    private func addPoint(with coortinate: CLLocationCoordinate2D, _ title: String, _ subtitle: String, _ image: String) {
        let annotation = ForecastPin(title: title,
                                     subtitle: "\(subtitle)°C",
                                     coordinate: CLLocationCoordinate2D(latitude: coortinate.latitude,
                                                                        longitude: coortinate.longitude),
                                     image: image)

        mapView.addAnnotation(annotation)
    }

    @objc private func addSavedLocations() {
        weatherData = Locations.shared.globalWeatherData
        guard let locations = weatherData else { return }

        for location in locations {
            let city = location.cityName
            let forecast = location.dayForecasts[0]

            if location.fromLocation {
                guard let _currentLocation = currentLocation else { return }
                addPoint(with: _currentLocation.coordinate, "Current Location", String(forecast.temp), forecast.icon)
            } else {
                getLocation(for: city) { placemark in
                    if let coordinate = placemark?.location?.coordinate {
                        self.addPoint(with: coordinate, city, String(forecast.temp), forecast.icon)
                    }
                }
            }
        }
    }

    @objc private func loadAllLocations() {
        mapView.removeAnnotations(mapView.annotations)
        addSavedLocations()
        centerMapOnCurrentLocation()
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
