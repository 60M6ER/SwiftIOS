//
//  ThemeSettingsModel.swift
//  ImagesWithsUserDefoults
//
//  Created by Борис Ларионов on 17.05.2026.
//

import UIKit

// Модель отвечает за хранение состояния темы и чтение значения из UserDefaults.
final class ThemeSettingsModel {
    // Ключ используется для сохранения положения переключателя между запусками приложения.
    private let themeStateKey = "savedThemeSwitchState"

    // UserDefaults инжектируется в модель, чтобы логику хранения можно было изолировать от контроллера.
    private let userDefaults: UserDefaults

    // Инициализатор позволяет использовать стандартное хранилище без лишнего кода в контроллере.
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // Возвращает тему для первого экрана: либо сохраненную, либо соответствующую теме устройства.
    func initialTheme(for deviceStyle: UIUserInterfaceStyle) -> AppTheme {
        if let savedTheme = savedTheme() {
            return savedTheme
        }

        return deviceStyle == .dark ? .dark : .light
    }

    // Показывает, менял ли пользователь тему вручную и есть ли уже сохраненное состояние.
    func hasSavedTheme() -> Bool {
        userDefaults.object(forKey: themeStateKey) != nil
    }

    // Сохраняет новое положение пользовательского переключателя.
    func saveTheme(_ theme: AppTheme) {
        userDefaults.set(theme.isSwitchOn, forKey: themeStateKey)
    }

    // Возвращает сохраненную тему, если пользователь уже менял положение переключателя.
    private func savedTheme() -> AppTheme? {
        guard userDefaults.object(forKey: themeStateKey) != nil else {
            return nil
        }

        return AppTheme(isSwitchOn: userDefaults.bool(forKey: themeStateKey))
    }
}
