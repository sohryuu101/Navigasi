import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @Query(sort: \Place.id, order: .forward) var places: [Place]
    @ObservedObject var appState: AppState
    
    var body: some View {
        Map(position: $viewModel.position) {
            // user's location
            UserAnnotation()
            
            // annotation for every place
            ForEach(places) { place in
                Annotation(place.name, coordinate: place.locationCoordinate) {
                    ZStack {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color("primer"))
                            .frame(width: 40, height: 40)
                        Image(systemName: place.sysImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .onTapGesture {
                                viewModel.selectedPlace = place
                                viewModel.isShowingDetails.toggle()
                            }
                    }
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            viewModel.checkIfLocationIsEnabled()
        }
        // bottom sheet area
        .sheet(isPresented: $viewModel.isShowingSheet) {
            SearchView(searchText: $viewModel.searchText)
                // searchview modifier
                .padding(.top, 40)
                .padding(.horizontal, 20)
            
            // title
            Text("Places")
                // textfield modifier
                .font(.system(size: 20, weight: .bold, design: .default))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 30)
                .padding(.top, 20)
            
            // show list of places - pass the view model and appState
            ListView(
                viewModel: viewModel,
                appState: appState,
                places: viewModel.searchText.isEmpty ? places : places.filter {
                    $0.name.lowercased().contains(viewModel.searchText.lowercased())
                }
            )
                .edgesIgnoringSafeArea(.bottom)
            // sheet modifier
            .padding(20)
            .presentationDetents([.fraction(0.2), .fraction(0.4), .fraction(0.99)])
            .presentationCornerRadius(15)
            .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.4)))
            .interactiveDismissDisabled(true)
        }
        // Add this sheet to show details when a map annotation is tapped
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

#Preview {
    MapView(appState: AppState())
}
