//
//  ToDoListModel.swift
//  ToDoListMVC
//
//  Created by Борис Ларионов on 17.05.2026.
//

import Foundation

// Модель списка задач хранит массив и все действия над данными.
final class ToDoListModel {
    // Стартовый массив нужен, чтобы приложение сразу показывало готовый список.
    private(set) var items: [TaskItem] = [
        TaskItem(title: "Добавить модель для данных", isCompleted: false),
        TaskItem(title: "Добавить TableView в контроллер", isCompleted: false),
        TaskItem(title: "Связать ячеку и таблицу", isCompleted: false),
        TaskItem(title: "Задать повдение для ячеки при действиях в чекбоксе", isCompleted: false),
        TaskItem(title: "Протестировать написанное", isCompleted: false)
    ]

    // Возвращает количество строк для `UITableViewDataSource`.
    func numberOfItems() -> Int {
        items.count
    }

    /// Отдает конкретную задачу по индексу для настройки ячейки.
    func item(at index: Int) -> TaskItem {
        items[index]
    }

    // Обновляет текст задачи после редактирования в текстовом поле.
    func updateTitle(_ title: String, at index: Int) {
        items[index].title = title
    }

    // Удаляет задачу из массива в режиме редактирования таблицы.
    func removeItem(at index: Int) {
        items.remove(at: index)
    }

    // Перемещает задачу при ручном изменении порядка среди строк таблицы.
    func moveItem(from sourceIndex: Int, to destinationIndex: Int) {
        let movedItem = items.remove(at: sourceIndex)
        items.insert(movedItem, at: destinationIndex)
    }

    // Меняет статус задачи и возвращает новый индекс, куда строку нужно переставить.
    func toggleCompletion(at index: Int) -> Int {
        items[index].isCompleted.toggle()
        return repositionItemAfterStatusChange(at: index)
    }

    // Переставляет строку так, чтобы выполненные задачи всегда находились внизу списка.
    func repositionItemAfterStatusChange(at index: Int) -> Int {
        let changedItem = items.remove(at: index)
        let targetIndex: Int

        if changedItem.isCompleted {
            targetIndex = firstCompletedIndex() ?? items.count
        } else {
            targetIndex = activeItemsCount()
        }

        items.insert(changedItem, at: targetIndex)
        return targetIndex
    }

    // Считает количество невыполненных задач, чтобы вставлять новые активные строки выше completed-блока.
    private func activeItemsCount() -> Int {
        items.filter { !$0.isCompleted }.count
    }

    // Ищет первую выполненную задачу, чтобы новая completed-строка вставлялась в начало completed-секции.
    private func firstCompletedIndex() -> Int? {
        items.firstIndex(where: { $0.isCompleted })
    }
}
