// MARK: 1_enum
enum Errors: Error {
    case Error_400
    case Error_404
    case Error_500
}

var currentError: Errors? = Errors.Error_404

// Обработка исключения хранящегося в переменной currentError
do {
    if let error = currentError {
        throw error
    }
} catch Errors.Error_400 {
    print("Error_400 has been thrown");
} catch Errors.Error_404 {
    print("Error_404 has been thrown");
} catch Errors.Error_500 {
    print("Error_500 has been thrown");
}

// MARK: 2_func_throws

func checkError(errorBuffer: Errors?) throws {
    if let error = errorBuffer {
        throw error
    }
    print("It's OK.")
}

// Обработка исключения через генерирующую функцию
do {
    try checkError(errorBuffer: currentError)
} catch Errors.Error_400 {
    print("Error_400 has been thrown");
} catch Errors.Error_404 {
    print("Error_404 has been thrown");
} catch Errors.Error_500 {
    print("Error_500 has been thrown");
}

// MARK: 3_generics_YesNo

func yesNo<T, E> (a: T, b: E) -> Void {
    if (type(of: a) == type(of: b)) {
        print("Yes")
    } else {
        print("No")
    }
}

yesNo(a: 1, b: "Yes")

// MARK: 4_generics_throws

enum TypeCheckError: Error {
    case TypesAreNotEqual
    case TypesAreEqual
}

func yesNoWithThrow<T, E> (a: T, b: E) throws -> Void {
    if (type(of: a) == type(of: b)) {
        throw TypeCheckError.TypesAreEqual
    } else {
        throw TypeCheckError.TypesAreNotEqual
    }
}

do {
    try yesNoWithThrow(a: 2, b: 5)
} catch TypeCheckError.TypesAreEqual {
    print("Types of values has been equal")
} catch TypeCheckError.TypesAreNotEqual {
    print("Types of values hasn't been equal")
}

// MARK: 5_generics_Equatable

func valuesIsEqual<T: Equatable> (a: T, b: T) -> Bool {
    return a == b
}

valuesIsEqual(a: 1, b: 1)
