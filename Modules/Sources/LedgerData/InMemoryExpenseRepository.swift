import LedgerDomain

public actor InMemoryExpenseRepository: ExpenseRepository {
    private var expenses: [Expense] = []
    public init() {}
    public func save(_ expense: Expense) async {
        expenses.append(expense)
    }
}
