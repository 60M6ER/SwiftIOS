//
//  PictureService.swift
//  PicSearcher
//
//  Created by Борис Ларионов on 19.05.2026.
//

import Foundation
import Moya
import SwiftyJSON

// Сервис инкапсулирует сетевой запрос, чтобы контроллер не работал с Moya напрямую.
final class PictureService {
    // Provider выполняет реальный HTTP-запрос к Pixabay и возвращает callback не на главном потоке.
    private let provider = MoyaProvider<PixabayAPI>(callbackQueue: DispatchQueue.global(qos: .userInitiated))

    // Метод загружает конкретную страницу изображений и возвращает корневой ответ через completion.
    func fetchPictures(query: String, page: Int, completion: @escaping (Result<PictureResponse, Error>) -> Void) {
        provider.request(.pictures(query: query, page: page)) { result in
            switch result {
            case .success(let response):
                do {
                    let successfulResponse = try response.filterSuccessfulStatusCodes()
                    let jsonObject = try JSON(data: successfulResponse.data)
                    let pictureResponse = PictureResponse(json: jsonObject)
                    completion(.success(pictureResponse))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
