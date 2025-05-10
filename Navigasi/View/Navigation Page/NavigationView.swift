import SwiftUI

struct MyNavigationView: View {
    @StateObject var viewModel = MyNavigationViewModel()
    @State var isNavigating: Bool = true
    
    var startingPoint: String
    
    var body: some View {
        ZStack {
            Color.blue
                .ignoresSafeArea(edges: .all)
            
            VStack {
                Spacer()
                HStack {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    VStack {
                        Text("\(Int(viewModel.distanceToNextPoint)) m")
                            .font(.title)
                            .foregroundColor(.white)
                            .bold()
                        
                        Text(viewModel.currentStep)
                            .foregroundColor(.white)
                    }
                    .padding(.trailing)
                }
                
                CompassView(userHeading: $viewModel.userHeading, targetHeading: $viewModel.targetHeading, isOnCorrectPath: $viewModel.isOnCorrectPath)
                
                Text(viewModel.isOnCorrectPath ? "You are on the right path!, Follow the instructions" : "You are heading the wrong way, please head to the icon")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 10)
                    .frame(width: 300)
                    .multilineTextAlignment(.center)
                Spacer()
            }
        }
        .onAppear {
            viewModel.startNavigation(to: "Apple Developer Academy")
        }
        .sheet(isPresented: $isNavigating) {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "bus.fill")
                            .font(.system(size: 16))
                        
                        Text("Halte BSD Link")
                            .font(.system(size: 16, weight: .bold))
                    }
                    
                    Divider()

                    HStack {
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 16))
                        
                        Text("Apple Developer Academy")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .padding(.bottom, 20)
                }
                .padding(40)
                
                HStack {
                    Text("5 min")
                        .font(.system(size: 14))
                    
                    Image(systemName: "circle.fill")
                        .font(.system(size: 5))
                    
                    Text("10 m")
                        .font(.system(size: 14))
                }
                
            }
            .presentationDetents([.fraction(0.2), .fraction(0.4)])
            .presentationCornerRadius(15)
            .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.2)))
            .interactiveDismissDisabled(true)

        }
    }
}

#Preview {
    MyNavigationView(startingPoint: "A")
}
