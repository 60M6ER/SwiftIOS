//
//  FilmObject.swift
//  MovieSearcher
//
//  Created by OpenAI on 22.05.2026.
//

import RealmSwift

class FilmObject: Object {
    // Идентификатор нужен Realm как primary key и пригодится позже для API.
    @Persisted(primaryKey: true) var id: Int = 0

    // Название фильма хранится как обязательное поле.
    @Persisted var title: String = ""

    // Оригинальное название можно хранить отдельно от локализованного.
    @Persisted var originalTitle: String = ""

    // Нормализованная строка нужна для локального поиска по избранному.
    @Persisted var searchTitle: String = ""

    // Год выпуска теперь тоже считаем обязательным.
    @Persisted var year: Int = 0

    // Рейтинг нужен и для главного экрана, и для деталей.
    @Persisted var rating: Double = 0

    // Строка постера хранит путь TMDB для карточки и fullscreen.
    @Persisted var posterImageName: String = ""

    // Описание уходит на детальный экран.
    @Persisted var overview: String = ""

    // Имена кадров хранятся как список строк, чтобы позже их заменить на URL.
    @Persisted var galleryImageNames: List<String>

    // Флаг лайка нужен для отбора избранного.
    @Persisted var isLiked: Bool = false

    // Удобный инициализатор нужен для явного создания объекта фильма из ответа TMDB и Realm-кэша.
    convenience init(
        id: Int,
        title: String,
        originalTitle: String = "",
        year: Int,
        rating: Double,
        posterImageName: String,
        overview: String,
        galleryImageNames: [String],
        isLiked: Bool
    ) {
        self.init()
        self.id = id
        self.title = title
        self.originalTitle = originalTitle
        self.searchTitle = Self.makeSearchTitle(title: title, originalTitle: originalTitle)
        self.year = year
        self.rating = rating
        self.posterImageName = posterImageName
        self.overview = overview
        self.galleryImageNames.append(objectsIn: galleryImageNames)
        self.isLiked = isLiked
    }

    // Primary key позволяет находить и обновлять конкретный объект по id.
    override class func primaryKey() -> String? {
        "id"
    }

    // Поисковая строка объединяет локальный и оригинальный заголовки в нижнем регистре.
    private static func makeSearchTitle(title: String, originalTitle: String) -> String {
        [title, originalTitle]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .lowercased()
    }
}
