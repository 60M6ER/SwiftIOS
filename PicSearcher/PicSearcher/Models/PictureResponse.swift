//
//  PictureResponse.swift
//  PicSearcher
//
//  Created by Борис Ларионов on 19.05.2026.
//

import Foundation
import SwiftyJSON

// Корневая модель ответа хранит массив изображений и общее количество доступных результатов.
final class PictureResponse {
    // Общее число найденных картинок помогает понять, есть ли еще страницы для загрузки.
    let totalHits: Int

    // Массив картинок передается контроллеру для показа в коллекции.
    let pictures: [Picture]

    // Инициализация.
    nonisolated init(json: JSON) {
        totalHits = json["totalHits"].intValue
        pictures = json["hits"].arrayValue.map(Picture.init)
    }
}
