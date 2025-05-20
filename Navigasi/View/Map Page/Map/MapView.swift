import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @Query(sort: \Place.id, order: .forward) var places: [Place]
    @ObservedObject var appState: AppState
    
    var body: some View {
        Map(position: $viewModel.position) {
            // polyline when user is ready
            if viewModel.isStartingPoint {
                // outer
                MapPolyline(coordinates: viewModel.polyline)
                    .stroke(Color("primer"), lineWidth: 8)
                
                // inner
                MapPolyline(coordinates: viewModel.polyline)
                    .stroke(Color.blue, lineWidth: 6)
            }
            
            // user's location
            UserAnnotation()
            
            // annotation for every place
            ForEach(places) { place in
                Annotation(place.name, coordinate: place.locationCoordinate) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5)) {
                            viewModel.selectedPlaceID = place.id
                        }
                        viewModel.selectedPlace = place
                        viewModel.zoomIntoPlace(place)
                        viewModel.isShowingDetails = true
                    }) {
                        ZStack {
                            // outer shadow for depth
                            Circle()
                                .fill(Color.white.opacity(0.6))
                                .frame(width: viewModel.selectedPlaceID == place.id ? 54 : 34, height: viewModel.selectedPlaceID == place.id ? 54 : 34)
                                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
                                .scaleEffect(viewModel.selectedPlaceID == place.id ? 1.3 : 1.0)
                                .rotationEffect(viewModel.selectedPlaceID == place.id ? .degrees(-15) : .degrees(0))
                                .animation(.easeInOut(duration: 0.2), value: viewModel.selectedPlaceID)
                            
                            // main background with border
                            Circle()
                                .fill(Color("primer"))
                                .frame(width: viewModel.selectedPlaceID == place.id ? 50 : 30, height: viewModel.selectedPlaceID == place.id ? 50 : 30)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                            
                            // icon
                            Image(systemName: place.sysImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.white)
                                .frame(width: viewModel.selectedPlaceID == place.id ? 25 : 15, height: viewModel.selectedPlaceID == place.id ? 25 : 15)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sensoryFeedback(.selection, trigger: viewModel.selectedPlace)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            viewModel.checkIfLocationIsEnabled()
        }
        // bottom sheet area
        .sheet(isPresented: $viewModel.isShowingSheet) {
            MapSheetView(viewModel: viewModel, appState: appState, places: places)
        }
        // sheet to show details when a map annotation is tapped
        .sheet(isPresented: $viewModel.isShowingDetails) {
            DetailSheetView(viewModel: viewModel, appState: appState)
        }
    }
}

#Preview {
    MapView(appState: AppState())
}
