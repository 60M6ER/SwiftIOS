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

    // Модель нужна ячейке только для переключения лайка по id.
    private let model = Model()

    // Сервис нужен для загрузки постера по ссылке из TMDB.
    private let tmdbService = TMDBService.shared

    // Локальное состояние пока меняет только внешний вид сердца в ячейке.
    private var isLiked = false

    // Текущий фильм нужен ячейке для синхронизации лайка с локальной базой.
    private var film: FilmObject?

    // Событие наружу нужно, чтобы экран мог обновить свои массивы и фильтры.
    var onLikeStateChanged: ((Int, Bool) -> Void)?

    @IBOutlet weak var likeButton: UIButton!
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
        configureLikeButton()
    }

    // Перед повторным использованием ячейка убирает старые данные.
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLable.text = nil
        yearLabel.text = nil
        isLiked = false
        film = nil
        onLikeStateChanged = nil
        updateLikeButtonAppearance()
    }

    // Метод переносит модель фильма в элементы карточки.
    func configure(with model: FilmObject) {
        film = model
        imageView.image = nil
        titleLable.text = model.title
        ratingView.configure(rating: model.rating, fontSize: 13)
        yearLabel.text = String(model.year)
        isLiked = model.isLiked
        accessibilityIdentifier = "main.filmCell"
        updateLikeButtonAppearance()

        if let posterURL = tmdbService.makePosterURL(path: model.posterImageName) {
            tmdbService.getSetPoster(url: posterURL) { [weak self] image in
                self?.imageView.image = image
            }
        }
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

    // Сердце пока живет только внутри ячейки и меняет свое состояние по тапу.
    func configureLikeButton() {
        likeButton.tintColor = .systemRed
        likeButton.addTarget(self, action: #selector(handleLikeTap), for: .touchUpInside)
        updateLikeButtonAppearance()
    }

    // Кнопка показывает контурное или залитое сердце.
    func updateLikeButtonAppearance() {
        let imageName = isLiked ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    // Тап пока только переключает иконку внутри ячейки.
    @objc func handleLikeTap() {
        guard let film else {
            return
        }

        isLiked = model.toggleLikedState(for: film)
        updateLikeButtonAppearance()
        onLikeStateChanged?(film.id, isLiked)
    }
}
