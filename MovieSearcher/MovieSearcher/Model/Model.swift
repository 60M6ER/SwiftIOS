//
//  Model.swift
//  MovieSearcher
//
//  Created by OpenAI on 22.05.2026.
//

import UIKit

final class Item {
    // Идентификатор помогает находить фильм в общем массиве.
    let id: Int

    // Название фильма.
    let title: String

    // Год пока храним отдельно, чтобы позже спокойно парсить его из даты TMDB.
    let year: Int?

    // Рейтинг пригодится и для плитки, и для детального экрана.
    let rating: Double?

    // Постер пока локальный, позже здесь спокойно останется только превью.
    let posterImage: UIImage?

    // Описание идет на детальный экран.
    let overview: String

    // Имена тестовых кадров нужны для локальной галереи.
    let galleryImageNames: [String]

    // Флаг нравится/не нравится понадобится для избранного.
    var isLiked: Bool

    init(
        id: Int,
        title: String,
        year: Int?,
        rating: Double?,
        posterImage: UIImage?,
        overview: String,
        galleryImageNames: [String],
        isLiked: Bool
    ) {
        self.id = id
        self.title = title
        self.year = year
        self.rating = rating
        self.posterImage = posterImage
        self.overview = overview
        self.galleryImageNames = galleryImageNames
        self.isLiked = isLiked
    }

    // Готовая коллекция кадров пока собирается из локальных ассетов.
    var galleryImages: [UIImage] {
        galleryImageNames.compactMap(UIImage.init(named:))
    }

}

// Основной массив пока играет роль локальной базы фильмов.
var testArray: [Item] = makeTestArray()

// Этот массив нужен для сортировки и поиска на главном экране.
var newTestArray: [Item] = testArray

// Отдельный массив собирает понравившиеся фильмы.
var likedTestArray: [Item] = []

// Флаг управляет направлением сортировки.
var sortAscending = true

final class Model {
    init() {}

    // Метод возвращает фильм по id из общего массива.
    func item(withID id: Int) -> Item? {
        testArray.first { $0.id == id }
    }

    // Метод собирает liked-массив заново.
    @discardableResult
    func showLikedFilms() -> [Item] {
        likedTestArray = testArray.filter { $0.isLiked }
        return likedTestArray
    }

    // Метод переключает лайк у фильма по его id.
    @discardableResult
    func toggleLikedState(forID id: Int) -> Bool {
        guard let item = item(withID: id) else {
            return false
        }

        item.isLiked.toggle()
        showLikedFilms()
        return item.isLiked
    }

    // Сортировка обновляет рабочий массив для списка.
    func sortFilms() {
        newTestArray = testArray.sorted { lhs, rhs in
            let leftRating = lhs.rating ?? 0
            let rightRating = rhs.rating ?? 0
            return sortAscending ? leftRating < rightRating : leftRating > rightRating
        }
    }

    // Поиск обновляет рабочий массив по названию фильма.
    func search(with text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedText.isEmpty else {
            sortFilms()
            return
        }

        newTestArray = testArray.filter { item in
            item.title.localizedCaseInsensitiveContains(trimmedText)
        }

        newTestArray.sort { lhs, rhs in
            let leftRating = lhs.rating ?? 0
            let rightRating = rhs.rating ?? 0
            return sortAscending ? leftRating < rightRating : leftRating > rightRating
        }
    }
}

// Тестовый массив пока подменяет реальные данные из TMDB.
private func makeTestArray() -> [Item] {
    let gallery = ["image1", "image2", "image3", "image4", "image5"]

    return [
        Item(id: 0, title: "Тестовый фильм 1", year: 2021, rating: 5.6, posterImage: UIImage(named: "image1"), overview: "Небольшое тестовое описание фильма для экрана деталей. Здесь позже появится текст из реального ответа TMDB, поэтому блок уже рассчитан на длинные абзацы.", galleryImageNames: gallery, isLiked: false),
        Item(id: 1, title: "Тестовый фильм 2", year: 2020, rating: 6.1, posterImage: UIImage(named: "image2"), overview: "Это демонстрационная карточка фильма. На этом этапе мы проверяем композицию экрана, прокрутку, работу жестов и полноэкранный просмотр изображений.", galleryImageNames: gallery, isLiked: true),
        Item(id: 2, title: "Тестовый фильм 3", year: 2019, rating: 7.5, posterImage: UIImage(named: "image3"), overview: "Описание пока тестовое, но уже похоже на реальный сценарий использования. Текст должен спокойно переноситься на несколько строк и не ломать layout экрана.", galleryImageNames: gallery, isLiked: false),
        Item(id: 3, title: "Тестовый фильм 4", year: 2018, rating: 8.3, posterImage: UIImage(named: "image4"), overview: "В будущем этот экран будет получать постер, рейтинг, год, галерею и подробное описание из сети. Сейчас нам важнее заложить устойчивую структуру и навигацию.", galleryImageNames: gallery, isLiked: true),
        Item(id: 4, title: "Очень странные дела в примитивном мире друзей", year: 2022, rating: 5.9, posterImage: UIImage(named: "image5"), overview: "Длинное название здесь нужно как дополнительный тест: блок с заголовком и правой колонкой не должен разваливаться даже на заметно более длинных строках.", galleryImageNames: gallery, isLiked: false),
        Item(id: 5, title: "Тестовый фильм 6", year: 2023, rating: 6.8, posterImage: UIImage(named: "image6"), overview: "Кадры на этом шаге тестовые и одинаковые для всех фильмов. Это позволяет сосредоточиться на взаимодействии экранов до подключения реальных ресурсов.", galleryImageNames: gallery, isLiked: false),
        Item(id: 6, title: "Тестовый фильм 7", year: 2021, rating: 7.4, posterImage: UIImage(named: "image7"), overview: "Полноэкранный просмотр строится с прицелом на дальнейшую подгрузку качественных изображений. Превью и оригиналы позже можно будет разделить без переделки архитектуры.", galleryImageNames: gallery, isLiked: true),
        Item(id: 7, title: "Тестовый фильм 8", year: 2020, rating: 8.0, posterImage: UIImage(named: "image8"), overview: "Для детального экрана важны не только данные, но и удобная навигация. Поэтому здесь заранее продуманы возврат, fullscreen-режим и счётчик картинок.", galleryImageNames: gallery, isLiked: false),
        Item(id: 8, title: "Тестовый фильм 9", year: 2019, rating: 5.4, posterImage: UIImage(named: "image9"), overview: "Светлая и тёмная темы тоже должны работать аккуратно. Этот блок описания нужен в том числе как тестовый объёмный контент для прокрутки.", galleryImageNames: gallery, isLiked: true),
        Item(id: 9, title: "Тестовый фильм 10", year: 2022, rating: 8.1, posterImage: UIImage(named: "image10"), overview: "Мы намеренно закладываем сюда многократное переиспользование компонентов: карточка фильма, рейтинг, превью-картинки и экран полного просмотра.", galleryImageNames: gallery, isLiked: false),
        Item(id: 10, title: "Тестовый фильм 11", year: 2023, rating: 7.9, posterImage: UIImage(named: "image11"), overview: "Текущий шаг про экран деталей. Следующие итерации уже можно будет посвящать сети, кэшу изображений и реальному контенту без переписывания UI с нуля.", galleryImageNames: gallery, isLiked: false),
        Item(id: 11, title: "Тестовый фильм 12", year: 2021, rating: 6.3, posterImage: UIImage(named: "image12"), overview: "Даже тестовый экран должен быть собран как настоящий: с учётом реальных ограничений по текстам, пропорциям постера и поведения полноэкранной галереи.", galleryImageNames: gallery, isLiked: true),
        Item(id: 12, title: "Тестовый фильм 13", year: 2020, rating: 7.2, posterImage: UIImage(named: "image13"), overview: "Пока описание единообразное по стилю, но позже можно будет легко подменить его данными из API и посмотреть, как экран ведёт себя на разных фильмах.", galleryImageNames: gallery, isLiked: false),
        Item(id: 13, title: "Тестовый фильм 14", year: 2018, rating: 5.8, posterImage: UIImage(named: "image14"), overview: "Главная цель этой стадии — чтобы весь экран ощущался цельным: верхний блок, карусель кадров, описание и fullscreen-режим работали как одна связная история.", galleryImageNames: gallery, isLiked: true),
        Item(id: 14, title: "Тестовый фильм 15", year: 2024, rating: 8.6, posterImage: UIImage(named: "image15"), overview: "После подключения реального TMDB здесь можно будет хранить уже не имена локальных изображений, а URL превью и URL полноразмерных картинок без изменения пользовательского сценария.", galleryImageNames: gallery, isLiked: false)
    ]
}
