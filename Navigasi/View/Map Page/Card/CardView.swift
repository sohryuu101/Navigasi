//
//  ListView.swift
//  Navigasi
//
//  Created by Akbar Febry on 04/05/25.
//
import SwiftUI

struct CardView: View {
    @StateObject var viewModel = MapViewModel()
    let place: Place
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(place.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(.label))
                
                Text("\(viewModel.distance) . \(place.building)")
                    .font(.system(size: 14))
                    .foregroundColor(Color(.secondaryLabel))
            }
            
            Spacer()
            
            ZStack {
                Rectangle()
                  .foregroundColor(.clear)
                  .frame(width: 60, height: 60)
                  .background(Color("sekunder"))
                  .cornerRadius(10)
                
                Label("", systemImage: place.sysImage)
                    .labelStyle(.iconOnly)
                    .foregroundStyle(Color("primer"))
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .frame(width: 350, height: 100)
        .background(Color("sekunderbgputih"))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.25), radius: 2, x: 2, y: 4)
        .onAppear {
            viewModel.checkIfLocationIsEnabled()
            viewModel.startLocationUpdates(for: place)
        }
    }
}

#Preview {
    CardView(place: Place(
        id: 1,
        name: "Apple Developer Academy",
        desc: "",
        sysImage: "graduationcap.fill",
        coordinates: Place.Coordinates(latitude: -6.3018849, longitude: 106.6500193),
        building: "GOP 9",
        imageNames: ["image1", "image2", "image3"]
    ))
}
