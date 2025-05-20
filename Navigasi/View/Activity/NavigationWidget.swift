//
//  NavigationWidget.swift
//  Navigasi
//
//  Created by Akbar Febry on 17/05/25.
//

import WidgetKit
import SwiftUI
import ActivityKit

struct NavigationWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NavigationAttributes.self) { context in
            // Lock Screen and Dynamic Island content
            VStack(alignment: .leading) {
                Text("Navigating to \(context.attributes.destinationName)")
                    .font(.headline)

                Text(context.state.currentStep)
                    .font(.subheadline)

                Text("\(Int(context.state.distanceToNextPoint)) meters remaining")
                    .font(.footnote)
                    .foregroundColor(context.state.isOnCorrectPath ? .green : .red)
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded view
                DynamicIslandExpandedRegion(.leading) {
                    Text("Step")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(Int(context.state.distanceToNextPoint)) m")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.currentStep)
                }
            } compactLeading: {
                Text("Nav")
            } compactTrailing: {
                Text("\(Int(context.state.distanceToNextPoint)) m")
            } minimal: {
                Text("Nav")
            }
        }
    }
}
