//
//  ViewController.swift
//  ToDoListMVC
//
//  Created by Борис Ларионов on 17.05.2026.
//

import UIKit

// Контроллер связывает модель списка задач с таблицей и пользовательскими действиями.
final class ViewController: UIViewController {
    // Модель хранит данные и бизнес-логику, а контроллер только вызывает ее методы.
    private let model = ToDoListModel()

    // Таблица показывает все задачи в одном экране приложения.
    private let tableView = UITableView(frame: .zero, style: .plain)

    // Жест нужен, чтобы закрывать клавиатуру тапом мимо текстового поля.
    private lazy var dismissKeyboardTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))

    // Загрузка контроллера используется для первичной настройки UI и MVC-связей.
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Мои задачи"
        navigationItem.rightBarButtonItem = editButtonItem
        setupTableView()
        setupKeyboardDismissGesture()
    }

    // Настраивает таблицу программно.
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 56, bottom: 0, right: 16)
        tableView.keyboardDismissMode = .interactive
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // Навешивает обработчик, который завершает редактирование за пределами текстового поля.
    private func setupKeyboardDismissGesture() {
        dismissKeyboardTapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissKeyboardTapGesture)
    }

    // Закрывает клавиатуру по тапу на свободной области экрана.
    @objc private func handleBackgroundTap() {
        view.endEditing(true)
    }

    // Синхронизирует визуальный режим таблицы с кнопкой `Edit` в navigation bar.
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    // Обновляет строку после изменения текста внутри ячейки.
    private func updateItemTitle(_ text: String, from cell: TaskTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        model.updateTitle(text, at: indexPath.row)
    }

    // Переключает статус задачи и переставляет строку по правилу completed-внизу.
    private func toggleCompletion(from cell: TaskTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        let targetRow = model.toggleCompletion(at: indexPath.row)
        let targetIndexPath = IndexPath(row: targetRow, section: indexPath.section)

        tableView.performBatchUpdates({
            tableView.moveRow(at: indexPath, to: targetIndexPath)
        }, completion: { [weak self] _ in
            self?.tableView.reloadData()
        })
    }
}

extension ViewController: UITableViewDataSource {

    // Отдает количество задач из модели.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.numberOfItems()
    }

    // Создает и настраивает кастомную ячейку для конкретной задачи.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.reuseIdentifier, for: indexPath) as? TaskTableViewCell else {
            return UITableViewCell()
        }

        cell.delegate = self
        cell.configure(with: model.item(at: indexPath.row))
        return cell
    }

    // Разрешает удаление строк в системном edit mode таблицы.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    // Разрешает ручное перемещение строк в системном edit mode таблицы.
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }

    // Удаляет задачу из массива и таблицы.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }

        model.removeItem(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    // Сохраняет новый порядок строк после ручного перемещения пользователем.
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        model.moveItem(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
}

extension ViewController: UITableViewDelegate {
    // Убирает выделение, если система все же подсветила строку после касания.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController: TaskTableViewCellDelegate {
    // Реагирует на нажатие чекбокса из конкретной ячейки.
    func taskCellDidTapCheckbox(_ cell: TaskTableViewCell) {
        toggleCompletion(from: cell)
    }

    // Сохраняет новый текст задачи после завершения редактирования поля.
    func taskCell(_ cell: TaskTableViewCell, didFinishEditingText text: String) {
        updateItemTitle(text, from: cell)
    }

    // Закрывает клавиатуру по нажатию Return внутри ячейки.
    func taskCellDidRequestKeyboardDismiss(_ cell: TaskTableViewCell) {
        view.endEditing(true)
    }
}
