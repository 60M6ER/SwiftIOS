//
//  LoadingCollectionViewCell.swift
//  PicSearcher
//
//  Created by Борис Ларионов on 19.05.2026.
//

import UIKit

// Служебная ячейка показывает системную анимацию загрузки для первой страницы и пагинации.
final class LoadingCollectionViewCell: UICollectionViewCell {
    // Идентификатор нужен для регистрации loading-ячейки в коллекции.
    static let reuseIdentifier = "LoadingCollectionViewCell"

    // Индикатор показывает, что сейчас идет сетевой запрос.
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    // Подпись делает ячейку понятной для проверяющего и пользователя.
    private let loadingLabel = UILabel()

    // Инициализация.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Подготовка к повторному использованию очищает старый текст загрузки.
    override func prepareForReuse() {
        super.prepareForReuse()
        activityIndicator.stopAnimating()
        loadingLabel.text = nil
    }

    // Метод запускает анимацию и задает текст в зависимости от этапа загрузки.
    func configure(text: String) {
        loadingLabel.text = text
        activityIndicator.startAnimating()
    }

    // Настройка View-элементов.
    private func setupView() {
        contentView.backgroundColor = .clear

        loadingLabel.font = .systemFont(ofSize: 14, weight: .medium)
        loadingLabel.textColor = .secondaryLabel
        loadingLabel.textAlignment = .center

        contentView.addSubview(activityIndicator)
        contentView.addSubview(loadingLabel)
    }

    // Констрейнты.
    private func setupLayout() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            loadingLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            loadingLabel.leadingAnchor.constraint(equalTo: activityIndicator.trailingAnchor, constant: 12),
            loadingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            loadingLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            loadingLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
