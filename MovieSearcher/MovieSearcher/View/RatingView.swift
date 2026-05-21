//
//  RatingView.swift
//  MovieSearcher
//
//  Created by Борис Ларионов on 20.05.2026.
//

import UIKit

final class RatingView: UIView {
    // Префикс держит одинаковый формат рейтинга на карточке и детальном экране.
    private let ratingTextPrefix = "TMDB: "

    // Лейбл занимает весь контейнер и показывает значение рейтинга.
    private let ratingLabel = UILabel()

    // Размер шрифта меняется снаружи, чтобы компонент жил и в плитке, и в деталях.
    private var fontSize: CGFloat = 13

    // Значение рейтинга хранится отдельно, чтобы можно было обновлять вид без пересоздания view.
    private var rating: Double = 0

    // Инициализатор нужен для создания компонента кодом с готовыми значениями.
    init(rating: Double = 0, fontSize: CGFloat = 13) {
        self.rating = rating
        self.fontSize = fontSize
        super.init(frame: .zero)
        commonInit()
    }

    // Инициализатор нужен для случая, когда view подключается из XIB или storyboard.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    // Метод применяет к лейблу текущий текст, шрифт и цвет.
    func updateAppearance() {
        ratingLabel.text = String(format: "\(ratingTextPrefix)%.1f", rating)
        ratingLabel.font = .systemFont(ofSize: fontSize, weight: .medium)
        ratingLabel.textColor = ratingColor(for: rating)
    }

    // Метод сразу обновляет рейтинг и размер шрифта.
    func configure(rating: Double, fontSize: CGFloat) {
        self.fontSize = fontSize
        self.rating = rating
        updateAppearance()
    }

    // Метод меняет только рейтинг и оставляет прежний размер текста.
    func setRating(_ rating: Double) {
        self.rating = rating
        updateAppearance()
    }

    // Метод меняет только размер шрифта и не трогает рейтинг.
    func setFontSize(_ fontSize: CGFloat) {
        self.fontSize = fontSize
        updateAppearance()
    }
}

private extension RatingView {
    // Общая настройка собирает внутренний лейбл и фиксирует его по краям.
    func commonInit() {
        backgroundColor = .clear

        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.numberOfLines = 1
        ratingLabel.lineBreakMode = .byTruncatingTail
        addSubview(ratingLabel)

        NSLayoutConstraint.activate([
            ratingLabel.topAnchor.constraint(equalTo: topAnchor),
            ratingLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            ratingLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        updateAppearance()
    }

    // Цвет рейтинга повторяет одну и ту же шкалу для всех экранов.
    func ratingColor(for rating: Double) -> UIColor {
        if rating < 6 {
            return .systemRed
        }

        if rating <= 8 {
            return UIColor(red: 0.82, green: 0.63, blue: 0.16, alpha: 1)
        }

        return .systemGreen
    }
}
