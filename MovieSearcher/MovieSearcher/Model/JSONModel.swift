//
//  JSONModel.swift
//  MovieSearcher
//
//  Created by OpenAI on 22.05.2026.
//

import Foundation

// Готовая страница нужна модели как рабочий результат парсинга TMDB.
struct MoviePage {
    let page: Int
    let totalPages: Int
    let totalResults: Int
    let films: [FilmObject]
}

// Глобальная обертка описывает список фильмов, который приходит от TMDB.
struct MovieList: Codable {
    let page: Int?
    let totalResults: Int?
    let totalPages: Int?
    let results: [MovieResult]?

    enum CodingKeys: String, CodingKey {
        case page
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case results
    }
}

// Один объект фильма нужен для парсинга ответа TMDB.
struct MovieResult: Codable {
    let id: Int?
    let title: String?
    let posterPath: String?
    let originalTitle: String?
    let overview: String?
    let releaseDate: String?
    let voteAverage: Double?
    let backdropPath: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case posterPath = "poster_path"
        case originalTitle = "original_title"
        case overview
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case backdropPath = "backdrop_path"
    }
}

// Ответ на запрос кадров содержит id фильма и массив backdrop-объектов.
struct MovieImagesResponse: Codable {
    let id: Int?
    let backdrops: [Backdrop]?
}

// Для кадров нам нужен путь к картинке.
struct Backdrop: Codable {
    let filePath: String?

    enum CodingKeys: String, CodingKey {
        case filePath = "file_path"
    }
}
