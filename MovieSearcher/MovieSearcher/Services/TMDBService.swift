//
//  TMDBService.swift
//  MovieSearcher
//
//  Created by OpenAI on 22.05.2026.
//

import Foundation
import UIKit

final class TMDBService {
    // Единая точка доступа помогает не плодить одинаковые сетевые экземпляры.
    static let shared = TMDBService()

    // Базовый адрес нужен для всех запросов к TMDB.
    private let baseURLString = "https://api.themoviedb.org/3"

    // Сессия выполняет нативные запросы без сторонних библиотек.
    private let session: URLSession

    // Ключ читается из локального plist и не хранится прямо в коде сервиса.
    private let apiKey: String

    // Парсер оставляет учебный стиль: сеть отдельно, разбор JSON отдельно.
    private let parsingService = JSONParsingService()

    // Локаль запроса управляет языком текстовых данных из TMDB.
    private let language = "ru-RU"

    // Кэш нужен, чтобы не грузить один и тот же постер при каждом скролле заново.
    private let imageCache = NSCache<NSString, UIImage>()

    private init(session: URLSession = .shared) {
        self.session = session
        self.apiKey = Self.loadAPIKey()
    }

    // Популярные фильмы нужны для главного экрана.
    func fetchPopularMovies(page: Int = 1, completion: @escaping (Result<Data, Error>) -> Void) {
        request(
            path: "/movie/popular",
            queryItems: [
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "page", value: String(page))
            ],
            completion: completion
        )
    }

    // Главный экрану удобнее получить уже готовую страницу фильмов.
    func fetchPopularMovieList(page: Int = 1, completion: @escaping (Result<MoviePage, Error>) -> Void) {
        fetchPopularMovies(page: page) { result in
            completion(result.flatMap(self.parsingService.parseMovies))
        }
    }

    // Detail-экрану удобнее получить уже готовые пути кадров фильма.
    func fetchMovieImagePaths(id: Int, completion: @escaping (Result<[String], Error>) -> Void) {
        fetchMovieImages(id: id) { result in
            completion(result.flatMap(self.parsingService.parseImagePaths))
        }
    }

    // Недавно вышедший фильм нужен для проверки endpoint latest.
    func fetchLatestMovie(completion: @escaping (Result<Data, Error>) -> Void) {
        request(
            path: "/movie/latest",
            queryItems: [
                URLQueryItem(name: "language", value: language)
            ],
            completion: completion
        )
    }

    // Фильмы в прокате нужны для категории now playing.
    func fetchNowPlayingMovies(page: Int = 1, completion: @escaping (Result<Data, Error>) -> Void) {
        request(
            path: "/movie/now_playing",
            queryItems: [
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "page", value: String(page))
            ],
            completion: completion
        )
    }

    // Высокорейтинговые фильмы нужны для категории top rated.
    func fetchTopRatedMovies(page: Int = 1, completion: @escaping (Result<Data, Error>) -> Void) {
        request(
            path: "/movie/top_rated",
            queryItems: [
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "page", value: String(page))
            ],
            completion: completion
        )
    }

    // Скоро выходящие фильмы нужны для категории upcoming.
    func fetchUpcomingMovies(page: Int = 1, completion: @escaping (Result<Data, Error>) -> Void) {
        request(
            path: "/movie/upcoming",
            queryItems: [
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "page", value: String(page))
            ],
            completion: completion
        )
    }

    // Поиск по названию нужен для search controller.
    func searchMovies(query: String, page: Int = 1, completion: @escaping (Result<Data, Error>) -> Void) {
        request(
            path: "/search/movie",
            queryItems: [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "include_adult", value: "false"),
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "page", value: String(page))
            ],
            completion: completion
        )
    }

    // Главный экрану удобнее получить уже готовую страницу поисковой выдачи.
    func fetchSearchMovieList(query: String, page: Int = 1, completion: @escaping (Result<MoviePage, Error>) -> Void) {
        searchMovies(query: query, page: page) { result in
            completion(result.flatMap(self.parsingService.parseMovies))
        }
    }

    // Кадры и постеры нужны для галереи фильма.
    func fetchMovieImages(id: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        request(
            path: "/movie/\(id)/images",
            queryItems: nil,
            completion: completion
        )
    }

    // Детальная информация нужна для полной карточки фильма.
    func fetchMovieDetails(id: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        request(
            path: "/movie/\(id)",
            queryItems: [
                URLQueryItem(name: "language", value: language)
            ],
            completion: completion
        )
    }

    // Метод собирает ссылку на постер нужного размера.
    func makePosterURL(path: String, size: String = "w500") -> URL? {
        guard !path.isEmpty else {
            return nil
        }

        return URL(string: "https://image.tmdb.org/t/p/\(size)\(path)")
    }

    // Метод собирает ссылку на оригинальный постер для fullscreen.
    func makeOriginalPosterURL(path: String) -> URL? {
        makePosterURL(path: path, size: "original")
    }

    // Метод грузит постер и возвращает кэшированную картинку через completion.
    func getSetPoster(url: URL, completion: @escaping (UIImage) -> Void) {
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage)
            return
        }

        let request = URLRequest(
            url: url,
            cachePolicy: .returnCacheDataElseLoad,
            timeoutInterval: 10
        )

        let downloadingTask = session.dataTask(with: request) { [weak self] data, response, error in
            guard
                error == nil,
                let unwrappedData = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let self
            else {
                return
            }

            guard let image = UIImage(data: unwrappedData) else {
                return
            }

            self.imageCache.setObject(image, forKey: url.absoluteString as NSString)

            DispatchQueue.main.async {
                completion(image)
            }
        }

        downloadingTask.resume()
    }

    /// Временная проверка нужна, чтобы быстро увидеть ответы всех endpoint в консоли.
    /// Метод для теста без интерфейса. вызывался в ранних юнитах.
    func debugRunAllRequests() {
        fetchPopularMovies(page: 1) { result in
            self.printDebugResult(title: "POPULAR", result: result)
        }

        searchMovies(query: "Avatar", page: 1) { result in
            self.printDebugResult(title: "SEARCH", result: result)
        }

        fetchMovieDetails(id: 550) { result in
            self.printDebugResult(title: "DETAILS", result: result)
        }

        fetchMovieImages(id: 550) { result in
            self.printDebugResult(title: "IMAGES", result: result)
        }
        
        fetchLatestMovie { result in
            self.printDebugResult(title: "LATEST", result: result)
        }

        fetchNowPlayingMovies(page: 1) { result in
            self.printDebugResult(title: "NOW_PLAYING", result: result)
        }

        fetchTopRatedMovies(page: 1) { result in
            self.printDebugResult(title: "TOP_RATED", result: result)
        }

        fetchUpcomingMovies(page: 1) { result in
            self.printDebugResult(title: "UPCOMING", result: result)
        }
    }

}

private extension TMDBService {
    // Общий запрос собирает URL, проверяет ответ и возвращает сырые данные.
    func request(
        path: String,
        queryItems: [URLQueryItem]?,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let url = makeURL(path: path, queryItems: queryItems) else {
            completion(.failure(TMDBServiceError.invalidURL))
            return
        }

        let task = session.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(TMDBServiceError.invalidResponse))
                return
            }

            guard 200...299 ~= httpResponse.statusCode else {
                completion(.failure(TMDBServiceError.invalidStatusCode(httpResponse.statusCode)))
                return
            }

            guard let data else {
                completion(.failure(TMDBServiceError.emptyData))
                return
            }

            completion(.success(data))
        }

        task.resume()
    }

    // URLComponents собирает endpoint и общие параметры запроса.
    func makeURL(path: String, queryItems: [URLQueryItem]?) -> URL? {
        var components = URLComponents(string: baseURLString + path)
        var items = queryItems ?? []
        items.append(URLQueryItem(name: "api_key", value: apiKey))
        components?.queryItems = items
        return components?.url
    }

    // Ключ берется из локального plist, который не уходит в git.
    static func loadAPIKey() -> String {
        guard
            let url = Bundle.main.url(forResource: "TMDBConfig", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let apiKey = plist["TMDBAPIKey"] as? String,
            !apiKey.isEmpty
        else {
            assertionFailure("TMDBConfig.plist not found or TMDBAPIKey is empty")
            return ""
        }

        return apiKey
    }

    // Консольный вывод помогает проверить сервис до сериализации и привязки к UI.
    func printDebugResult(title: String, result: Result<Data, Error>) {
        switch result {
        case let .success(data):
            let responseString = String(data: data, encoding: .utf8) ?? "Не удалось преобразовать Data в строку."
            print("\n===== TMDB \(title) =====\n\(responseString)\n")
        case let .failure(error):
            print("\n===== TMDB \(title) ERROR =====\n\(error.localizedDescription)\n")
        }
    }
}

enum TMDBServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidStatusCode(Int)
    case emptyData

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Не удалось собрать URL запроса."
        case .invalidResponse:
            return "Сервис вернул некорректный ответ."
        case let .invalidStatusCode(code):
            return "Сервис вернул статус \(code)."
        case .emptyData:
            return "Сервис вернул пустые данные."
        }
    }
}
