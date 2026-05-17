//
//  ThemeToggleControl.swift
//  ImagesWithsUserDefoults
//
//  Created by Борис Ларионов on 17.05.2026.
//

import UIKit

// Кастомный переключатель
final class ThemeToggleControl: UIControl {
    // Свойство хранит текущее положение переключателя.
    private(set) var isOn = false

    // Основной контейнер формирует форму переключателя.
    private let trackView = UIView()

    // Выделенная подложка перемещается между левой и правой половиной.
    private let selectionView = UIView()

    // Левая иконка отвечает за светлую тему.
    private let sunImageView = UIImageView()

    // Правая иконка отвечает за темную тему.
    private let moonImageView = UIImageView()

    // Горизонтальный стек упрощает симметричное размещение иконок.
    private let iconsStackView = UIStackView()

    // Констрейнт позволяет двигать выделенную зону без ручного пересчета фреймов.
    private var selectionLeadingConstraint: NSLayoutConstraint?

    // Внутренний отступ делает control аккуратнее и ближе к стилю системного switch.
    private let contentInset: CGFloat = 6

    // Программная инициализация создает и настраивает переключатель.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
        setupInteraction()
        updateAppearance(animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // При изменении размеров контрол пересчитывает радиусы скругления.
    override func layoutSubviews() {
        super.layoutSubviews()
        trackView.layer.cornerRadius = bounds.height / 2
        selectionView.layer.cornerRadius = (bounds.height - contentInset * 2) / 2
        updateAppearance(animated: false)
    }

    // Внешний метод меняет состояние переключателя и при необходимости анимирует это изменение.
    func setOn(_ isOn: Bool, animated: Bool) {
        self.isOn = isOn
        updateAppearance(animated: animated)
    }

    // Настраивает базовый внешний вид составных частей кастомного switch.
    private func setupView() {
        backgroundColor = .clear

        trackView.backgroundColor = UIColor.secondarySystemFill
        trackView.isUserInteractionEnabled = false

        selectionView.backgroundColor = UIColor(named: "SwitchAccentLight")
        selectionView.isUserInteractionEnabled = false

        sunImageView.image = UIImage(systemName: "sun.max")
        sunImageView.contentMode = .scaleAspectFit

        moonImageView.image = UIImage(systemName: "moon")
        moonImageView.contentMode = .scaleAspectFit

        iconsStackView.axis = .horizontal
        iconsStackView.distribution = .fillEqually
        iconsStackView.alignment = .fill
        iconsStackView.isUserInteractionEnabled = false

        addSubview(trackView)
        trackView.addSubview(selectionView)
        trackView.addSubview(iconsStackView)
        iconsStackView.addArrangedSubview(sunImageView)
        iconsStackView.addArrangedSubview(moonImageView)
    }

    // Создает констрейнты для трека, выделения и иконок.
    private func setupLayout() {
        trackView.translatesAutoresizingMaskIntoConstraints = false
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        iconsStackView.translatesAutoresizingMaskIntoConstraints = false
        sunImageView.translatesAutoresizingMaskIntoConstraints = false
        moonImageView.translatesAutoresizingMaskIntoConstraints = false

        selectionLeadingConstraint = selectionView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor, constant: contentInset)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 68),
            widthAnchor.constraint(equalToConstant: 152),

            trackView.topAnchor.constraint(equalTo: topAnchor),
            trackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            trackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            selectionView.topAnchor.constraint(equalTo: trackView.topAnchor, constant: contentInset),
            selectionView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor, constant: -contentInset),
            selectionView.widthAnchor.constraint(equalTo: trackView.widthAnchor, multiplier: 0.5, constant: -contentInset),

            iconsStackView.topAnchor.constraint(equalTo: trackView.topAnchor),
            iconsStackView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            iconsStackView.trailingAnchor.constraint(equalTo: trackView.trailingAnchor),
            iconsStackView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor),

            selectionLeadingConstraint!
        ])
    }

    // Добавляет обработчик тапа, чтобы control вел себя как стандартный переключатель.
    private func setupInteraction() {
        addTarget(self, action: #selector(toggleValue), for: .touchUpInside)
    }

    // Переключает состояние, обновляет внешний вид и отправляет наружу событие valueChanged.
    @objc private func toggleValue() {
        isOn.toggle()
        updateAppearance(animated: true)
        sendActions(for: .valueChanged)
    }

    // Синхронизирует положение выделения, цвета иконок и оттенок активной половины.
    private func updateAppearance(animated: Bool) {
        let selectedColorName = isOn ? "SwitchAccentDark" : "SwitchAccentLight"
        let selectedColor = UIColor(named: selectedColorName) ?? .systemBlue
        let activeTintColor = UIColor.label
        let inactiveTintColor = UIColor.secondaryLabel

        selectionView.backgroundColor = selectedColor
        selectionLeadingConstraint?.constant = isOn ? bounds.width / 2 : contentInset
        sunImageView.tintColor = isOn ? inactiveTintColor : activeTintColor
        moonImageView.tintColor = isOn ? activeTintColor : inactiveTintColor

        let animationBlock = {
            self.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.86, initialSpringVelocity: 0.2) {
                animationBlock()
            }
        } else {
            animationBlock()
        }
    }
}
