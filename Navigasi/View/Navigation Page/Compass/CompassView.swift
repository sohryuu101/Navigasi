//
//  CompassView.swift
//  Testestes
//
//  Created by Akbar Febry on 07/05/25.
//

import SwiftUI

// Update your CompassView to use smoother animations

struct CompassView: View {
    @Binding var userHeading: Double
    @Binding var targetHeading: Double
    @Binding var isOnCorrectPath: Bool
    
    // Constants for compass sizing
    private let compassSize: CGFloat = 240
    private let indicatorSize: CGFloat = 40
    
    var body: some View {
        ZStack {
            // Compass ring that rotates with user heading
            CompassRing(size: compassSize)
                .rotationEffect(Angle(degrees: userHeading))
                // Use more sophisticated animation
                .animation(
                    .interpolatingSpring(
                        mass: 1.0,
                        stiffness: 50,
                        damping: 10,
                        initialVelocity: 0
                    ),
                    value: userHeading
                )
            
            // Center arrow - fixed pointing up
            Image(systemName: isOnCorrectPath ? "location.north.fill" : "location.north")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(isOnCorrectPath ? .blue : .red)
            
            // Destination indicator that stays fixed relative to compass rotation
            PositionedIndicator(
                angle: targetHeading - userHeading,
                compassRadius: compassSize/2,
                indicatorSize: indicatorSize
            )
            .animation(.linear(duration: 0.15), value: userHeading)
            .animation(.linear(duration: 0.15), value: targetHeading)
        }
    }
}
// Separate component for the compass ring with markings
struct CompassRing: View {
    let size: CGFloat
    
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: size, height: size)
            .shadow(radius: 5)
    }
}

// Helper view to position the indicator around the compass
struct PositionedIndicator: View {
    let angle: Double
    let compassRadius: CGFloat
    let indicatorSize: CGFloat
    
    var body: some View {
        // Calculate position on the circle's circumference
        // Subtract 90 degrees to align with north at 0 degrees
        let positionAngle = Angle(degrees: angle - 90)
        let x = cos(positionAngle.radians) * (compassRadius - indicatorSize/2)
        let y = sin(positionAngle.radians) * (compassRadius - indicatorSize/2)
        
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: indicatorSize, height: indicatorSize)
                .shadow(radius: 2)
            
            Image(systemName: "bus.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.blue)
                .frame(width: indicatorSize/2, height: indicatorSize/2)
        }
        .offset(x: x, y: y)
    }
}

#Preview {
    CompassView(userHeading: .constant(0), targetHeading: .constant(45), isOnCorrectPath: .constant(true))
}
