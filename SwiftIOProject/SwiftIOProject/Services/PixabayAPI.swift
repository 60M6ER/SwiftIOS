//
//  PixabayAPI.swift
//  SwiftIOProject
//
//  Created by Борис Ларионов on 20.05.2026.
//

import Foundation
import Alamofire
import Moya

// Enum описывает единственную конечную точку API, с которой работает приложение.
enum PixabayAPI {
    // Запрос получает десять картинок по запросу sports car.
    case sportsCars
}

extension PixabayAPI: TargetType {
    // Базовый адрес сервиса Pixabay одинаков для всех запросов приложения.
    var baseURL: URL {
        URL(string: "https://pixabay.com")!
    }

    // Путь указывает на endpoint поиска изображений.
    var path: String {
        "/api/"
    }

    // Метод запроса обычный GET, потому что мы только читаем данные.
    var method: Moya.Method {
        .get
    }

    // Это свойство требует Moya.
    var sampleData: Data {
        Data()
    }

    // Task формирует query-параметры запроса по sports car.
    var task: Task {
        let parameters: [String: Any] = [
            "key": "55922363-fea55c30c06041f59bf87d93e",
            "q": "sports car",
            "order": "popular",
            "per_page": 10,
            "safesearch": true
        ]

        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }

    // Заголовки передают тип ожидаемых данных.
    var headers: [String: String]? {
        [
            "Content-Type": "application/json"
        ]
    }
}
