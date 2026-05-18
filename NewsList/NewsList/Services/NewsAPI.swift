//
//  NewsAPI.swift
//  NewsList
//
//  Created by Борис Ларионов on 18.05.2026.
//

import Foundation
import Alamofire
import Moya

// Enum описывает единственную конечную точку API, с которой работает приложение.
enum NewsAPI {
    // Запрос получает новости по ключевому слову education.
    case education(page: Int)
}

extension NewsAPI: TargetType {
    // Базовый адрес сервиса News API одинаков для всех запросов приложения.
    var baseURL: URL {
        URL(string: "https://newsapi.org")!
    }

    // Путь указывает на endpoint everything из задания.
    var path: String {
        "/v2/everything"
    }

    // Метод запроса обычный GET, потому что мы только читаем данные.
    var method: Moya.Method {
        .get
    }

    // Это свойство требует Moya
    var sampleData: Data {
        Data()
    }

    // Task формирует query-параметры запроса с ключевым словом и API key.
    var task: Task {
        let currentPage: Int

        switch self {
        case .education(let page):
            currentPage = page
        }

        let parameters: [String: Any] = [
            "q": "education",
            "pageSize": 20,
            "page": currentPage,
            "language": "ru",
            "sortBy": "publishedAt"
        ]

        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }

    // Заголовки передают тип данных и API key для доступа к сервису.
    var headers: [String: String]? {
        [
            "Content-Type": "application/json",
            "X-Api-Key": "eaa74cd71c37446c9f69e82e1a3e1111"
        ]
    }
}
