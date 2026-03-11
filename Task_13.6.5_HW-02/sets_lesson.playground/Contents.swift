// 1. Пункт
let firstPerson = (name: "Peter", surname: "Smith", gender: "male")
let secondPerson = (name: "Jane", surname: "Doe", gender: "female")

// Обращение по индексу
firstPerson.0
firstPerson.1
firstPerson.2

// Обращение по параметру
secondPerson.name
secondPerson.surname
secondPerson.gender

// 2. Пункт
let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
let daysCountOfMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

// Вывод количества дней в каждом месяце
for count in daysCountOfMonth {
    print(count)
}

// Вывод количества дней в каждом месяце с именами месяцев
for index in months.indices {
    print("\(months[index]) has \(daysCountOfMonth[index]) days")
}

let monthsCortege = [(name: "January", countOfDays: 31),
                    (name: "February", countOfDays: 28),
                    (name: "March", countOfDays: 31),
                    (name: "April", countOfDays: 30),
                    (name: "May", countOfDays: 31),
                    (name: "June", countOfDays: 30),
                    (name: "July", countOfDays: 31),
                    (name: "August", countOfDays: 31),
                    (name: "September", countOfDays: 30),
                    (name: "October", countOfDays: 31),
                    (name: "November", countOfDays: 30),
                    (name: "December", countOfDays: 31)]
// Тоже самое с использованием кортежа
for month in monthsCortege {
    print("\(month.name) has \(month.countOfDays) days")
}

// Тоже самое в обратном порядке. Исходный массив не изменен
for day in daysCountOfMonth.reversed() {
    print(day)
}

let date = (day: 15, month: 10) // Произвольная дата

var curSequence = daysCountOfMonth.dropFirst(date.month)
var lastDays = daysCountOfMonth[date.month - 1] - date.day
lastDays = daysCountOfMonth.dropFirst(date.month).reduce(lastDays, +)
// Итог включая текущий день
print("\(lastDays) days left to the end of the year.")

// 3. Пункт

var students: [String: Int] = [:]

students.updateValue(5, forKey: "Peter Smith")
students.updateValue(2, forKey: "Michael Carter")
students.updateValue(3, forKey: "Emily Johnson")
students.updateValue(4, forKey: "Daniel Brooks")
students.updateValue(5, forKey: "Olivia Bennett")

students.updateValue(4, forKey: "Emily Johnson") // Повышение оценки

// Вывод результатов тестирования
for (key, value) in students {
    switch value {
    case 5, 4, 3:
        print("\(key) has a good mark: \(value). Congratulations!")
    case 1, 2:
        print("\(key) needs to improve: \(value)")
    default:
        print("\(key) has an average mark: \(value)")
    }
}

// Новые одногруппники
students.updateValue(4, forKey: "Liam Anderson")
students.updateValue(2, forKey: "Sophia Turner")
students.updateValue(3, forKey: "Ethan Mitchell")
students.updateValue(5, forKey: "Grace Collins")

// Отчисление студента
students.removeValue(forKey: "Michael Carter")

// Средний балл
let averageMark = Double(students.reduce(0) { $0 + $1.value }) / Double(students.count)
print("The avarage mark is: \(averageMark)")
