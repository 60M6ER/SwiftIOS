//
//  NewsSource.swift
//  NewsList
//
//  Created by Борис Ларионов on 18.05.2026.
//

import Foundation
import ObjectMapper

// Модель источника нужна для чтения названия издания из JSON.
final class NewsSource: Mappable {
    // Название источника выводится в верхней строке ячейки перед заголовком новости.
    var name = ""

    // Пустой инициализатор нужен библиотеке ObjectMapper для создания объекта перед маппингом.
    init() {
    }

    // Инициализатор подтверждает, что объект может быть создан из карты JSON.
    required init?(map: Map) {
    }

    // Метод сопоставляет поле JSON с локальным свойством модели.
    func mapping(map: Map) {
        name <- map["name"]
    }
}
