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
}

extension TestModel {
    static let lessonSamples: [TestModel] = [
        TestModel(title: "Тестовый фильм 1", year: "2021", rating: 5.6, posterImage: UIImage(named: "image1")),
        TestModel(title: "Тестовый фильм 2", year: "2020", rating: 6.1, posterImage: UIImage(named: "image2")),
        TestModel(title: "Тестовый фильм 3", year: "2019", rating: 7.5, posterImage: UIImage(named: "image3")),
        TestModel(title: "Тестовый фильм 4", year: "2018", rating: 8.3, posterImage: UIImage(named: "image4")),
        TestModel(title: "Очень странные дела в примитивном мире друзей", year: "2022", rating: 5.9, posterImage: UIImage(named: "image5")),
        TestModel(title: "Тестовый фильм 6", year: "2023", rating: 6.8, posterImage: UIImage(named: "image6")),
        TestModel(title: "Тестовый фильм 7", year: "2021", rating: 7.4, posterImage: UIImage(named: "image7")),
        TestModel(title: "Тестовый фильм 8", year: "2020", rating: 8.0, posterImage: UIImage(named: "image8")),
        TestModel(title: "Тестовый фильм 9", year: "2019", rating: 5.4, posterImage: UIImage(named: "image9")),
        TestModel(title: "Тестовый фильм 10", year: "2022", rating: 8.1, posterImage: UIImage(named: "image10")),
        TestModel(title: "Тестовый фильм 11", year: "2023", rating: 7.9, posterImage: UIImage(named: "image11")),
        TestModel(title: "Тестовый фильм 12", year: "2021", rating: 6.3, posterImage: UIImage(named: "image12")),
        TestModel(title: "Тестовый фильм 13", year: "2020", rating: 7.2, posterImage: UIImage(named: "image13")),
        TestModel(title: "Тестовый фильм 14", year: "2018", rating: 5.8, posterImage: UIImage(named: "image14")),
        TestModel(title: "Тестовый фильм 15", year: "2024", rating: 8.6, posterImage: UIImage(named: "image15"))
    ]
}
