//
//  CompassView.swift
//  Navigasi
//
//  Created by Akbar Febry on 09/05/25.
//

import SwiftUI

struct CompassView: View {
    @Binding var userHeading: Double
    @Binding var targetHeading: Double
    @Binding var isOnCorrectPath: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color("sekunderbgputih"))
                .frame(width: 280, height: 280)
                .shadow(radius: 5)
            
            Image(systemName: isOnCorrectPath ? "location.fill" : "location.north")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(isOnCorrectPath ? Color("primer") : Color(.red))
                .font(.system(size: 70))
                .rotationEffect(Angle(degrees: targetHeading - userHeading))
                .animation(.spring(), value: userHeading)
        }
    }
}

#Preview {
    CompassView(userHeading: .constant(0), targetHeading: .constant(0), isOnCorrectPath: .constant(true))
}
