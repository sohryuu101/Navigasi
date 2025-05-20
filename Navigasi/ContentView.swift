import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \Place.id, order: .forward) var places: [Place]
    @Environment(\.modelContext) var context
    @StateObject private var appState = AppState()
    @Namespace private var animation
    
    private var dataRelated = DataRelated()
    
    var body: some View {
        if places.isEmpty {
            Text("Loading...")
                .task {
                    dataRelated.initializeData(context: context)
                }
        } else {
            ZStack {
                // Switch content based on app state
                switch appState.currentScreen {
                case .showingMap:
                    MapView(appState: appState)
                        .transition(
                            .asymmetric(
                                insertion: .opacity.combined(with: .scale),
                                removal: .opacity.combined(with: .slide)
                            )
                        )
                        .matchedGeometryEffect(id: "screenContainer", in: animation)
                        
                case .navigation(let startingPoint):
                    NavigationScreen(appState: appState, startingPoint: startingPoint)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            )
                        )
                        .matchedGeometryEffect(id: "screenContainer", in: animation)
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: appState.currentScreen)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Place.self, inMemory: true)
}
