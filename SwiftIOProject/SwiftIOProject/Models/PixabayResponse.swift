//
//  PixabayResponse.swift
//  SwiftIOProject
//
//  Created by Борис Ларионов on 20.05.2026.
//

import Foundation

// Корневая модель ответа хранит массив изображений от Pixabay.
struct PixabayResponse: Decodable {
    // Массив картинок передается на главный экран.
    let hits: [CarImage]
}
