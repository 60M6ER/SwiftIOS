//
//  CarImageListViewModel.swift
//  SwiftIOProject
//
//  Created by Борис Ларионов on 20.05.2026.
//

import Foundation
import Combine

// ViewModel хранит список картинок и состояние загрузки для главного экрана.
final class CarImageListViewModel: ObservableObject {
    // Сервис выполняет запрос к Pixabay.
    private let service = CarImageService()

    // Массив картинок служит источником данных для списка SwiftUI.
    @Published var images: [CarImage] = []

    // Флаг показывает, что сейчас идет первая загрузка данных.
    @Published var isLoading = false

    // Текст ошибки показывается на экране, если запрос не удался.
    @Published var errorMessage = ""

    // Метод загружает картинки по sports car и обновляет состояние экрана.
    func loadImages() {
        isLoading = true
        errorMessage = ""

        service.fetchSportsCars { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }

                self.isLoading = false

                switch result {
                case .success(let images):
                    self.images = images.enumerated().map { index, image in
                        var updatedImage = image
                        updatedImage.generatedTitle = "Sport car \(index + 1)"
                        return updatedImage
                    }
                case .failure:
                    self.images = []
                    self.errorMessage = "Не удалось загрузить изображения."
                }
            }
        }
    }
}
