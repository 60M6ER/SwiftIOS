//
//  JSONModel.swift
//  MovieSearcher
//
//  Created by Kirill Timanovsky on 30.07.2021.
//

import Foundation
import UIKit

class JSONModel: Codable {
    var original_title: String?
    var poster_path: String?
    var release_date: String?
    var overview: String?
    var vote_average: Double?
    var backdrop_path: String?
}

struct TestModel {
    let title: String
    let year: String
    let rating: Double
    let posterImage: UIImage?
    let overview: String
    let galleryImageNames: [String]
}

extension TestModel {
    static let sharedGalleryImageNames = ["image1", "image2", "image3", "image4", "image5"]

    static let lessonSamples: [TestModel] = [
        TestModel(title: "Тестовый фильм 1", year: "2021", rating: 5.6, posterImage: UIImage(named: "image1"), overview: "Небольшое тестовое описание фильма для экрана деталей. Здесь позже появится текст из реального ответа TMDB, поэтому блок уже рассчитан на длинные абзацы.", galleryImageNames: sharedGalleryImageNames),
        TestModel(title: "Тестовый фильм 2", year: "2020", rating: 6.1, posterImage: UIImage(named: "image2"), overview: "Это демонстрационная карточка фильма. На этом этапе мы проверяем композицию экрана, прокрутку, работу жестов и полноэкранный просмотр изображений.", galleryImageNames: sharedGalleryImageNames),
        TestModel(title: "Тестовый фильм 3", year: "2019", rating: 7.5, posterImage: UIImage(named: "image3"), overview: "Описание пока тестовое, но уже похоже на реальный сценарий использования. Текст должен спокойно переноситься на несколько строк и не ломать layout экрана.", galleryImageNames: sharedGalleryImageNames),
        TestModel(title: "Тестовый фильм 4", year: "2018", rating: 8.3, posterImage: UIImage(named: "image4"), overview: "В будущем этот экран будет получать постер, рейтинг, год, галерею и подробное описание из сети. Сейчас нам важнее заложить устойчивую структуру и навигацию.", galleryImageNames: sharedGalleryImageNames),
        TestModel(title: "Очень странные дела в примитивном мире друзей", year: "2022", rating: 5.9, posterImage: UIImage(named: "image5"), overview: "Длинное название здесь нужно как дополнительный тест: блок с заголовком и правой колонкой не должен разваливаться даже на заметно более длинных строках.", galleryImageNames: sharedGalleryImageNames),
        TestModel(title: "Тестовый фильм 6", year: "2023", rating: 6.8, posterImage: UIImage(named: "image6"), overview: "Кадры на этом шаге тестовые и одинаковые для всех фильмов. Это позволяет сосредоточиться на взаимодействии экранов до подключения реальных ресурсов.", galleryImageNames: sharedGalleryImageNames),
        TestModel(title: "Тестовый фильм 7", year: "2021", rating: 7.4, posterImage: UIImage(named: "image7"), overview: "Полноэкранный просмотр строится с прицелом на дальнейшую подгрузку качественных изображений. Превью и оригиналы позже можно будет разделить без переделки архитектуры.", galleryImageNames: sharedGalleryImageNames),
        TestModel(title: "Тестовый фильм 8", year: "2020", rating: 8.0, posterImage: UIImage(named: "image8"), overview: "Для детального экрана важны не только данные, но и удобная навигация. Поэтому здесь заранее продуманы возврат, fullscreen-режим и счётчик картинок.", galleryImageNames: sharedGalleryImageNames),
        TestModel(title: "Тестовый фильм 9", year: "2019", rating: 5.4, posterImage: UIImage(named: "image9"), overview: "Светлая и тёмная темы тоже должны работать аккуратно. Этот блок описания нужен в том числе как тестовый объёмный контент для прокрутки.", galleryImageNames: sharedGalleryImageNames),
        TestModel(title: "Тестовый фильм 10", year: "2022", rating: 8.1, posterImage: UIImage(named: "image10"), overview: "Мы намеренно закладываем сюда многократное переиспользование компонентов: карточка фильма, рейтинг, превью-картинки и экран полного просмотра.", galleryImageNames: sharedGalleryImageNames),
        TestModel(title: "Тестовый фильм 11", year: "2023", rating: 7.9, posterImage: UIImage(named: "image11"), overview: "Текущий шаг про экран деталей. Следующие итерации уже можно будет посвящать сети, кэшу изображений и реальному контенту без переписывания UI с нуля.", galleryImageNames: sharedGalleryImageNames),
        TestModel(title: "Тестовый фильм 12", year: "2021", rating: 6.3, posterImage: UIImage(named: "image12"), overview: "Даже тестовый экран должен быть собран как настоящий: с учётом реальных ограничений по текстам, пропорциям постера и поведения полноэкранной галереи.", galleryImageNames: sharedGalleryImageNames),
        TestModel(title: "Тестовый фильм 13", year: "2020", rating: 7.2, posterImage: UIImage(named: "image13"), overview: "Пока описание единообразное по стилю, но позже можно будет легко подменить его данными из API и посмотреть, как экран ведёт себя на разных фильмах.", galleryImageNames: sharedGalleryImageNames),
        TestModel(title: "Тестовый фильм 14", year: "2018", rating: 5.8, posterImage: UIImage(named: "image14"), overview: "Главная цель этой стадии — чтобы весь экран ощущался цельным: верхний блок, карусель кадров, описание и fullscreen-режим работали как одна связная история.", galleryImageNames: sharedGalleryImageNames),
        TestModel(title: "Тестовый фильм 15", year: "2024", rating: 8.6, posterImage: UIImage(named: "image15"), overview: "После подключения реального TMDB здесь можно будет хранить уже не имена локальных изображений, а URL превью и URL полноразмерных картинок без изменения пользовательского сценария.", galleryImageNames: sharedGalleryImageNames)
    ]

    var galleryImages: [UIImage] {
        galleryImageNames.compactMap(UIImage.init(named:))
    }
}
