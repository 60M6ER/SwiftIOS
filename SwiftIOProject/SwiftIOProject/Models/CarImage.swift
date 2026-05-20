//
//  CarImage.swift
//  SwiftIOProject
//
//  Created by Борис Ларионов on 20.05.2026.
//

import Foundation

// Модель картинки хранит данные, которые нужны списку и детальному экрану.
struct CarImage: Identifiable, Decodable {
    // Идентификатор нужен для списка SwiftUI.
    let id: Int

    // Теги используются как заголовок и описание.
    let tags: String

    // Маленькая картинка показывается в списке.
    let previewURL: String

    // Большая картинка показывается на детальном экране.
    let largeImageURL: String

    // Имя автора можно показать под описанием.
    let user: String

    // Заголовок генерируется локально после загрузки и не приходит из API.
    var generatedTitle = ""

    // CodingKeys описывает только поля, которые реально приходят от Pixabay.
    private enum CodingKeys: String, CodingKey {
        case id
        case tags
        case previewURL
        case largeImageURL
        case user
    }

    // Готовый URL для списка.
    var previewImageURL: URL? {
        URL(string: previewURL)
    }

    // Готовый URL для детального экрана.
    var detailImageURL: URL? {
        URL(string: largeImageURL)
    }

    // Заголовок скрывает пустые теги.
    var titleText: String {
        generatedTitle.isEmpty ? "Sport car" : generatedTitle
    }

    // Описание скрывает пустые теги и добавляет автора.
    var descriptionText: String {
        if tags.isEmpty {
            return "Описание недоступно."
        }

        return tags
    }
}
