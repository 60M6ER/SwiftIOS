//
//  PixabayAPI.swift
//  PicSearcher
//
//  Created by Борис Ларионов on 19.05.2026.
//

import Foundation
import Alamofire
import Moya

// Enum описывает единственную конечную точку API, с которой работает приложение.
enum PixabayAPI {
    // Запрос получает изображения по введенному тексту и номеру страницы.
    case pictures(query: String, page: Int)
}

extension PixabayAPI: TargetType {
    // Базовый адрес сервиса Pixabay одинаков для всех запросов приложения.
    var baseURL: URL {
        URL(string: "https://pixabay.com")!
    }

    // Путь указывает на endpoint поиска изображений из задания.
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

    // Task формирует query-параметры запроса с текстом поиска, ключом и пагинацией.
    var task: Task {
        let queryText: String
        let currentPage: Int

        switch self {
        case .pictures(let query, let page):
            queryText = query
            currentPage = page
        }

        let parameters: [String: Any] = [
            "key": "55922363-fea55c30c06041f59bf87d93e",
            "q": queryText,
            "order": "popular",
            "safesearch": true,
            "page": currentPage,
            "per_page": 20
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
