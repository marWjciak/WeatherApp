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

        NotificationCenter.default.addObserver(self, selector: #selector(loadAllLocations), name: UIApplication.willEnterForegroundNotification, object: nil)
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

    private func addSavedLocations() {
        guard let locations = weatherData else { return }

        for location in locations {
            let city = location.cityName
            let forecast = location.dayForecasts[0]

            if location.fromLocation {
                guard let _currentLocation = currentLocation else { return }
                centerMapOnLocation(_currentLocation)
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
