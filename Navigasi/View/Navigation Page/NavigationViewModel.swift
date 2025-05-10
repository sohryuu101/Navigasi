//
//  Compass.swift
//  Testestes
//
//  Created by Akbar Febry on 07/05/25.
//

import SwiftUI
import CoreLocation
import CoreMotion
import MapKit

class MyNavigationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocation?
    @Published var userHeading: Double = 0
    @Published var targetHeading: Double = 0
    @Published var distanceToNextPoint: Double = 0
    @Published var isOnCorrectPath: Bool = true
    @Published var currentStep: String = "Go Straight"
    @Published var route: MKRoute?
    @Published var routeSteps: [MKRoute.Step] = []
    @Published var currentStepIndex: Int = 0
    
    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionManager()
    
    // Destination points
    var destinations: [String: CLLocationCoordinate2D] = [
        "Halte BSD Link": CLLocationCoordinate2D(latitude: -6.301, longitude: 106.652),
        "Apple Developer Academy": CLLocationCoordinate2D(latitude: -6.302, longitude: 106.651)
    ]
    
    override init() {
        super.init()
        setupLocationServices()
        setupMotionServices()
    }
    
    func setupLocationServices() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func setupMotionServices() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
                guard let motion = motion, error == nil else { return }
                
                // Get device orientation relative to magnetic north
                if let heading = self?.calculateHeading(from: motion) {
                    self?.userHeading = heading
                    self?.checkIfOnPath()
                }
            }
        }
    }
    
    func calculateHeading(from motion: CMDeviceMotion) -> Double {
        // Convert device motion data to heading angle
        let attitude = motion.attitude
        
        // Get heading from attitude (this is simplified - actual implementation needs quaternion calculations)
        let heading = atan2(2 * (attitude.quaternion.x * attitude.quaternion.y + attitude.quaternion.w * attitude.quaternion.z),
                          attitude.quaternion.w * attitude.quaternion.w + attitude.quaternion.x * attitude.quaternion.x - attitude.quaternion.y * attitude.quaternion.y - attitude.quaternion.z * attitude.quaternion.z)
        
        return heading * 180 / .pi // Convert to degrees
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
        
        // Update distance to next waypoint
        if let nextWaypoint = getCurrentWaypointCoordinate() {
            let nextWaypointLocation = CLLocation(latitude: nextWaypoint.latitude, longitude: nextWaypoint.longitude)
            distanceToNextPoint = location.distance(from: nextWaypointLocation)
            
            // Update target heading based on current location and next waypoint
            updateTargetHeading(to: nextWaypoint)
            
            // Check if reached waypoint
            if distanceToNextPoint < 10 { // Within 10 meters
                moveToNextWaypoint()
            }
        }
        
        checkIfOnPath()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // This gives the compass heading (different from device orientation)
        // We can use this for more accurate heading when the device is held flat
        if newHeading.headingAccuracy > 0 {
            // Only update if accuracy is valid
            // Combine this with device motion data for best results
        }
    }
    
    func updateTargetHeading(to coordinate: CLLocationCoordinate2D) {
        guard let userLocation = userLocation else { return }
        
        // Calculate bearing to target
        let lat1 = userLocation.coordinate.latitude * .pi / 180
        let lon1 = userLocation.coordinate.longitude * .pi / 180
        let lat2 = coordinate.latitude * .pi / 180
        let lon2 = coordinate.longitude * .pi / 180
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        var bearing = atan2(y, x)
        bearing = bearing * 180 / .pi
        bearing = (bearing + 360).truncatingRemainder(dividingBy: 360)
        
        targetHeading = bearing
    }
    
    func checkIfOnPath() {
        // Calculate the difference between user heading and target heading
        var headingDifference = abs(userHeading - targetHeading)
        if headingDifference > 180 {
            headingDifference = 360 - headingDifference
        }
        
        // If difference is more than 45 degrees, user is heading wrong way
        isOnCorrectPath = headingDifference <= 45
    }
    
    func calculateRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: from)
        let destinationPlacemark = MKPlacemark(coordinate: to)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let response = response, error == nil else { return }
            
            self?.route = response.routes.first
            self?.routeSteps = response.routes.first?.steps ?? []
            self?.currentStepIndex = 0
            if let firstStep = self?.routeSteps.first {
                self?.currentStep = firstStep.instructions
            }
        }
    }
    
    func getCurrentWaypointCoordinate() -> CLLocationCoordinate2D? {
        guard currentStepIndex < routeSteps.count else { return nil }
        return routeSteps[currentStepIndex].polyline.coordinate
    }
    
    func moveToNextWaypoint() {
        currentStepIndex += 1
        if currentStepIndex < routeSteps.count {
            currentStep = routeSteps[currentStepIndex].instructions
        } else {
            // Reached final destination
            currentStep = "Arrived at destination"
        }
    }
    
    func startNavigation(to destinationName: String) {
        guard let userLocation = userLocation?.coordinate,
              let destinationCoordinate = destinations[destinationName] else {
            return
        }
        
        calculateRoute(from: userLocation, to: destinationCoordinate)
    }
    
    func improvedHeadingCalculation() {
        // More advanced sensor fusion using complementary or Kalman filter
        motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) { [weak self] (motion, error) in
            guard let motion = motion else { return }
            
            // This uses magnetic north reference and gives better heading info
            // The heading is available directly from attitude.yaw
            let heading = motion.heading
            self?.userHeading = heading
        }
    }
    
    func recalculateRouteIfNeeded() {
        // If user is significantly off route (more than X meters)
        guard let userLocation = userLocation?.coordinate,
              let route = route else { return }
        
        // Check if user is far from the route
        let userLocationPoint = MKMapPoint(userLocation)
        let routeRect = route.polyline.boundingMapRect
//        let threshold: Double = 50 // meters
        
        if routeRect.contains(userLocationPoint) == false {
            // User is off the route, recalculate
            if let destination = destinations["Apple Developer Academy"] {
                calculateRoute(from: userLocation, to: destination)
            }
        }
    }
    
}
