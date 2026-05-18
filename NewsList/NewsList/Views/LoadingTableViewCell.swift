//
//  LoadingTableViewCell.swift
//  NewsList
//
//  Created by Борис Ларионов on 18.05.2026.
//

import UIKit

// Служебная ячейка показывает системную анимацию загрузки для первой страницы и пагинации.
final class LoadingTableViewCell: UITableViewCell {
    // Идентификатор нужен для регистрации loading-ячейки в таблице.
    static let reuseIdentifier = "LoadingTableViewCell"

    // Индикатор показывает, что сейчас идет сетевой запрос.
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    // Подпись делает ячейку понятной для проверяющего и пользователя.
    private let loadingLabel = UILabel()

    // Инициализация.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Метод запускает анимацию и задает текст в зависимости от этапа загрузки.
    func configure(text: String) {
        loadingLabel.text = text
        activityIndicator.startAnimating()
    }

    // Настройка View-элементов
    private func setupView() {
        selectionStyle = .none

        loadingLabel.font = .systemFont(ofSize: 14, weight: .medium)
        loadingLabel.textColor = .secondaryLabel
        loadingLabel.textAlignment = .center

        contentView.addSubview(activityIndicator)
        contentView.addSubview(loadingLabel)
    }

    // Констрейнты
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
