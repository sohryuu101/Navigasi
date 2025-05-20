//
//  Route.swift
//  Navigasi
//
//  Created by Akbar Febry on 15/05/25.
//

import Foundation
import CoreLocation
import SwiftUI

// Custom Route class
class Route {
    var steps: [Step] = []
    var distance: Double // Total distance in meters
    var expectedTravelTime: TimeInterval // Total expected travel time in seconds
    var name: String
    var polyline: [CLLocationCoordinate2D] // Array of coordinates forming the route path
    
    // Nested Step class
    class Step {
        var instructions: String
        var instructionImage: String
        var distance: Double // Distance in meters
        var expectedTravelTime: TimeInterval // Expected travel time in seconds
        var startLocation: CLLocationCoordinate2D
        var endLocation: CLLocationCoordinate2D
        var heading: Double // Heading direction in degrees (0-360)
        var polyline: [CLLocationCoordinate2D] // Coordinates for this step
        
        var image: Image {
            Image(systemName: instructionImage)
        }
        
        init(instructions: String,
             instructionImage: String,
             distance: Double,
             expectedTravelTime: TimeInterval,
             startLocation: CLLocationCoordinate2D,
             endLocation: CLLocationCoordinate2D,
             heading: Double,
             polyline: [CLLocationCoordinate2D]) {
            self.instructions = instructions
            self.instructionImage = instructionImage
            self.distance = distance
            self.expectedTravelTime = expectedTravelTime
            self.startLocation = startLocation
            self.endLocation = endLocation
            self.heading = heading
            self.polyline = polyline
        }
        
        // Helper method to get formatted distance
        func formattedDistance() -> String {
            if distance < 1000 {
                return "\(Int(distance)) m"
            } else {
                return String(format: "%.1f km", distance/1000)
            }
        }
    }
    
    init(name: String, distance: Double, expectedTravelTime: TimeInterval, polyline: [CLLocationCoordinate2D]) {
        self.name = name
        self.distance = distance
        self.expectedTravelTime = expectedTravelTime
        self.polyline = polyline
    }
    
    // Helper method to add a step
    func addStep(_ step: Step) {
        steps.append(step)
    }
    
    // Helper method to get formatted total distance
    func formattedTotalDistance() -> String {
        if distance < 1000 {
            return "\(Int(distance)) m"
        } else {
            return String(format: "%.1f km", distance/1000)
        }
    }
    
    // Helper method to get formatted total time
    func formattedTotalTime() -> String {
        let minutes = Int(expectedTravelTime / 60)
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours) h \(remainingMinutes) min"
        }
    }
}
