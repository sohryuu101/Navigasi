//
//  ViewModelel.swift
//  Testestes
//
//  Created by Akbar Febry on 10/05/25.
//

import SwiftUI
import Foundation
import MapKit
import CoreMotion
import CoreLocation
import ActivityKit

enum NavigationJourney {
    case running
    case completed
}

class ViewModelel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocation?
    @Published var userHeading: Double = 0
    @Published var targetHeading: Double = 0
    @Published var distanceToNextPoint: Double = 0
    @Published var isOnCorrectPath: Bool = true
    @Published var currentStep: String = "Go Straight"
    @Published var currentStepImage: Image = Image(systemName: "arrow.up")
    @Published var route: Route?
    @Published var routeSteps: [Route.Step] = []
    @Published var currentStepIndex: Int = 0
    @Published var journey: NavigationJourney = .running

    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionManager()

    // Destination points
    var destinations: [String: CLLocationCoordinate2D] = [
        "Halte BSD Link": CLLocationCoordinate2D(latitude: -6.3012246, longitude: 106.6532949),
        "Apple Developer Academy": CLLocationCoordinate2D(latitude: -6.3023062, longitude: 106.6522011)
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
            motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) { [weak self] (motion, error) in
                guard let motion = motion, error == nil else { return }
                
                // Use the heading property directly - this is already relative to true north
                self?.userHeading = motion.heading
                self?.checkIfOnPath()
            }
        }
    }

//    func calculateHeading(from motion: CMDeviceMotion) -> Double {
//        // Convert device motion data to heading angle
//        let attitude = motion.attitude
//        
//        // Get heading from attitude (this is simplified - actual implementation needs quaternion calculations)
//        let heading = atan2(2 * (attitude.quaternion.x * attitude.quaternion.y + attitude.quaternion.w * attitude.quaternion.z),
//                          attitude.quaternion.w * attitude.quaternion.w + attitude.quaternion.x * attitude.quaternion.x - attitude.quaternion.y * attitude.quaternion.y - attitude.quaternion.z * attitude.quaternion.z)
//        
//        return heading * 180 / .pi // Convert to degrees
//    }

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
        // Only update when we have reasonable accuracy
        if newHeading.headingAccuracy > 0 && newHeading.headingAccuracy <= 20 {
            // trueHeading is relative to true north, magneticHeading to magnetic north
            let heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
            
            // You might want to use a complementary filter here to combine with motion data
            // For example: userHeading = 0.9 * userHeading + 0.1 * heading
            userHeading = heading
            checkIfOnPath()
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

//    func checkIfOnPath() {
//        // Calculate the difference between user heading and target heading
//        var headingDifference = abs(userHeading - targetHeading)
//        if headingDifference > 180 {
//            headingDifference = 360 - headingDifference
//        }
//
//        // If difference is more than 30 degrees, user is heading wrong way
//        isOnCorrectPath = headingDifference <= 30
//    }
    // Add or replace this method
    func checkIfOnPath() {
        // Calculate heading difference (-180 to +180 degrees)
        let rawDifference = targetHeading - userHeading
        
        // Normalize to -180 to +180 range
        var headingDiff = rawDifference.truncatingRemainder(dividingBy: 360)
        if headingDiff > 180 {
            headingDiff -= 360
        } else if headingDiff < -180 {
            headingDiff += 360
        }
        
        // Update isOnCorrectPath based on the heading difference
        // Consider on path if within ±30 degrees of the target heading
        isOnCorrectPath = abs(headingDiff) <= 30
        
        // Update distanceToNextPoint if needed
        if let userLocation = userLocation, let nextWaypoint = getCurrentWaypointCoordinate() {
            let nextLocation = CLLocation(latitude: nextWaypoint.latitude, longitude: nextWaypoint.longitude)
            distanceToNextPoint = userLocation.distance(from: nextLocation)
        }
    }

    func getCurrentWaypointCoordinate() -> CLLocationCoordinate2D? {
        guard currentStepIndex < routeSteps.count else { return nil }
        
        // Return the end location of the current step as the next waypoint
        return routeSteps[currentStepIndex].endLocation
    }

    func moveToNextWaypoint() {
        currentStepIndex += 1
        if currentStepIndex < routeSteps.count {
            // Update the current step instructions
            currentStep = routeSteps[currentStepIndex].instructions
            
            // Update the current step image
            currentStepImage = routeSteps[currentStepIndex].image
            
            // Update the target heading based on the new step's heading
            targetHeading = routeSteps[currentStepIndex].heading
        } else {
            // Reached final destination
            journey = .completed
            currentStep = "Arrived at destination"
        }
    }

    func startNavigation(to destinationName: String) {
        guard let userLocation = userLocation?.coordinate,
              let destinationCoordinate = destinations[destinationName] else {
            return
        }
        
        // Reset current step index
        currentStepIndex = 0
        
        // Reset enum
        journey = .running
        
        // Generate a custom route between the points
        createCustomRouteBetween(start: userLocation, end: destinationCoordinate, name: destinationName)
    }

    func improvedHeadingCalculation() {
        // More advanced sensor fusion using complementary or Kalman filter
        motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) { [weak self] (motion, error) in
            guard let motion = motion else { return }
            
            // This uses magnetic north reference and gives better heading info
            let heading = motion.heading
            self?.userHeading = heading
        }
    }

    func createCustomRoute() {
        // Create route coordinates
        let polyline: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: -6.3020963, longitude: 106.6521549), // Starting point
            CLLocationCoordinate2D(latitude: -6.3019084, longitude: 106.6521452),
            CLLocationCoordinate2D(latitude: -6.3015344, longitude: 106.6524264),
            CLLocationCoordinate2D(latitude: -6.3015396, longitude: 106.6526969),
            CLLocationCoordinate2D(latitude: -6.3015978, longitude: 106.6531169),
            CLLocationCoordinate2D(latitude: -6.3013748, longitude: 106.6531418)
        ]
        
        // Create the route
        let customRoute = Route(
            name: "Apple Academy to BSD Link",
            distance: 188, // meters
            expectedTravelTime: 137, // sekon
            polyline: polyline
        )
        
        // Create and add steps
        let step1 = Route.Step( // okay
            instructions: "Follow the Icon",
            instructionImage: "arrow.up",
            distance: 21,
            expectedTravelTime: 15,
            startLocation: polyline[0],
            endLocation: polyline[1],
            heading: 0,
            polyline: [polyline[0], polyline[1]]
        )
        
        let step2 = Route.Step(
            instructions: "Slight right, then walk straight",
            instructionImage: "arrow.up.right",
            distance: 52,
            expectedTravelTime: 40,
            startLocation: polyline[1],
            endLocation: polyline[2],
            heading: 38, //
            polyline: [polyline[1], polyline[2]]
        )
        
        let step3 = Route.Step(
            instructions: "Slight right again",
            instructionImage: "arrow.turn.up.right",
            distance: 30,
            expectedTravelTime: 13,
            startLocation: polyline[2],
            endLocation: polyline[3],
            heading: 92, //
            polyline: [polyline[2], polyline[3]]
        )
        
        let step4 = Route.Step(
            instructions: "Walk down the stairs and cross the road",
            instructionImage: "figure.stairs",
            distance: 47,
            expectedTravelTime: 12,
            startLocation: polyline[3],
            endLocation: polyline[4],
            heading: 98, //
            polyline: [polyline[3], polyline[4]]
        )
        
        let step5 = Route.Step(
            instructions: "Turn left then you will arrived",
            instructionImage: "arrow.turn.up.left",
            distance: 25,
            expectedTravelTime: 12,
            startLocation: polyline[4],
            endLocation: polyline[5],
            heading: 6, //
            polyline: [polyline[4], polyline[5]]
        )
        
        // Add steps to route
        customRoute.addStep(step1)
        customRoute.addStep(step2)
        customRoute.addStep(step3)
        customRoute.addStep(step4)
        customRoute.addStep(step5)
        
        // Update published properties
        self.route = customRoute
        self.routeSteps = customRoute.steps
        
        // Set initial step
        if !routeSteps.isEmpty {
            currentStep = routeSteps[0].instructions
            targetHeading = routeSteps[0].heading
        }
    }

    // Generate a route between arbitrary points
    func createCustomRouteBetween(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, name: String) {
        // Calculate distance between points
        let startLocation = CLLocation(latitude: start.latitude, longitude: start.longitude)
        let endLocation = CLLocation(latitude: end.latitude, longitude: end.longitude)
        let totalDistance = startLocation.distance(from: endLocation)
        
        // Create direct route (as the crow flies)
        let polyline = [start, end]
        
        // Calculate bearing between points
        let bearing = calculateBearing(from: start, to: end)
        
        // Create the route
        let customRoute = Route(
            name: "Route to \(name)",
            distance: totalDistance,
            expectedTravelTime: totalDistance / 1.4, // Assuming 1.4 m/s walking speed
            polyline: polyline
        )
        
        // Create a single step for direct navigation
        let step = Route.Step(
            instructions: "Head to \(name)",
            instructionImage: "arrow.up",
            distance: totalDistance,
            expectedTravelTime: totalDistance / 1.4,
            startLocation: start,
            endLocation: end,
            heading: bearing,
            polyline: polyline
        )
        
        customRoute.addStep(step)
        
        // Update published properties
        self.route = customRoute
        self.routeSteps = customRoute.steps
        
        // Set initial step
        if !routeSteps.isEmpty {
            currentStep = routeSteps[0].instructions
            targetHeading = routeSteps[0].heading
        }
    }

    // Helper function to calculate bearing between coordinates
    func calculateBearing(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> Double {
        let lat1 = start.latitude * .pi / 180
        let lon1 = start.longitude * .pi / 180
        let lat2 = end.latitude * .pi / 180
        let lon2 = end.longitude * .pi / 180
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        var bearing = atan2(y, x)
        bearing = bearing * 180 / .pi
        bearing = (bearing + 360).truncatingRemainder(dividingBy: 360)
        
        return bearing
    }

    // Find the nearest point on the route from user's current location
    func findNearestPointOnRoute() -> CLLocationCoordinate2D? {
        guard let userLocation = userLocation, let route = route else { return nil }
        
        var nearestPoint: CLLocationCoordinate2D? = nil
        var minDistance = Double.infinity
        
        // Check each segment of the route polyline
        for i in 0..<route.polyline.count-1 {
            let start = route.polyline[i]
            let end = route.polyline[i+1]
            
            let nearestPointOnSegment = findNearestPointOnSegment(
                point: userLocation.coordinate,
                lineStart: start,
                lineEnd: end
            )
            
            let distance = calculateDistance(
                from: userLocation.coordinate,
                to: nearestPointOnSegment
            )
            
            if distance < minDistance {
                minDistance = distance
                nearestPoint = nearestPointOnSegment
            }
        }
        
        return nearestPoint
    }

    // Find nearest point on a line segment
    func findNearestPointOnSegment(point: CLLocationCoordinate2D, lineStart: CLLocationCoordinate2D, lineEnd: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        // Convert to simple 2D coordinates for projection calculation
        let x = point.longitude
        let y = point.latitude
        let x1 = lineStart.longitude
        let y1 = lineStart.latitude
        let x2 = lineEnd.longitude
        let y2 = lineEnd.latitude
        
        // Calculate projection parameters
        let dx = x2 - x1
        let dy = y2 - y1
        let len = dx * dx + dy * dy
        
        // Handle zero-length segments
        if len == 0 {
            return lineStart
        }
        
        // Calculate projection parameter
        let t = ((x - x1) * dx + (y - y1) * dy) / len
        
        if t < 0 {
            // Before the start point
            return lineStart
        } else if t > 1 {
            // After the end point
            return lineEnd
        } else {
            // On the segment
            return CLLocationCoordinate2D(
                latitude: y1 + t * dy,
                longitude: x1 + t * dx
            )
        }
    }

    // Calculate distance between coordinates
    func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }
}

