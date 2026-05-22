//
//  TMDBService.swift
//  MovieSearcher
//
//  Created by OpenAI on 22.05.2026.
//

import Foundation

final class TMDBService {
    // Единая точка доступа помогает не плодить одинаковые сетевые экземпляры.
    static let shared = TMDBService()

    // Базовый адрес нужен для всех запросов к TMDB.
    private let baseURLString = "https://api.themoviedb.org/3"

    // Сессия выполняет нативные запросы без сторонних библиотек.
    private let session: URLSession

    // Ключ читается из локального plist и не хранится прямо в коде сервиса.
    private let apiKey: String

    private init(session: URLSession = .shared) {
        self.session = session
        self.apiKey = Self.loadAPIKey()
    }

    // Популярные фильмы нужны для главного экрана.
    func fetchPopularMovies(page: Int = 1, completion: @escaping (Result<Data, Error>) -> Void) {
        request(
            path: "/movie/popular",
            queryItems: [
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "page", value: String(page))
            ],
            completion: completion
        )
    }

    // Недавно вышедший фильм нужен для проверки endpoint latest.
    func fetchLatestMovie(completion: @escaping (Result<Data, Error>) -> Void) {
        request(
            path: "/movie/latest",
            queryItems: [
                URLQueryItem(name: "language", value: "en-US")
            ],
            completion: completion
        )
    }

    // Фильмы в прокате нужны для категории now playing.
    func fetchNowPlayingMovies(page: Int = 1, completion: @escaping (Result<Data, Error>) -> Void) {
        request(
            path: "/movie/now_playing",
            queryItems: [
                URLQueryItem(name: "language", value: "en-US"),
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
                URLQueryItem(name: "language", value: "en-US"),
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
                URLQueryItem(name: "language", value: "en-US"),
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
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "page", value: String(page))
            ],
            completion: completion
        )
    }

    // Детальная информация нужна для полной карточки фильма.
    func fetchMovieDetails(id: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        request(
            path: "/movie/\(id)",
            queryItems: [
                URLQueryItem(name: "language", value: "en-US")
            ],
            completion: completion
        )
    }

    // Кадры и постеры нужны для галереи фильма.
    func fetchMovieImages(id: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        request(
            path: "/movie/\(id)/images",
            queryItems: nil,
            completion: completion
        )
    }

    // Временная проверка нужна, чтобы быстро увидеть ответы всех endpoint в консоли.
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
    }

    // Временная проверка нужна именно под задание с четырьмя категориями фильмов.
    func debugRunHomeworkRequests() {
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
