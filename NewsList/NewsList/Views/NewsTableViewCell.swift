//
//  NewsTableViewCell.swift
//  NewsList
//
//  Created by Борис Ларионов on 18.05.2026.
//

import UIKit
import Kingfisher

// Кастомная ячейка отвечает только за отображение картинки, текста и даты новости.
final class NewsTableViewCell: UITableViewCell {
    // Идентификатор нужен для регистрации и повторного использования ячейки в таблице.
    static let reuseIdentifier = "NewsTableViewCell"

    // Верхний лейбл показывает источник и заголовок новости.
    private let headlineLabel = UILabel()

    // Изображение новости загружается асинхронно и кэшируется Kingfisher.
    private let previewImageView = UIImageView()

    // Описание новости заполняет правую часть нижнего блока.
    private let descriptionLabel = UILabel()

    // Нижняя подпись показывает дату публикации в привычном для пользователя формате.
    private let dateLabel = UILabel()

    // Горизонтальный стек объединяет картинку и описание в один нижний блок.
    private let contentStackView = UIStackView()

    // Форматтер преобразует ISO-дату из API в русское представление для интерфейса.
    private let inputDateFormatter = ISO8601DateFormatter()

    // Форматтер создает строку даты, понятную пользователю.
    private let outputDateFormatter = DateFormatter()

    // Инициализация
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupFormatters()
        setupView()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Подготовка к повторному использованию очищает картинку и тексты от старой новости.
    override func prepareForReuse() {
        super.prepareForReuse()
        previewImageView.kf.cancelDownloadTask()
        previewImageView.image = UIImage(named: "no-image")
        headlineLabel.text = nil
        descriptionLabel.text = nil
        dateLabel.text = nil
    }

    // Метод применяет модель новости к визуальным элементам ячейки.
    func configure(with article: NewsArticle) {
        headlineLabel.text = article.headlineText
        descriptionLabel.text = article.descriptionText
        dateLabel.text = formattedDate(from: article.publishedAt)

        let placeholderImage = UIImage(named: "no-image")
        previewImageView.kf.indicatorType = .activity
        previewImageView.kf.setImage(
            with: article.imageURL,
            placeholder: placeholderImage,
            options: [.transition(.fade(1.0))]
        )
    }

    // Форматтеры настраиваются один раз, чтобы не повторять это в каждом configure.
    private func setupFormatters() {
        inputDateFormatter.formatOptions = [.withInternetDateTime]
        outputDateFormatter.locale = Locale(identifier: "ru_RU")
        outputDateFormatter.dateStyle = .medium
        outputDateFormatter.timeStyle = .short
    }

    // Настройка View-элементов.
    private func setupView() {
        selectionStyle = .none
        accessoryType = .disclosureIndicator

        headlineLabel.font = .systemFont(ofSize: 16, weight: .bold)
        headlineLabel.numberOfLines = 0

        previewImageView.contentMode = .scaleAspectFill
        previewImageView.clipsToBounds = true
        previewImageView.layer.cornerRadius = 10
        previewImageView.image = UIImage(named: "no-image")

        descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .secondaryLabel

        dateLabel.font = .systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = .tertiaryLabel
        dateLabel.numberOfLines = 1

        contentStackView.axis = .horizontal
        contentStackView.spacing = 12
        contentStackView.alignment = .top
        contentStackView.distribution = .fill

        contentView.addSubview(headlineLabel)
        contentView.addSubview(contentStackView)
        contentView.addSubview(dateLabel)
        contentStackView.addArrangedSubview(previewImageView)
        contentStackView.addArrangedSubview(descriptionLabel)
    }

    // Констрейнты
    private func setupLayout() {
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headlineLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            headlineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headlineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            contentStackView.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 10),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            previewImageView.widthAnchor.constraint(equalToConstant: 100),
            previewImageView.heightAnchor.constraint(equalToConstant: 100),

            dateLabel.topAnchor.constraint(equalTo: contentStackView.bottomAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14)
        ])
    }

    // Метод переводит дату из строки API в локализованный человекочитаемый текст.
    private func formattedDate(from string: String) -> String {
        if let date = inputDateFormatter.date(from: string) {
            return outputDateFormatter.string(from: date)
        }

        return "Дата неизвестна"
    }
}
