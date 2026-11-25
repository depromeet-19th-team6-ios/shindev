import Foundation
import SwiftUI
import ComposableArchitecture
import LedgerDomain

@Reducer
public struct TransactionFeature {
    @ObservableState
    public struct State: Equatable {
        public var date: Date
        var title = ""
        var amount = ""
        var isSaving = false
        public init(date: Date) { self.date = date }
        var canSave: Bool {
            !isSaving && !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && (Int(amount).map { (1...100_000_000).contains($0) } ?? false)
        }
    }
    public enum Action {
        case titleChanged(String)
        case amountChanged(String)
        case saveTapped
        case saved(Expense)
    }
    private let addExpense: AddExpenseUseCase
    public init(addExpense: AddExpenseUseCase) { self.addExpense = addExpense }
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .titleChanged(title):
                state.title = title
                return .none
            case let .amountChanged(amount):
                state.amount = amount
                return .none
            case .saveTapped:
                guard state.canSave, let amount = Int(state.amount) else { return .none }
                state.isSaving = true
                let expense = Expense(id: UUID(), date: state.date,
                    title: state.title.trimmingCharacters(in: .whitespacesAndNewlines), amount: amount)
                let useCase = addExpense
                return .run { send in
                    await useCase.execute(expense)
                    await send(.saved(expense))
                }
            case .saved:
                state.title = ""
                state.amount = ""
                state.isSaving = false
                return .none
            }
        }
    }
}

public struct TransactionView: View {
    let store: StoreOf<TransactionFeature>
    public init(store: StoreOf<TransactionFeature>) { self.store = store }
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("지출 입력").font(.headline)
            Text(store.date.formatted(date: .abbreviated, time: .omitted))
                .foregroundStyle(.secondary)
            TextField("내용 (예: 점심)", text: Binding(
                get: { store.title }, set: { store.send(.titleChanged($0)) }))
                .textFieldStyle(.roundedBorder)
                .disabled(store.isSaving)
            TextField("금액 (원)", text: Binding(
                get: { store.amount }, set: { store.send(.amountChanged($0)) }))
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .disabled(store.isSaving)
            Button {
                store.send(.saveTapped)
            } label: {
                Text("저장하기").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!store.canSave)
        }
    }
}
