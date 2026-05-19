//
//  Picture.swift
//  PicSearcher
//
//  Created by Борис Ларионов on 19.05.2026.
//

import Foundation
import SwiftyJSON

// Модель одной картинки хранит поля, которые нужны сетке, детальному экрану и сохранению.
final class Picture {
    // Идентификатор изображения нужен для устойчивой логики выбора и отладки.
    let id: Int

    // Набор тегов используется как подпись на детальном экране.
    let tags: String

    // Маленькая картинка загружается в ячейке коллекции как превью.
    let previewURLString: String

    // Средняя картинка может пригодиться как запасной вариант для детального просмотра.
    let webformatURLString: String

    // Большая картинка используется на полноэкранном экране.
    let largeImageURLString: String

    // Имя автора можно показать позже, если понадобится дополнить интерфейс.
    let userName: String

    // Ширина большого изображения пригодится для подписи на детальном экране.
    let imageWidth: Int

    // Высота большого изображения пригодится для подписи на детальном экране.
    let imageHeight: Int

    // Инициализация.
    nonisolated init(json: JSON) {
        id = json["id"].intValue
        tags = json["tags"].stringValue
        previewURLString = json["previewURL"].stringValue
        webformatURLString = json["webformatURL"].stringValue
        largeImageURLString = json["largeImageURL"].stringValue
        userName = json["user"].stringValue
        imageWidth = json["imageWidth"].intValue
        imageHeight = json["imageHeight"].intValue
    }

    // Готовая подпись скрывает обработку пустых тегов внутри модели.
    var titleText: String {
        tags.isEmpty ? "Без названия" : tags
    }

    // URL превью нужен для асинхронной загрузки изображения в плитку коллекции.
    var previewURL: URL? {
        URL(string: previewURLString)
    }

    // URL большого изображения используется на детальном экране.
    var detailImageURL: URL? {
        if !largeImageURLString.isEmpty {
            return URL(string: largeImageURLString)
        }

        return URL(string: webformatURLString)
    }

    // Готовая строка разрешения скрывает форматирование размеров внутри модели.
    var resolutionText: String {
        guard imageWidth > 0, imageHeight > 0 else {
            return "Разрешение неизвестно"
        }

        return "\(imageWidth) x \(imageHeight)"
    }
}
