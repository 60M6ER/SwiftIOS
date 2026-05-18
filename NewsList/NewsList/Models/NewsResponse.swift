//
//  NewsResponse.swift
//  NewsList
//
//  Created by Борис Ларионов on 18.05.2026.
//

import Foundation
import ObjectMapper

// Корневая модель ответа хранит массив новостей, который приходит из News API.
final class NewsResponse: Mappable {
    // Общее число найденных новостей помогает понять, есть ли еще страницы для загрузки.
    var totalResults = 0

    // Массив статей передается контроллеру для показа в таблице.
    var articles: [NewsArticle] = []

    // Пустой инициализатор нужен библиотеке ObjectMapper для создания объекта перед маппингом.
    init() {
    }

    // Инициализатор подтверждает, что объект может быть создан из карты JSON.
    required init?(map: Map) {
    }

    // Метод сопоставляет массив статей из JSON с локальным свойством модели.
    func mapping(map: Map) {
        totalResults <- map["totalResults"]
        articles <- map["articles"]
    }
}
