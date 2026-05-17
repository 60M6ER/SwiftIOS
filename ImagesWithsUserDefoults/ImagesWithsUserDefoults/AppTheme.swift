//
//  AppTheme.swift
//  ImagesWithsUserDefoults
//
//  Created by Борис Ларионов on 17.05.2026.
//

import UIKit

// Перечисление описывает два режима, между которыми переключается экран.
enum AppTheme {
    // Светлый режим показывает первую картинку и светлый фон.
    case light

    // Темный режим показывает вторую картинку и темный фон.
    case dark

    // Имя картинки для текущего режима хранится здесь, чтобы контроллер не держал строки у себя.
    var imageName: String {
        switch self {
        case .light:
            return "light"
        case .dark:
            return "dark"
        }
    }

    // Имя цветового ассета для фона соответствует выбранной теме.
    var backgroundColorName: String {
        switch self {
        case .light:
            return "ThemeBackgroundLight"
        case .dark:
            return "ThemeBackgroundDark"
        }
    }

    // Системный стиль нужен, чтобы интерфейс контроллера тоже выглядел согласованно.
    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    // Положение переключателя связывается с режимом, чтобы модель была простой.
    var isSwitchOn: Bool {
        switch self {
        case .light:
            return false
        case .dark:
            return true
        }
    }

    // Инициализатор переводит логическое положение переключателя в конкретную тему.
    init(isSwitchOn: Bool) {
        self = isSwitchOn ? .dark : .light
    }
}
