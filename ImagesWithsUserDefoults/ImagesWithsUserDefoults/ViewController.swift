//
//  ViewController.swift
//  ImagesWithsUserDefoults
//
//  Created by Борис Ларионов on 17.05.2026.
//

import UIKit

// Контроллер связывает модель темы, картинку и кастомный переключатель в одном экране.
final class ViewController: UIViewController {
    // Модель хранит и читает выбранное состояние темы.
    private let model = ThemeSettingsModel()

    // Изображение показывает одну из двух картинок в зависимости от текущего режима.
    private let imageView = UIImageView()

    // Подпись поясняет назначение кастомного переключателя.
    private let descriptionLabel = UILabel()

    // Пользовательский переключатель заменяет стандартный UISwitch.
    private let themeToggleControl = ThemeToggleControl()

    // При загрузке контроллер собирает экран кодом и применяет стартовую тему.
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Theme Images"
        setupView()
        setupLayout()
        setupActions()
        applyInitialTheme()
    }

    // Если система меняет тему, а пользователь еще ничего не сохранял, экран подстраивается под устройство.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard !model.hasSavedTheme() else {
            return
        }

        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else {
            return
        }

        let theme = model.initialTheme(for: traitCollection.userInterfaceStyle)
        themeToggleControl.setOn(theme.isSwitchOn, animated: true)
        applyTheme(theme, animated: true)
    }

    // Настраивает свойства элементов интерфейса для одностраничного экрана.
    private func setupView() {
        view.backgroundColor = UIColor(named: "ThemeBackgroundLight")

        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 28

        descriptionLabel.text = "Light / Dark"
        descriptionLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .label

        view.addSubview(imageView)
        view.addSubview(descriptionLabel)
        view.addSubview(themeToggleControl)
    }

    // Расставляет элементы по экрану программно без настройки storyboard через Interface Builder.
    private func setupLayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        themeToggleControl.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -90),
            imageView.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            imageView.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.72),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 36),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            themeToggleControl.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 18),
            themeToggleControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            themeToggleControl.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32)
        ])
    }

    // Подписывает контроллер на событие valueChanged у кастомного переключателя.
    private func setupActions() {
        themeToggleControl.addTarget(self, action: #selector(themeToggleValueChanged), for: .valueChanged)
    }

    // Определяет стартовый режим на основе UserDefaults или текущей темы устройства.
    private func applyInitialTheme() {
        let initialTheme = model.initialTheme(for: traitCollection.userInterfaceStyle)
        themeToggleControl.setOn(initialTheme.isSwitchOn, animated: false)
        applyTheme(initialTheme, animated: false)
    }

    // Реагирует на переключение кастомного switch, сохраняет состояние и запускает анимацию смены темы.
    @objc private func themeToggleValueChanged() {
        let newTheme = AppTheme(isSwitchOn: themeToggleControl.isOn)
        model.saveTheme(newTheme)
        applyTheme(newTheme, animated: true)
    }

    // Применяет тему к картинке, фону и системному стилю контроллера.
    private func applyTheme(_ theme: AppTheme, animated: Bool) {
        let backgroundColor = UIColor(named: theme.backgroundColorName) ?? .systemBackground
        let image = UIImage(named: theme.imageName)
        let changes = {
            self.overrideUserInterfaceStyle = theme.interfaceStyle
            self.view.backgroundColor = backgroundColor
            self.imageView.image = image
        }

        guard animated else {
            changes()
            return
        }

        UIView.transition(with: imageView, duration: 0.3, options: .transitionCrossDissolve) {
            self.imageView.image = image
        }

        UIView.animate(withDuration: 0.3) {
            self.overrideUserInterfaceStyle = theme.interfaceStyle
            self.view.backgroundColor = backgroundColor
        }
    }
}
