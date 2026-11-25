import Foundation
import SwiftUI
import UIKit
import ComposableArchitecture
import CalendarFeature
import TransactionFeature
import LedgerDomain
import LedgerData

@Reducer
struct RootFeature {
    @ObservableState
    struct State: Equatable {
        var calendar: CalendarFeature.State
        var transaction: TransactionFeature.State
        init(date: Date = .now) {
            calendar = .init(date: date)
            transaction = .init(date: date)
        }
    }
    enum Action {
        case calendar(CalendarFeature.Action)
        case transaction(TransactionFeature.Action)
    }
    let addExpense: AddExpenseUseCase
    var body: some ReducerOf<Self> {
        Scope(state: \.calendar, action: \.calendar) { CalendarFeature() }
        Scope(state: \.transaction, action: \.transaction) {
            TransactionFeature(addExpense: addExpense)
        }
        Reduce { state, action in
            switch action {
            case let .calendar(.dateChanged(date)):
                state.transaction.date = date
                return .none
            case let .transaction(.saved(expense)):
                state.calendar.expenses.append(expense)
                return .none
            case .transaction:
                return .none
            }
        }
    }
}

@MainActor
public struct LedgerRootView: View {
    @State private var store: StoreOf<RootFeature>
    public init() {
        let repository = InMemoryExpenseRepository()
        _store = State(initialValue: Store(initialState: RootFeature.State()) {
            RootFeature(addExpense: AddExpenseUseCase(repository: repository))
        })
    }
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    CalendarView(store: store.scope(state: \.calendar, action: \.calendar))
                    Divider()
                    TransactionView(store: store.scope(state: \.transaction, action: \.transaction))
                }
                .padding()
            }
            .navigationTitle("SocialLedger")
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("완료") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
        }
    }
}
