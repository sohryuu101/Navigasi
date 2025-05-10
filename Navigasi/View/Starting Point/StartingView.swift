//
//  StartingView.swift
//  Navigasi
//
//  Created by Akbar Febry on 07/05/25.
//

import SwiftUI

struct StartingView: View {
    @State private var selectedPoint: String?
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    // Light blue for selection highlight
    let lightBlue = Color(red: 0.9, green: 0.95, blue: 1)
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Pick a Starting Point")
                    .bold(true)
                    .padding(.bottom, 50)
                    .foregroundColor(Color(.label))
                
                // Point A
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color("primer"))
                        
                        Text("A")
                            .foregroundColor(.white)
                    }
                    .frame(width: 40, height: 40, alignment: .center)
                    
                    VStack(alignment: .leading) {
                        Text("Halte BSD Link")
                            .bold(true)
                        
                        Text("Near Your Location")
                            .font(.caption)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(selectedPoint == "A" ? Color("sekunder") : Color.clear)
                .cornerRadius(8)
                .onTapGesture {
                    withAnimation(.spring()) {
                        selectedPoint = "A"
                    }
                }
                
                // Point B
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color("primer"))
                        
                        Text("B")
                            .foregroundColor(.white)
                    }
                    .frame(width: 40, height: 40, alignment: .center)
                    
                    Text("Gate 1 Green Office Park")
                        .bold(true)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(selectedPoint == "B" ? Color("sekunder") : Color.clear)
                .cornerRadius(8)
                .onTapGesture {
                    withAnimation(.spring()) {
                        selectedPoint = "B"
                    }
                }
                
                // Point C
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color("primer"))
                        
                        Text("C")
                            .foregroundColor(.white)
                    }
                    .frame(width: 40, height: 40, alignment: .center)
                    
                    Text("Gate 2 Green Office Park")
                        .bold(true)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(selectedPoint == "C" ? Color("sekunder") : Color.clear)
                .cornerRadius(8)
                .onTapGesture {
                    withAnimation(.spring()) {
                        selectedPoint = "C"
                    }
                }
                
                Spacer()
                
                Button(action: {                    
                    // Then navigate to navigation view with selected starting point
                    if let selectedPoint = selectedPoint {
                        appState.currentScreen = .navigation(startingPoint: selectedPoint)
                    }
                }) {
                    Text("Go")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color("primer"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("sekunder"))
                        .cornerRadius(10)
                }
                .padding(.top, 15)
                .disabled(selectedPoint == nil) // Disable if no point is selected
                .opacity(selectedPoint == nil ? 0 : 1.0) // Visual feedback for disabled button
            }
            .padding(20)
        }
    }
}

#Preview {
    StartingView(appState: AppState())
}
