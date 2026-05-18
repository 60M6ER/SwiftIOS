//
//  NewsArticle.swift
//  NewsList
//
//  Created by Борис Ларионов on 18.05.2026.
//

import Foundation
import ObjectMapper

// Модель одной новости хранит все поля, которые нужны таблице и переходу в браузер.
final class NewsArticle: Mappable {
    // Источник новости нужен для подписи вида "Источник: Заголовок".
    var source = NewsSource()

    // Заголовок новости выводится в верхнем жирном лейбле ячейки.
    var title = ""

    // Краткое описание выводится под заголовком справа от картинки.
    var articleDescription = ""

    // Ссылка на оригинал новости открывается через SFSafariViewController.
    var urlString = ""

    // Ссылка на изображение используется Kingfisher для загрузки и кэширования картинки.
    var imageURLString = ""

    // Дата публикации приходит строкой в ISO-формате и позже преобразуется для UI.
    var publishedAt = ""

    // Пустой инициализатор нужен библиотеке ObjectMapper для создания объекта перед маппингом.
    init() {
    }

    // Инициализатор подтверждает, что объект может быть создан из карты JSON.
    required init?(map: Map) {
    }

    // Метод сопоставляет поля JSON со свойствами локальной модели.
    func mapping(map: Map) {
        source <- map["source"]
        title <- map["title"]
        articleDescription <- map["description"]
        urlString <- map["url"]
        imageURLString <- map["urlToImage"]
        publishedAt <- map["publishedAt"]
    }

    // Готовый текст верхней строки упрощает настройку ячейки и скрывает детали склейки строк.
    var headlineText: String {
        let sourceName = source.name.isEmpty ? "Источник" : source.name
        let articleTitle = title.isEmpty ? "Без заголовка" : title
        return "\(sourceName): \(articleTitle)"
    }

    // Описание нормализуется, чтобы ячейка не показывала пустую дыру при неполном ответе API.
    var descriptionText: String {
        articleDescription.isEmpty ? "Описание недоступно." : articleDescription
    }

    // Валидный URL нужен для безопасного открытия новости внутри приложения.
    var articleURL: URL? {
        URL(string: urlString)
    }

    // Валидный URL изображения нужен для Kingfisher.
    var imageURL: URL? {
        URL(string: imageURLString)
    }
}
