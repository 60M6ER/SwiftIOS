//
//  CarImageService.swift
//  SwiftIOProject
//
//  Created by Борис Ларионов on 20.05.2026.
//

import Foundation
import Moya

// Сервис инкапсулирует сетевой запрос, чтобы View не работала с Moya напрямую.
final class CarImageService {
    // Provider выполняет реальный HTTP-запрос к Pixabay.
    private let provider = MoyaProvider<PixabayAPI>()

    // Метод загружает список картинок и возвращает его через completion.
    func fetchSportsCars(completion: @escaping (Result<[CarImage], Error>) -> Void) {
        provider.request(.sportsCars) { result in
            switch result {
            case .success(let response):
                do {
                    let successfulResponse = try response.filterSuccessfulStatusCodes()
                    let decodedResponse = try JSONDecoder().decode(PixabayResponse.self, from: successfulResponse.data)
                    completion(.success(decodedResponse.hits))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
