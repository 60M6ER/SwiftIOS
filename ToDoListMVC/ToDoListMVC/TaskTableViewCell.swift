//
//  TaskTableViewCell.swift
//  ToDoListMVC
//
//  Created by Борис Ларионов on 17.05.2026.
//

import UIKit

// Делегат позволяет ячейке сообщать контроллеру об изменениях
protocol TaskTableViewCellDelegate: AnyObject {
    // Передает событие нажатия по чекбоксу.
    func taskCellDidTapCheckbox(_ cell: TaskTableViewCell)

    // Передает новый текст после завершения редактирования.
    func taskCell(_ cell: TaskTableViewCell, didFinishEditingText text: String)

    // Сообщает контроллеру, что пользователь нажал Return и хочет закрыть клавиатуру.
    func taskCellDidRequestKeyboardDismiss(_ cell: TaskTableViewCell)
}

// Кастомная ячейка отвечает только за отображение и пользовательские события.
final class TaskTableViewCell: UITableViewCell {
    // Идентификатор нужен для регистрации и повторного использования ячейки.
    static let reuseIdentifier = "TaskTableViewCell"

    // Делегат принимает события от кнопки и текстового поля.
    weak var delegate: TaskTableViewCellDelegate?

    // Кнопка играет роль чекбокса и меняет статус выполнения задачи.
    private let checkboxButton = UIButton(type: .system)

    // Поле ввода позволяет менять текст
    private let titleTextField = UITextField()

    // Стек упрощает горизонтальную раскладку элементов внутри ячейки.
    private let contentStackView = UIStackView()

    // Здесь хранится последний примененный текст, чтобы не отправлять в модель лишние обновления.
    private var currentTitle = ""

    // Подготовка ячейки на уровне кода.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Сбрасывает временное состояние перед повторным использованием ячейки.
    override func prepareForReuse() {
        super.prepareForReuse()
        currentTitle = ""
        titleTextField.text = nil
        titleTextField.attributedText = nil
        titleTextField.isUserInteractionEnabled = true
    }

    // Применяет модель к UI и настраивает внешний вид строки.
    func configure(with item: TaskItem) {
        currentTitle = item.title
        titleTextField.text = item.title
        applyAppearance(isCompleted: item.isCompleted)
    }

    // Создает подвиды и навешивает события.
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        checkboxButton.tintColor = .systemTeal
        checkboxButton.addTarget(self, action: #selector(checkboxButtonTapped), for: .touchUpInside)

        titleTextField.borderStyle = .none
        titleTextField.clearButtonMode = .whileEditing
        titleTextField.returnKeyType = .done
        titleTextField.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        titleTextField.textColor = .label
        titleTextField.delegate = self

        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        contentStackView.spacing = 12

        contentView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(checkboxButton)
        contentStackView.addArrangedSubview(titleTextField)
    }

    // Расставляет констрейнты для компактной одностраничной таблицы.
    private func setupLayout() {
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            checkboxButton.widthAnchor.constraint(equalToConstant: 28),
            checkboxButton.heightAnchor.constraint(equalToConstant: 28),
            titleTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 24)
        ])
    }

    // Переключает визуальное состояние между активной и выполненной задачей.
    private func applyAppearance(isCompleted: Bool) {
        let symbolName = isCompleted ? "checkmark.circle.fill" : "circle"
        checkboxButton.setImage(UIImage(systemName: symbolName), for: .normal)

        if isCompleted {
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.secondaryLabel,
                .strikethroughStyle: NSUnderlineStyle.single.rawValue
            ]
            titleTextField.attributedText = NSAttributedString(string: currentTitle, attributes: attributes)
            titleTextField.isUserInteractionEnabled = false
        } else {
            titleTextField.attributedText = nil
            titleTextField.text = currentTitle
            titleTextField.textColor = .label
            titleTextField.isUserInteractionEnabled = true
        }
    }

    // Отправляет контроллеру событие изменения статуса.
    @objc private func checkboxButtonTapped() {
        delegate?.taskCellDidTapCheckbox(self)
    }
}

extension TaskTableViewCell: UITextFieldDelegate {
    // Закрывает клавиатуру по Return и передает финальный текст в контроллер.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.taskCellDidRequestKeyboardDismiss(self)
        textField.resignFirstResponder()
        return true
    }

    // Сохраняет текст в модель, когда пользователь закончил редактирование.
    func textFieldDidEndEditing(_ textField: UITextField) {
        let trimmedText = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let finalText = trimmedText.isEmpty ? currentTitle : trimmedText

        textField.text = finalText
        currentTitle = finalText
        delegate?.taskCell(self, didFinishEditingText: finalText)
    }
}
