//
//  TaskItem.swift
//  ToDoListMVC
//
//  Created by Борис Ларионов on 17.05.2026.
//

import Foundation

// Модель одной задачи, которую контроллер показывает в таблице.
struct TaskItem {
    // Текст задачи, который пользователь редактирует прямо в ячейке.
    var title: String

    // Признак выполнения, влияющий на внешний вид и положение строки.
    var isCompleted: Bool
}
