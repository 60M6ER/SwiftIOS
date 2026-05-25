//
//  JSONParsingService.swift
//  MovieSearcher
//
//  Created by OpenAI on 22.05.2026.
//

import Foundation

final class JSONParsingService {
    // Метод декодирует ответ TMDB и возвращает страницу с фильмами и метаданными.
    func parseMovies(from data: Data) -> Result<MoviePage, Error> {
        do {
            let movieList = try JSONDecoder().decode(MovieList.self, from: data)
            let moviePage = MoviePage(
                page: movieList.page ?? 1,
                totalPages: movieList.totalPages ?? 1,
                totalResults: movieList.totalResults ?? 0,
                films: makeFilms(from: movieList.results ?? [])
            )
            return .success(moviePage)
        } catch {
            return .failure(error)
        }
    }

    // Метод декодирует список кадров и возвращает только пути изображений.
    func parseImagePaths(from data: Data) -> Result<[String], Error> {
        do {
            let movieImages = try JSONDecoder().decode(MovieImagesResponse.self, from: data)
            let imagePaths = (movieImages.backdrops ?? []).compactMap(\.filePath)
            return .success(imagePaths)
        } catch {
            return .failure(error)
        }
    }
}

private extension JSONParsingService {
    // Результаты TMDB переносятся в FilmObject через явное сопоставление полей.
    func makeFilms(from results: [MovieResult]) -> [FilmObject] {
        results.compactMap { item in
            guard
                let id = item.id,
                let title = item.title,
                let overview = item.overview,
                let releaseDate = item.releaseDate,
                let voteAverage = item.voteAverage
            else {
                return nil
            }

            let galleryPaths = item.backdropPath.map { [$0] } ?? []

            return FilmObject(
                id: id,
                title: title,
                originalTitle: item.originalTitle ?? "",
                year: Int(releaseDate.prefix(4)) ?? 0,
                rating: voteAverage,
                posterImageName: item.posterPath ?? "",
                overview: overview,
                galleryImageNames: galleryPaths,
                isLiked: false
            )
        }
    }
}
