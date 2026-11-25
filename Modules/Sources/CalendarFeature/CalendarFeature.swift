import Foundation
import SwiftUI
import ComposableArchitecture
import LedgerDomain

@Reducer
public struct CalendarFeature {
    @ObservableState
    public struct State: Equatable {
        public var date: Date
        public var expenses: [Expense] = []
        public init(date: Date) { self.date = date }
        public var dailyExpenses: [Expense] {
            expenses.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
        }
    }
    public enum Action {
        case dateChanged(Date)
    }
    public init() {}
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .dateChanged(date):
                state.date = date
                return .none
            }
        }
    }
}

public struct CalendarView: View {
    let store: StoreOf<CalendarFeature>
    public init(store: StoreOf<CalendarFeature>) { self.store = store }
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            DatePicker("날짜", selection: Binding(
                get: { store.date },
                set: { store.send(.dateChanged($0)) }
            ), displayedComponents: .date)
            .datePickerStyle(.graphical)
            Text("일별 지출 합계: \(store.dailyExpenses.reduce(0) { $0 + $1.amount }.formatted())원")
                .font(.headline)
            if store.dailyExpenses.isEmpty {
                Text("지출 내역이 없습니다.").foregroundStyle(.secondary)
            }
            ForEach(store.dailyExpenses) { expense in
                HStack {
                    Text(expense.title)
                    Spacer()
                    Text("\(expense.amount.formatted())원")
                }
            }
        }
    }
}
