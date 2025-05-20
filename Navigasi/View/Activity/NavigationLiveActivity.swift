//
//  NavigationLiveActivity.swift
//  Navigasi
//
//  Created by Akbar Febry on 17/05/25.
//

import ActivityKit

struct NavigationAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var currentStep: String
        var distanceToNextPoint: Double
        var isOnCorrectPath: Bool
    }
    
    var destinationName: String
    var totalDistance: Double
}

extension ViewModelel {
    func startLiveActivity() {
        guard let route = route else { return }

        let attributes = NavigationAttributes(
            destinationName: "Halte BSD Link",
            totalDistance: route.distance
        )

        let initialContentState = NavigationAttributes.ContentState(
            currentStep: currentStep,
            distanceToNextPoint: distanceToNextPoint,
            isOnCorrectPath: isOnCorrectPath
        )

        let initialContent = ActivityContent(
            state: initialContentState,
            staleDate: nil // Optional: Specify a stale date if needed
        )

        do {
            let activity = try Activity<NavigationAttributes>.request(
                attributes: attributes,
                content: initialContent,
                pushType: nil // Use `.token` if you want to update via push notifications
            )
            print("Live Activity started: \(activity.id)")
        } catch {
            print("Failed to start Live Activity: \(error.localizedDescription)")
        }
    }

    func updateLiveActivity() {
        Task {
            let updatedContentState = NavigationAttributes.ContentState(
                currentStep: currentStep,
                distanceToNextPoint: distanceToNextPoint,
                isOnCorrectPath: isOnCorrectPath
            )

            let updatedContent = ActivityContent(
                state: updatedContentState,
                staleDate: nil // Optional: Specify a stale date if needed
            )

            for activity in Activity<NavigationAttributes>.activities {
                await activity.update(updatedContent)
            }
        }
    }

    func endLiveActivity() {
        Task {
            let finalContentState = NavigationAttributes.ContentState(
                currentStep: "Arrived at destination",
                distanceToNextPoint: 0,
                isOnCorrectPath: true
            )

            let finalContent = ActivityContent(
                state: finalContentState,
                staleDate: nil // Optional: Specify a stale date if needed
            )

            for activity in Activity<NavigationAttributes>.activities {
                await activity.end(finalContent, dismissalPolicy: .immediate)
            }
        }
    }
}
