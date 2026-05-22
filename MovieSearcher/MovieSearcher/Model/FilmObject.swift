//
//  FilmObject.swift
//  MovieSearcher
//
//  Created by OpenAI on 22.05.2026.
//

import UIKit
import RealmSwift

class FilmObject: Object {
    // Идентификатор нужен Realm как primary key и пригодится позже для API.
    @Persisted(primaryKey: true) var id: Int = 0

    // Название фильма хранится как обязательное поле.
    @Persisted var title: String = ""

    // Год выпуска теперь тоже считаем обязательным.
    @Persisted var year: Int = 0

    // Рейтинг нужен и для главного экрана, и для деталей.
    @Persisted var rating: Double = 0

    // Имя постера пока ссылается на локальный ассет.
    @Persisted var posterImageName: String = ""

    // Описание уходит на детальный экран.
    @Persisted var overview: String = ""

    // Имена кадров хранятся как список строк, чтобы позже их заменить на URL.
    @Persisted var galleryImageNames: List<String>

    // Флаг лайка нужен для отбора избранного.
    @Persisted var isLiked: Bool = false

    // Удобный инициализатор нужен для тестового наполнения локальной базы.
    convenience init(
        id: Int,
        title: String,
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

    // Готовый постер пока достается из локальных ассетов.
    var posterImage: UIImage? {
        UIImage(named: posterImageName)
    }

    // Готовая коллекция кадров пока собирается из локальных ассетов.
    var galleryImages: [UIImage] {
        galleryImageNames.compactMap(UIImage.init(named:))
    }
}
