import Foundation
import SwiftUI

struct ListView: View {
    @ObservedObject var viewModel: MapViewModel
    @ObservedObject var appState: AppState
    
    var places: [Place]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(places) { place in
                    Button(action: {
                        viewModel.isShowingDetails = true
                        viewModel.zoomIntoPlace(place)
                        viewModel.selectedPlace = place
                        viewModel.selectedPlaceID = place.id
                    }) {
                        CardView(place: place)
                    }
                }
            }
            .padding(.horizontal)
        }
        // sheet for place details
        .sheet(isPresented: $viewModel.isShowingDetails) {
            DetailSheetView(viewModel: viewModel, appState: appState)
        }
    }
}
