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
                        viewModel.isShowingDetails.toggle()
                        viewModel.selectedPlace = place
                    }) {
                        CardView(place: place)
                    }
                }
            }
            .padding(.horizontal)
        }
        // sheet for place details
        .sheet(isPresented: $viewModel.isShowingDetails) {
            HStack {
                Spacer()
                Button {
                    viewModel.isShowingDetails.toggle()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding([.top, .trailing])
            
            VStack(alignment: .leading) {
                if let selectedPlace = viewModel.selectedPlace {
                    DetailView(viewModel: viewModel, appState: appState, place: selectedPlace)
                        .edgesIgnoringSafeArea(.bottom)
                }
            }
            .presentationDetents([.fraction(0.2), .fraction(0.4), .fraction(0.99)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(15)
            .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.4)))
            .interactiveDismissDisabled(true)
        }
    }
}
