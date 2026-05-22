//
//  Model.swift
//  MovieSearcher
//
//  Created by OpenAI on 22.05.2026.
//

import UIKit
import RealmSwift

// Основной массив теперь собирается из Realm и питает главный список.
var testArray: [FilmObject] = []

// Этот массив нужен для сортировки и поиска на главном экране.
var newTestArray: [FilmObject] = []

// Отдельный массив собирает понравившиеся фильмы.
var likedTestArray: [FilmObject] = []

// Флаг управляет направлением сортировки.
var sortAscending = true

final class Model {
    // Экземпляр Realm держит доступ к локальной базе приложения.
    private let realm = try! Realm()

    // Основной Realm-список хранит фильмы в базе.
    private var filmObjects: Results<FilmObject>?

    init() {}

    // Метод готовит базу, добавляет тестовые фильмы и читает их в рабочие массивы.
    func prepareRealmData() {
        seedRealmIfNeeded()
        readRealmData()
        showLikedFilms()
    }

    // Адрес realm-файла удобно смотреть в консоли при отладке.
    func printRealmFilePath() {
        guard let fileURL = realm.configuration.fileURL else {
            return
        }

        print(fileURL.path)
    }

    // Тестовые фильмы записываются в базу только один раз.
    func seedRealmIfNeeded() {
        guard realm.objects(FilmObject.self).isEmpty else {
            return
        }

        let films = makeTestArray()

        do {
            try realm.write {
                realm.add(films, update: .modified)
            }
        } catch {
            print("Realm seed error: \(error.localizedDescription)")
        }
    }

    // Метод выгружает фильмы из Realm в рабочий массив приложения.
    func readRealmData() {
        filmObjects = realm.objects(FilmObject.self)
        testArray = Array(filmObjects ?? realm.objects(FilmObject.self))
    }

    // Метод возвращает фильм по id из общего массива.
    func item(withID id: Int) -> FilmObject? {
        realm.object(ofType: FilmObject.self, forPrimaryKey: id)
    }

    // Метод собирает liked-массив заново.
    @discardableResult
    func showLikedFilms() -> [FilmObject] {
        likedTestArray = Array(realm.objects(FilmObject.self).filter("isLiked == true"))
        return likedTestArray
    }

    // Метод переключает лайк у фильма по его id.
    @discardableResult
    func toggleLikedState(forID id: Int) -> Bool {
        guard let item = item(withID: id) else {
            return false
        }

        do {
            try realm.write {
                item.isLiked.toggle()
            }
        } catch {
            print("Realm write error: \(error.localizedDescription)")
        }

        readRealmData()
        showLikedFilms()
        return item.isLiked
    }

    // Сортировка обновляет рабочий массив для списка.
    func sortFilms() {
        readRealmData()

        guard let filmObjects else {
            newTestArray = []
            return
        }

        let sortedResults = filmObjects.sorted(byKeyPath: "rating", ascending: sortAscending)
        newTestArray = Array(sortedResults)
    }

    // Поиск обновляет рабочий массив по названию фильма.
    func search(with text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedText.isEmpty else {
            sortFilms()
            return
        }

        let searchResults = realm.objects(FilmObject.self)
            .filter("title CONTAINS[c] %@", trimmedText)
            .sorted(byKeyPath: "rating", ascending: sortAscending)

        newTestArray = Array(searchResults)
    }
}

// Тестовый массив пока подменяет реальные данные из TMDB.
private func makeTestArray() -> [FilmObject] {
    let gallery = ["image1", "image2", "image3", "image4", "image5"]

    return [
        FilmObject(id: 0, title: "Тестовый фильм 1", year: 2021, rating: 5.6, posterImageName: "image1", overview: "Небольшое тестовое описание фильма для экрана деталей. Здесь позже появится текст из реального ответа TMDB, поэтому блок уже рассчитан на длинные абзацы.", galleryImageNames: gallery, isLiked: false),
        FilmObject(id: 1, title: "Тестовый фильм 2", year: 2020, rating: 6.1, posterImageName: "image2", overview: "Это демонстрационная карточка фильма. На этом этапе мы проверяем композицию экрана, прокрутку, работу жестов и полноэкранный просмотр изображений.", galleryImageNames: gallery, isLiked: true),
        FilmObject(id: 2, title: "Тестовый фильм 3", year: 2019, rating: 7.5, posterImageName: "image3", overview: "Описание пока тестовое, но уже похоже на реальный сценарий использования. Текст должен спокойно переноситься на несколько строк и не ломать layout экрана.", galleryImageNames: gallery, isLiked: false),
        FilmObject(id: 3, title: "Тестовый фильм 4", year: 2018, rating: 8.3, posterImageName: "image4", overview: "В будущем этот экран будет получать постер, рейтинг, год, галерею и подробное описание из сети. Сейчас нам важнее заложить устойчивую структуру и навигацию.", galleryImageNames: gallery, isLiked: true),
        FilmObject(id: 4, title: "Очень странные дела в примитивном мире друзей", year: 2022, rating: 5.9, posterImageName: "image5", overview: "Длинное название здесь нужно как дополнительный тест: блок с заголовком и правой колонкой не должен разваливаться даже на заметно более длинных строках.", galleryImageNames: gallery, isLiked: false),
        FilmObject(id: 5, title: "Тестовый фильм 6", year: 2023, rating: 6.8, posterImageName: "image6", overview: "Кадры на этом шаге тестовые и одинаковые для всех фильмов. Это позволяет сосредоточиться на взаимодействии экранов до подключения реальных ресурсов.", galleryImageNames: gallery, isLiked: false),
        FilmObject(id: 6, title: "Тестовый фильм 7", year: 2021, rating: 7.4, posterImageName: "image7", overview: "Полноэкранный просмотр строится с прицелом на дальнейшую подгрузку качественных изображений. Превью и оригиналы позже можно будет разделить без переделки архитектуры.", galleryImageNames: gallery, isLiked: true),
        FilmObject(id: 7, title: "Тестовый фильм 8", year: 2020, rating: 8.0, posterImageName: "image8", overview: "Для детального экрана важны не только данные, но и удобная навигация. Поэтому здесь заранее продуманы возврат, fullscreen-режим и счётчик картинок.", galleryImageNames: gallery, isLiked: false),
        FilmObject(id: 8, title: "Тестовый фильм 9", year: 2019, rating: 5.4, posterImageName: "image9", overview: "Светлая и тёмная темы тоже должны работать аккуратно. Этот блок описания нужен в том числе как тестовый объёмный контент для прокрутки.", galleryImageNames: gallery, isLiked: true),
        FilmObject(id: 9, title: "Тестовый фильм 10", year: 2022, rating: 8.1, posterImageName: "image10", overview: "Мы намеренно закладываем сюда многократное переиспользование компонентов: карточка фильма, рейтинг, превью-картинки и экран полного просмотра.", galleryImageNames: gallery, isLiked: false),
        FilmObject(id: 10, title: "Тестовый фильм 11", year: 2023, rating: 7.9, posterImageName: "image11", overview: "Текущий шаг про экран деталей. Следующие итерации уже можно будет посвящать сети, кэшу изображений и реальному контенту без переписывания UI с нуля.", galleryImageNames: gallery, isLiked: false),
        FilmObject(id: 11, title: "Тестовый фильм 12", year: 2021, rating: 6.3, posterImageName: "image12", overview: "Даже тестовый экран должен быть собран как настоящий: с учётом реальных ограничений по текстам, пропорциям постера и поведения полноэкранной галереи.", galleryImageNames: gallery, isLiked: true),
        FilmObject(id: 12, title: "Тестовый фильм 13", year: 2020, rating: 7.2, posterImageName: "image13", overview: "Пока описание единообразное по стилю, но позже можно будет легко подменить его данными из API и посмотреть, как экран ведёт себя на разных фильмах.", galleryImageNames: gallery, isLiked: false),
        FilmObject(id: 13, title: "Тестовый фильм 14", year: 2018, rating: 5.8, posterImageName: "image14", overview: "Главная цель этой стадии — чтобы весь экран ощущался цельным: верхний блок, карусель кадров, описание и fullscreen-режим работали как одна связная история.", galleryImageNames: gallery, isLiked: true),
        FilmObject(id: 14, title: "Тестовый фильм 15", year: 2024, rating: 8.6, posterImageName: "image15", overview: "После подключения реального TMDB здесь можно будет хранить уже не имена локальных изображений, а URL превью и URL полноразмерных картинок без изменения пользовательского сценария.", galleryImageNames: gallery, isLiked: false)
    ]
}
