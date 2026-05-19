//
//  VideoContentCell.swift
//  VideoPlayer
//
//  Created by Борис Ларионов on 19.05.2026.
//

import UIKit

// Ячейка показывает картинку видео и его заголовок в таблице.
class VideoContentCell: UITableViewCell {
    // Идентификатор нужен для регистрации и повторного использования ячейки.
    static let reuseIdentifier = "VideoContentCell"

    // Картинка показывает заставку выбранного видео.
    private let imageVideoContent = UIImageView()

    // Лейбл показывает название ролика.
    private let labelVideoContent = UILabel()

    // Модель ячейки запускает обновление интерфейса после присваивания.
    public var video: Video! {
        didSet {
            updateUI()
        }
    }

    // Инициализация.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Метод применяет модель к картинке и заголовку ячейки.
    private func updateUI() {
        imageVideoContent.layer.cornerRadius = 10
        imageVideoContent.clipsToBounds = true
        imageVideoContent.contentMode = .scaleAspectFill
        imageVideoContent.image = video.videoImage
        labelVideoContent.text = video.videoTitle
    }

    // Метод настраивает элементы ячейки и добавляет их в contentView.
    private func setupView() {
        accessoryType = .disclosureIndicator

        labelVideoContent.font = .systemFont(ofSize: 19, weight: .regular)
        labelVideoContent.numberOfLines = 0

        contentView.addSubview(imageVideoContent)
        contentView.addSubview(labelVideoContent)
    }

    // Констрейнты.
    private func setupLayout() {
        imageVideoContent.translatesAutoresizingMaskIntoConstraints = false
        labelVideoContent.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageVideoContent.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imageVideoContent.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            imageVideoContent.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            imageVideoContent.widthAnchor.constraint(equalToConstant: 136),
            imageVideoContent.heightAnchor.constraint(equalToConstant: 100),

            labelVideoContent.leadingAnchor.constraint(equalTo: imageVideoContent.trailingAnchor, constant: 12),
            labelVideoContent.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            labelVideoContent.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
