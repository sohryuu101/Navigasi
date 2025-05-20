//
//  MapSheetView.swift
//  Navigasi
//
//  Created by Akbar Febry on 17/05/25.
//

import SwiftUI

struct MapSheetView: View {
    @ObservedObject var viewModel: MapViewModel
    @ObservedObject var appState: AppState
    
    var places: [Place]
    
    var body: some View {
        SearchView(searchText: $viewModel.searchText)
            // searchview modifier
            .padding(.top, 40)
            .padding(.horizontal, 30)
        
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
        .presentationDetents([.fraction(0.2), .fraction(0.4), .fraction(0.99)], selection: .constant(.fraction(0.4)))
        .presentationCornerRadius(15)
        .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.4)))
        .interactiveDismissDisabled(true)
    }
}
