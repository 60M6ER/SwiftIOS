//
//  NewsService.swift
//  NewsList
//
//  Created by Борис Ларионов on 18.05.2026.
//

import Foundation
import Moya
import ObjectMapper

// Сервис инкапсулирует сетевой запрос, чтобы контроллер не работал с Moya напрямую.
final class NewsService {
    // Provider выполняет реальный HTTP-запрос к News API.
    private let provider = MoyaProvider<NewsAPI>()

    // Метод загружает конкретную страницу новостей и возвращает корневой ответ через completion.
    func fetchNews(page: Int, completion: @escaping (Result<NewsResponse, Error>) -> Void) {
        provider.request(.education(page: page)) { result in
            switch result {
            case .success(let response):
                do {
                    let successfulResponse = try response.filterSuccessfulStatusCodes()
                    let jsonString = try successfulResponse.mapString()

                    guard let newsResponse = Mapper<NewsResponse>().map(JSONString: jsonString) else {
                        completion(.failure(NewsServiceError.mappingFailed))
                        return
                    }

                    completion(.success(newsResponse))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// Ошибки сервиса выделены отдельно, чтобы контроллер мог показать понятное сообщение пользователю.
enum NewsServiceError: LocalizedError {
    // Ошибка возникает, если JSON не удалось преобразовать в локальные модели.
    case mappingFailed

    // Текст ошибки пригодится для alert в контроллере.
    var errorDescription: String? {
        switch self {
        case .mappingFailed:
            return "Не удалось обработать ответ сервера."
        }
    }
}
