//
//  ImageCollectionViewCell.swift
//  PicSearcher
//
//  Created by Борис Ларионов on 19.05.2026.
//

import UIKit
import Kingfisher

// Кастомная ячейка отвечает только за отображение превью изображения в сетке.
final class ImageCollectionViewCell: UICollectionViewCell {
    // Идентификатор нужен для регистрации и повторного использования ячейки в коллекции.
    static let reuseIdentifier = "ImageCollectionViewCell"

    // Изображение загружается асинхронно и кэшируется Kingfisher.
    private let previewImageView = UIImageView()

    // Инициализация.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Подготовка к повторному использованию очищает картинку от старого результата поиска.
    override func prepareForReuse() {
        super.prepareForReuse()
        previewImageView.kf.cancelDownloadTask()
        previewImageView.image = UIImage(named: "no-image")
    }

    // Метод применяет модель картинки к визуальным элементам ячейки.
    func configure(with picture: Picture) {
        let placeholderImage = UIImage(named: "no-image")
        previewImageView.kf.indicatorType = .activity
        previewImageView.kf.setImage(
            with: picture.previewURL,
            placeholder: placeholderImage,
            options: [.transition(.fade(1.0))]
        )
    }

    // Настройка View-элементов.
    private func setupView() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        previewImageView.contentMode = .scaleAspectFill
        previewImageView.clipsToBounds = true
        previewImageView.image = UIImage(named: "no-image")

        contentView.addSubview(previewImageView)
    }

    // Констрейнты.
    private func setupLayout() {
        previewImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            previewImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            previewImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            previewImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            previewImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
