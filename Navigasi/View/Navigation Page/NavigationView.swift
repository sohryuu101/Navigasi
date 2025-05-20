import SwiftUI

struct NavigationScreen: View {
    @StateObject var viewModel = ViewModelel()
    @ObservedObject var appState: AppState
    @State var isNavigating: Bool = true
    
    var startingPoint: String = "A"
    
    var body: some View {
        ZStack {
            Color.blue
                .ignoresSafeArea(edges: .all)
            
            switch viewModel.journey {
            case .running:
                VStack {
                    Spacer()
                    HStack {
                        viewModel.currentStepImage
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                        
                        VStack {
                            Text("\(Int(viewModel.distanceToNextPoint)) m")
                                .font(.title)
                                .foregroundColor(.white)
                                .bold()
                            
                            Text(viewModel.currentStep)
                                .foregroundColor(.white)
                                .sensoryFeedback(.impact, trigger: viewModel.currentStep)
                        }
                        .padding(.trailing)
                    }
                    
                    CompassView(userHeading: $viewModel.userHeading,
                                targetHeading: $viewModel.targetHeading,
                                isOnCorrectPath: $viewModel.isOnCorrectPath)
                    
                    Text(viewModel.isOnCorrectPath ?
                         "You are on the right path! Follow the instructions" :
                            "You are heading the wrong way, please head to the icon")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 10)
                    .frame(width: 300)
                    .multilineTextAlignment(.center)
                    .sensoryFeedback(.warning, trigger: !viewModel.isOnCorrectPath)
                    
                    // Debugging
                    //                Text("Target Heading is \(viewModel.targetHeading)")
                    //                    .font(.system(size: 14))
                    //                    .foregroundColor(.white)
                    //                    .padding(.vertical, 20)
                    //                    .padding(.horizontal, 10)
                    //                    .frame(width: 300)
                    //                Text("User Heading is \(viewModel.userHeading)")
                    //                    .font(.system(size: 14))
                    //                    .foregroundColor(.white)
                    //                    .padding(.vertical, 20)
                    //                    .padding(.horizontal, 10)
                    //                    .frame(width: 300)
                    
                    if let _ = viewModel.route, viewModel.currentStepIndex < viewModel.routeSteps.count {
                        Text("Step \(viewModel.currentStepIndex + 1) of \(viewModel.routeSteps.count)")
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                            .padding(.bottom, 10)
                    }
                    
                    Spacer()
                }
                .onAppear {
                    // Create a custom route or start navigation to a destination
                    viewModel.createCustomRoute() // Use this for pre-defined route
                    // Or use this to navigate to a specific destination
                    // viewModel.startNavigation(to: "Apple Developer Academy")
                    viewModel.startLiveActivity()
                }
                .sheet(isPresented: $isNavigating) {
                    NavigationInfoSheet(viewModel: viewModel, appState: appState)
                }
            case .completed:
                VStack {
                    Text(viewModel.currentStep)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .sensoryFeedback(.success, trigger: viewModel.currentStep)
                        .padding(.bottom, 50)
                    
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 2400, height: 240)
                            .shadow(radius: 2)
                        
                        Image(systemName: "checkmark")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.blue)
                            .frame(width: 80, height: 80)
                    }
                }
                .sheet(isPresented: $isNavigating) {
                    NavigationInfoSheet(viewModel: viewModel, appState: appState)
                }
            }
        }
    }
}

// Extract the bottom sheet to a separate view for better organization
struct NavigationInfoSheet: View {
    @ObservedObject var viewModel: ViewModelel
    @ObservedObject var appState: AppState
    
    var body: some View {
        ScrollView {
            switch viewModel.journey {
            case .running:
                VStack(alignment: .leading) {
                    // Origin
                    HStack {
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 16))
                        
                        Text("Apple Developer Academy")
                            .font(.system(size: 16, weight: .bold))
                    }
                    
                    Divider()
                    
                    // Destination
                    HStack {
                        Image(systemName: "bus.fill")
                            .font(.system(size: 16))
                        
                        Text("Halte BSD Link")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 40)
                .padding(.top, 40)
                
                // Route stats
                if let route = viewModel.route {
                    HStack {
                        Text(route.formattedTotalTime())
                            .font(.system(size: 14))
                        
                        Image(systemName: "circle.fill")
                            .font(.system(size: 5))
                        
                        Text(route.formattedTotalDistance())
                            .font(.system(size: 14))
                    }
                    .padding(.bottom, 40)
                }
                
                Button {
                    // action
                    appState.currentScreen = .showingMap
                } label: {
                    Text("End Route")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(15)
                        .background(Color("merahmuda"))
                        .cornerRadius(50)
                }
                .sensoryFeedback(.stop, trigger: appState.currentScreen)
                .padding(.horizontal, 20)
            case .completed:
                VStack(alignment: .leading) {
                    Text("You arrived at Halte BSD Link")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top, 40)
                        .padding(.leading, 20)
                    
                    Button {
                        // action
                        appState.currentScreen = .showingMap
                    } label: {
                        Text("Done")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(15)
                            .background(Color("ijo"))
                            .cornerRadius(50)
                    }
                    .sensoryFeedback(.selection, trigger: appState.currentScreen)
                    .padding(.horizontal, 20)
                }
            }
        }
        .presentationDetents([.fraction(0.2), .fraction(0.4)])
        .presentationCornerRadius(15)
        .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.2)))
        .interactiveDismissDisabled(true)
    }
}

#Preview {
    NavigationScreen(appState: AppState())
}
