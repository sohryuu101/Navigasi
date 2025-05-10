//
//  MapViewModel.swift
//  Navigasi
//
//  Created by Akbar Febry on 29/04/25.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var position = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -6.301616, longitude: 106.651796),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.005)
    ))
    @Published var selectedPlace: Place?
    @Published var locationManager: CLLocationManager?
    @Published var isShowingSheet: Bool = true
    @Published var searchText: String = ""
    @Published var isShowingDetails: Bool = false
    @Published var userLocation: CLLocation?
    @Published var distance: String = ""
    @Published var isStartingPoint: Bool = false
        
    func checkIfLocationIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.delegate = self
            locationManager!.startUpdatingLocation()
            
        } else {
            print("Location services are not enabled")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async {
                self.userLocation = location
            }
        }
    }
    
    func startLocationUpdates(for place: Place) {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self, let userLocation = self.userLocation else { return }
            
            let calculatedDistance = self.distanceFromUser(to: place, userLocation: userLocation)
            
            // Format distance appropriately
            if calculatedDistance >= 1000 {
                let kmDistance = calculatedDistance / 1000
                self.distance = String(format: "%.1f km", kmDistance)
            } else {
                self.distance = "\(Int(calculatedDistance))"
            }
            
            if calculatedDistance > 0 {
                timer.invalidate()
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            if let location = manager.location {
                DispatchQueue.main.async {
                    self.position = .region(MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.005)
                    ))
                }
            }
        case .restricted, .denied:
            print("Location access denied or restricted.")
        @unknown default:
            print("Unhandled case in authorization status.")
        }
    }
    
    func distanceFromUser(to place: Place, userLocation: CLLocation) -> Double {
        let placeLocation = CLLocation(latitude: place.coordinates.latitude, longitude: place.coordinates.longitude)
        return userLocation.distance(from: placeLocation)
    }
    
}
