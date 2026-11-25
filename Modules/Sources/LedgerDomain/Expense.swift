import Foundation

public struct Expense: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let date: Date
    public let title: String
    public let amount: Int

    public init(id: UUID, date: Date, title: String, amount: Int) {
        self.id = id
        self.date = date
        self.title = title
        self.amount = amount
    }
}

public protocol ExpenseRepository: Sendable {
    func save(_ expense: Expense) async
}

public struct AddExpenseUseCase: Sendable {
    private let repository: any ExpenseRepository
    public init(repository: any ExpenseRepository) {
        self.repository = repository
    }
    public func execute(_ expense: Expense) async {
        await repository.save(expense)
    }
}
