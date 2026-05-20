//
//  ContentView.swift
//  SwiftIOProject
//
//  Created by Борис Ларионов on 20.05.2026.
//

import SwiftUI

struct ContentView: View {
    // ViewModel управляет загрузкой картинок и состоянием списка.
    @StateObject private var viewModel = CarImageListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Загрузка изображений...")
                } else if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    List(viewModel.images) { image in
                        NavigationLink(destination: CarImageDetailView(image: image)) {
                            CarImageRowView(image: image)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Sport Cars")
        }
        .onAppear {
            if viewModel.images.isEmpty {
                viewModel.loadImages()
            }
        }
    }
}

#Preview {
    ContentView()
}
