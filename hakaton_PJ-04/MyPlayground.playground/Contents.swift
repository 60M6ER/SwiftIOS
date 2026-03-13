// Абстракция данных пользователя из банка
// Данная абстракция нужна банку, а наличка клиента не входит в ответсвенность банка.
protocol UserData {
  var userName: String { get }    //Имя пользователя
  var userCardId: String { get }   //Номер карты
  var userCardPin: Int { get }       //Пин-код
  var userPhone: String { get }       //Номер телефона
  var userBankDeposit: Float { get set }   //Банковский депозит
  var userPhoneBalance: Float { get set }    //Баланс телефона
  var userCardBalance: Float { get set }    //Баланс карты
}

// Действия, которые пользователь может выбирать в банкомате (имитация кнопок)
enum UserActions {
    case showBalance
    case topUpCash
    case withdrawCash
    case topUpPhone
    
}

// Виды операций, выбранных пользователем (подтверждение выбора)
enum DescriptionTypesAvailableOperations: String {
    case balance = "Вы запросили баланс."
    case topUp = "Вы выбарали операцию пополнения счета."
    case withdraw = "Вы выбрали операцию вывода средств со счета."
    case phone = "Вы выбрали операцию пополнения телефона."
}

// Способ оплаты/пополнения наличными, картой или через депозит
enum PaymentMethod {
    case cash
    case card
    case deposit
}

enum Errors: Error {
    case wrongPinCode
    case wrongCardId
    case wrongPhoneNumber
    case notEnoughMoney
    case wrongPaymentMethod
    case notEnoughCashInATM
    case needCardInsert
    case wrongAmount
}

// MARK: Errors
extension Errors {
    var errorDescription: String? {
        switch self {
        case .wrongPinCode:
            return "Неверный пин-код."
        case .wrongCardId:
            return "Неверный номер карты."
        case .wrongPhoneNumber:
            return "Неверный номер телефона."
        case .notEnoughMoney:
            return "Недостаточно средств на выбранном счете."
        case .wrongPaymentMethod:
            return "Выбран неверный источник средств."
        case .notEnoughCashInATM:
            return "В банкомате недостаточно наличных средств для выдачи запрошенной суммы."
        case .needCardInsert:
            return "Необходимо вставить карту для авторизации."
        case .wrongAmount:
            return "Введена неверная сумма."
        }
    }
}

let defaultErrorMessage = "Произошла техническая неполадка. Обратитесь в техПоддержку."

// Протокол по работе с банком предоставляет доступ к данным пользователя зарегистрированного в банке
// Банк будет отдавать все ошибки клиенту (ATM) для обработки и передачи сообщений пользователю
protocol BankApi {
    func getUserName(userCardId: String, userCardPin: Int) throws -> String
    
    func showUserCardBalance(userCardId: String, userCardPin: Int) throws -> Float
    func showUserDepositBalance(userCardId: String, userCardPin: Int) throws -> Float
    func showUserPhoneBalance(phone: String) throws -> Float
 
    mutating func getCash(userCardId: String, userCardPin: Int, value: Float, paymentMethod: PaymentMethod) throws
    mutating func putCash(userCardId: String, userCardPin: Int, value: Float, paymentMethod: PaymentMethod) throws
    mutating func topUpPhoneBalance(userCardId: String, userCardPin: Int, phone: String, value: Float, paymentMethod: PaymentMethod) throws
}

class User: UserData {
    var userName: String
    
    var userCardId: String
    
    var userCardPin: Int
    
    var userPhone: String
    
    var userBankDeposit: Float
    
    var userPhoneBalance: Float
    
    var userCardBalance: Float
    
    init(userName: String, userCardId: String, userCardPin: Int, userPhone: String, userBankDeposit: Float, userPhoneBalance: Float, userCardBalance: Float) {
        self.userName = userName
        self.userCardId = userCardId
        self.userCardPin = userCardPin
        self.userPhone = userPhone
        self.userBankDeposit = userBankDeposit
        self.userPhoneBalance = userPhoneBalance
        self.userCardBalance = userCardBalance
    }

}

class SomeBank: BankApi {
    // Банк хранит данные о своих клиентах
    private var users: [UserData] = []
    
    // При создании заполняется актуалтная база клиентов
    init() {
        self.users.append(
            User(userName: "Иван Иванов", userCardId: "1234567890", userCardPin: 1234, userPhone: "79998887766", userBankDeposit: 350.50, userPhoneBalance: 110.20, userCardBalance: 125.75))
        self.users.append(
            User(userName: "Семён Петрович", userCardId: "0987654321", userCardPin: 4321, userPhone: "81112223344", userBankDeposit: 560.10, userPhoneBalance: 2.50, userCardBalance: 135.00))
        print("Банк начал свой рабочий день.")
    }
    
    // Внутренний метод банка для проверки авторизации по cardID и Pin.
    private func authorize(userCardId: String, userCardPin: Int) throws -> UserData {
        if let user = users.first(where: {$0.userCardId == userCardId}) {
            if user.userCardPin == userCardPin {
                return user
            } else {
                throw Errors.wrongPinCode
            }
        } else {
            throw Errors.wrongCardId
        }
    }
    
    // Выполняет авторизацию и возвращает имя клиента
    func getUserName(userCardId: String, userCardPin: Int) throws -> String {
        do {
            let user = try self.authorize(userCardId: userCardId, userCardPin: userCardPin)
            return user.userName
        } catch let error as Errors {
            throw error
        }
    }
    
    // Выполняет авторизацию по данным пользователя и после отдает баланс
    func showUserCardBalance(userCardId: String, userCardPin: Int) throws -> Float {
        do {
            let user = try self.authorize(userCardId: userCardId, userCardPin: userCardPin)
            return user.userCardBalance
        } catch let error as Errors {
            throw error
        }
    }
    
    // Выполняет авторизацию по данным пользователя и после отдает баланс
    func showUserDepositBalance(userCardId: String, userCardPin: Int) throws -> Float {
        do {
            let user = try self.authorize(userCardId: userCardId, userCardPin: userCardPin)
            return user.userBankDeposit
        } catch let error as Errors {
            throw error
        }
    }
    
    // По хорошему тут тоже должна быть авторизация, но для разности обращений сделал без нее
    func showUserPhoneBalance(phone: String) throws -> Float {
        do {
            if let user = self.users.first(where: {$0.userPhone == phone}) {
               return user.userPhoneBalance
            } else {
                throw Errors.wrongPhoneNumber
            }
        } catch let error as Errors {
            throw error
        }
    }
 
    // Выполняет авторизацию по данным пользователя. Проверяет, что на счете достаточно денег для вывода средств. И после завершается успешно если проверки не упали.
    func getCash(userCardId: String, userCardPin: Int, value: Float, paymentMethod: PaymentMethod) throws {
        do {
            var user = try self.authorize(userCardId: userCardId, userCardPin: userCardPin)
            switch paymentMethod {
            case .card:
                if user.userCardBalance >= value {
                    user.userCardBalance -= value
                } else {
                    throw Errors.notEnoughMoney
                }
            case .deposit:
                if user.userBankDeposit >= value {
                    user.userBankDeposit -= value
                } else {
                    throw Errors.notEnoughMoney
                }
            default:
                throw Errors.wrongPaymentMethod
            }
        } catch let error as Errors {
            throw error
        }
    }
    
    // Выполняет авторизацию по данным пользователя. Проверяет, что на счете достаточно денег для вывода средств. И после завершается успешно если проверки не упали.
    func putCash(userCardId: String, userCardPin: Int, value: Float, paymentMethod: PaymentMethod) throws {
        do {
            var user = try self.authorize(userCardId: userCardId, userCardPin: userCardPin)
            switch paymentMethod {
            case .card:
                user.userCardBalance += value
            case .deposit:
                user.userBankDeposit += value
            default:
                throw Errors.wrongPaymentMethod
            }
        } catch let error as Errors {
            throw error
        }
    }
    
    // Ищет пользователя по номеру телефона. По данным карты проверяет балансы, если пополнение с карты или депозита. И добавляет ему средства.
    // При пополнении через наличные банк ожидает, что ATM уже проверил сумму внесенных средств.
    func topUpPhoneBalance(userCardId: String, userCardPin: Int, phone: String, value: Float, paymentMethod: PaymentMethod) throws {
        do {
            if var recipient = self.users.first(where: {$0.userPhone == phone}) {
                if paymentMethod == PaymentMethod.cash { // Если пополнение наличными то просто зачисляем на счет.
                    recipient.userPhoneBalance += value
                } else {
                    var payer = try self.authorize(userCardId: userCardId, userCardPin: userCardPin)
                    switch paymentMethod{
                    case .card:
                        if payer.userCardBalance >= value {
                            payer.userCardBalance -= value
                            recipient.userPhoneBalance += value
                        } else {
                            throw Errors.notEnoughMoney
                        }
                    case .deposit:
                        if payer.userBankDeposit >= value {
                            payer.userBankDeposit -= value
                            recipient.userPhoneBalance += value
                        } else {
                            throw Errors.notEnoughMoney
                        }
                    default:
                        break
                    }
                }
            } else {
                throw Errors.wrongPhoneNumber
            }
        } catch let error as Errors {
            throw error
        }
    }
}

// Банкомат, с которым мы работаем, имеет общедоступный интерфейс sendUserDataToBank
class ATM {
    private var cash: Float = 100.00 // Наличка, которая уже есть в банкоманте. Важно для работы выдачи и внесения средств.
    private var someBank: BankApi // Банк с которым работает банкомат.
    
    // Поскольку банкоматом может одновременно пользоваться только один клиент, то банкомат хранит данные сессии прямо в себе.
    private var userCardId: String? // Данные авторизации клиента. Заполняются после того, как клиент вставит карту.
    private var userCardPin: Int? // Данные авторизации клиента. Заполняются после того, как клиент вставит карту.
    
    // Инициализация банкомата после вклюения в розетку.
    init(someBank: BankApi) {
        self.someBank = someBank
        print("Банкомат подключился к серверам и у него зашуршали куллеры.")
    }
    
    // Клиент подходит к банкомату и вставляет карту. Вводит пинкод.
    public final func insertCard(cardId: String, pin: Int) {
        print("Клиент вставляет карту.")
        self.userCardId = cardId
        self.userCardPin = pin
        do {
            let userName = try self.someBank.getUserName(userCardId: self.userCardId!, userCardPin: self.userCardPin!)
            print(
                """
                Добро пожаловать, \(userName)!
                Выберите операцию:
                1. Показать баланс (на карте/на депозите)
                2. Снять наличные (с карты/с депозита)
                3. Внести наличные (на карту/на депозит)
                4. Пополнить телефон (со своих счетов/наличными)
                """
            )
        } catch let e as Errors {
            print(e.errorDescription ?? defaultErrorMessage)
        } catch {
            print(defaultErrorMessage)
        }
    }
    
    // Клиент нажимает уйти
    public final func exit() {
        print("Клиент нажал уйти.")
        self.userCardId = nil
        self.userCardPin = nil
        print("До свидания!")
    }
    
    // Обработка нажатий клиента. Упростим реализацию до того, что UI уже уточнил у пользователя сопособ платежа
    // Параметры нужны для внесения дополнительных данных (сумма, номер телефона). Десериализацию будет проводить ATM.
    public final func doAction(actions: UserActions, payment: PaymentMethod? = nil, parametr1: String? = nil, parametr2: String? = nil) {
        print("Клиент нажал действие на экране банкомата.")
        do {
            if self.userCardId == nil || self.userCardPin == nil {
                throw Errors.needCardInsert
            }
            switch actions{
            case .showBalance:
                if let method = payment {
                    var balance: Float = 0.0
                    switch method {
                    case .card:
                        balance = try self.someBank.showUserCardBalance(userCardId: self.userCardId!, userCardPin: self.userCardPin!)
                    case .deposit:
                        balance = try self.someBank.showUserDepositBalance(userCardId: self.userCardId!, userCardPin: self.userCardPin!)
                    default:
                        throw Errors.wrongPaymentMethod
                    }
                    print("Баланс на \(payment == .card ? "карте" : "депозите"): \(balance) рублей")
                } else {
                    throw Errors.wrongPaymentMethod
                }
            case .topUpCash:
                if let method = payment {
                    if let amount = parametr1.flatMap(Float.init) {
                        try self.someBank.putCash(userCardId: self.userCardId!, userCardPin: self.userCardPin!, value: amount, paymentMethod: method)
                        self.cash += amount
                        print("Внесено на \(payment == .card ? "карту" : "депозит"): \(amount) рублей")
                    } else {
                        throw Errors.wrongAmount
                    }
                } else {
                    throw Errors.wrongPaymentMethod
                }
            case .withdrawCash:
                if let method = payment {
                    if let amount = parametr1.flatMap(Float.init) {
                        if self.cash < amount {
                            throw Errors.notEnoughCashInATM
                        }
                        try self.someBank.getCash(userCardId: self.userCardId!, userCardPin: self.userCardPin!, value: amount, paymentMethod: method)
                        self.cash -= amount
                        print("Получите Ваши \(amount) рублей наличными.")
                    } else {
                        throw Errors.wrongAmount
                    }
                } else {
                    throw Errors.wrongPaymentMethod
                }
            case .topUpPhone:
                if let method = payment {
                    if let amount = parametr1.flatMap(Float.init) {
                        if let phone = parametr2 {
                            try self.someBank.topUpPhoneBalance(userCardId: self.userCardId!, userCardPin: self.userCardPin!, phone: phone, value: amount, paymentMethod: method)
                            if method == .cash {
                                self.cash += amount
                            }
                            print("Успешно пополнен баланс телефона: \(phone)\n На: \(amount) рублей.")
                        } else {
                            throw Errors.wrongPhoneNumber
                        }
                    } else {
                        throw Errors.wrongAmount
                    }
                } else {
                    throw Errors.wrongPaymentMethod
                }
            }
        } catch let e as Errors {
            print(e.errorDescription ?? defaultErrorMessage)
        } catch {
            print(defaultErrorMessage)
        }
    }
}

// MARK: Presentation

// Создаем банк
let bank = SomeBank()

// Включаем в розетку ATM
let cATM = ATM(someBank: bank)

// Приходит клиент
cATM.insertCard(cardId: "1234567890", pin: 1234)
cATM.doAction(actions: .showBalance, payment: .card)
cATM.doAction(actions: .showBalance, payment: .deposit)
cATM.doAction(actions: .showBalance, payment: .cash)
cATM.doAction(actions: .withdrawCash, payment: .card, parametr1: "150")
cATM.doAction(actions: .withdrawCash, payment: .card, parametr1: "100")
cATM.exit()

// Приходит другой клиент
cATM.insertCard(cardId: "0987654321", pin: 4321)
cATM.doAction(actions: .topUpPhone, payment: .deposit, parametr1: "52.50", parametr2: "79998887766")
cATM.exit()
