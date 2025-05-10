//
//  SearchView.swift
//  Navigasi
//
//  Created by Akbar Febry on 04/05/25.
//

import SwiftUI

struct SearchView: View {
    @Binding var searchText: String
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 11)
                    
                    TextField("Search Places", text: $searchText)
                        .padding(.leading, 8)
                        .padding(.vertical, 12)
                        .submitLabel(.search)
                        .autocorrectionDisabled()
                        .font(.system(size: 14))
                }
                .background(Color(red: 0.27, green: 0.27, blue: 0.27).opacity(0.07))
                .cornerRadius(10)
                .overlay(
                  RoundedRectangle(cornerRadius: 10)
                    .inset(by: 0.5)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
                )
                
                if searchText.isEmpty == false {
                    Button {
                        searchText = ""
                        dismissKeyboard()
                    } label: {
                        Text("Cancel")
                            .foregroundStyle(.blue)
                            .font(.system(size: 14))
                    }
                }
            }
        }
    }
}
