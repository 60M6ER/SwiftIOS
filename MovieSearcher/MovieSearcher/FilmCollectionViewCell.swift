//
//  FilmCollectionViewCell.swift
//  MovieSearcher
//
//  Created by Борис Ларионов on 20.05.2026.
//

import UIKit

final class FilmCollectionViewCell: UICollectionViewCell {
    // Идентификатор нужен коллекции для регистрации и повторного использования ячейки.
    static let reuseIdentifier = "FilmCell"

    // Имя XIB нужно для подключения внешнего шаблона ячейки.
    static let nibName = "FilmCollectionViewCell"

    // Постер занимает верхнюю часть карточки.
    @IBOutlet weak var imageView: UIImageView!

    // Название фильма показывает заголовок плитки.
    @IBOutlet weak var titleLable: UILabel!

    // Переиспользуемый блок рейтинга живет отдельно от карточки.
    @IBOutlet weak var ratingView: RatingView!

    // Год выпуска стоит в правом нижнем углу карточки.
    @IBOutlet weak var yearLabel: UILabel!

    // Контейнер держит нижнюю текстовую часть отдельно от постера.
    @IBOutlet weak var infoContainer: UIView!
    
    // После загрузки XIB здесь задается внешний вид карточки.
    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
        configureImageView()
        configureLabels()
    }

    // Перед повторным использованием ячейка убирает старые данные.
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLable.text = nil
        yearLabel.text = nil
    }

    // Метод переносит модель фильма в элементы карточки.
    func configure(with model: TestModel) {
        imageView.image = model.posterImage
        titleLable.text = model.title
        ratingView.configure(rating: model.rating, fontSize: 13)
        yearLabel.text = model.year
    }
}

private extension FilmCollectionViewCell {
    // Общая настройка задает фон, скругление и базовое поведение контейнеров.
    func configureView() {
        contentView.backgroundColor =
            UIColor(named: "TileBackground")
            ?? UIColor(named: "TileBackgound")
            ?? .secondarySystemBackground
        contentView.layer.cornerRadius = 18
        contentView.layer.cornerCurve = .continuous
        contentView.layer.masksToBounds = true
        infoContainer.backgroundColor = .clear
    }

    // Постер должен плотно заполнять верхний блок карточки.
    func configureImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }

    // Настройка шрифтов и поведения текстов внутри плитки.
    func configureLabels() {
        titleLable.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLable.numberOfLines = 2
        titleLable.lineBreakMode = .byTruncatingTail

        yearLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        yearLabel.textColor = .secondaryLabel
        yearLabel.numberOfLines = 1
        yearLabel.textAlignment = .right
    }
}
