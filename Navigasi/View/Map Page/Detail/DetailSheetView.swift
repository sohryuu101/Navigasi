//
//  BeforeDetailsView.swift
//  Navigasi
//
//  Created by Akbar Febry on 17/05/25.
//

import SwiftUI

struct DetailSheetView: View {
    @ObservedObject var viewModel: MapViewModel
    @ObservedObject var appState: AppState

    var body: some View {
        HStack {
            Spacer()
            Button {
                viewModel.zoomOut()
                viewModel.isShowingDetails.toggle()
                viewModel.selectedPlace = nil
                viewModel.selectedPlaceID = nil
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
        .presentationDetents([.fraction(0.2), .fraction(0.4), .fraction(0.99)], selection: .constant(.fraction(0.4)))
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(15)
        .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.4)))
        .interactiveDismissDisabled(true)
    }
}
