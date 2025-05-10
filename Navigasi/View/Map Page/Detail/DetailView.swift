import SwiftUI
import CoreLocation

struct DetailView: View {
    @ObservedObject var viewModel: MapViewModel
    @ObservedObject var appState: AppState
    var place: Place
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(place.name)
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(Color(.label))
                
                HStack {
                    Text(viewModel.distance)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(.secondaryLabel))
                    Image(systemName: "circle.fill")
                        .foregroundColor(Color(.secondaryLabel))
                        .font(.system(size: 5))
                    Text(place.building)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(.secondaryLabel))
                }
                
                Text("Photos")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(.label))
                    .padding(.top, 10)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(place.images.indices, id: \.self) { index in
                            place.images[index]
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 146, height: 183)
                                .cornerRadius(10)
                        }
                    }
                }
                
                Text("Description")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(.label))
                    .padding(.top, 10)
                
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .background(Color("sekunder"))
                        .cornerRadius(10)
                    
                    Text(place.desc)
                        .font(.system(size: 14))
                        .padding(15)
                        .foregroundColor(Color(.label))
                }
                .frame(height: 120)
                
                Button(action: {
                    viewModel.isStartingPoint = true
                }) {
                    Text("Select Starting Point")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color("primer"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("sekunder"))
                        .cornerRadius(10)
                }
                .padding(.top, 15)
                
                .sheet(isPresented: $viewModel.isStartingPoint) {
                    HStack {
                        Spacer()
                        Button {
                            viewModel.isStartingPoint.toggle()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding([.top, .trailing])
                    
                    StartingView(appState: appState)
                    
                        .presentationDetents([.fraction(0.2), .fraction(0.4), .fraction(0.99)])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(15)
                        .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.4)))
                        .interactiveDismissDisabled(true)
                }
            }
            .padding(.horizontal)
        }
        .scrollDisabled(false)
        .onAppear {
            viewModel.checkIfLocationIsEnabled()
            viewModel.startLocationUpdates(for: place)
        }
    }
}

#Preview {
    DetailView(
        viewModel: MapViewModel(),
        appState: AppState(),
        place: Place(id: 1, name: "Test", desc: "Test", sysImage: "map", coordinates: .init(latitude: 0, longitude: 0), building: "GOP 9", imageNames: ["image1", "image2", "image3"])
    )
}
