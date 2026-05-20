//
//  FilmCollectionViewCell.swift
//  MovieSearcher
//
//  Created by Codex on 20.05.2026.
//

import UIKit

final class FilmCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "FilmCollectionViewCell"

    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let yearLabel = UILabel()
    private let ratingLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configurePosterImageView()
        configureLabels()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
        configurePosterImageView()
        configureLabels()
        configureLayout()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        titleLabel.text = nil
        yearLabel.text = nil
        ratingLabel.text = nil
    }

    func configure(with model: TestModel) {
        titleLabel.text = model.title
        yearLabel.text = model.year
        ratingLabel.text = String(format: "TMDB: %.1f", model.rating)
        ratingLabel.textColor = ratingColor(for: model.rating)
        posterImageView.image = model.posterImage
    }
}

private extension FilmCollectionViewCell {
    func configureView() {
        contentView.backgroundColor = UIColor(named: "TileBackgound") ?? .secondarySystemBackground
        contentView.layer.cornerRadius = 18
        contentView.layer.cornerCurve = .continuous
        contentView.layer.masksToBounds = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.shadowRadius = 16
    }

    func configurePosterImageView() {
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
    }

    func configureLabels() {
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        yearLabel.font = .systemFont(ofSize: 13, weight: .regular)
        yearLabel.textColor = .secondaryLabel
        yearLabel.numberOfLines = 1
        yearLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        yearLabel.textAlignment = .right
        yearLabel.translatesAutoresizingMaskIntoConstraints = false

        ratingLabel.font = .systemFont(ofSize: 13, weight: .medium)
        ratingLabel.numberOfLines = 1
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    func configureLayout() {
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(yearLabel)
        contentView.addSubview(ratingLabel)

        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.72),

            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 44),

            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            ratingLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            ratingLabel.trailingAnchor.constraint(lessThanOrEqualTo: yearLabel.leadingAnchor, constant: -8),

            yearLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            yearLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: yearLabel.topAnchor, constant: -6)
        ])
    }

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
