//
//  RecordListReactor.swift
//  FIG
//
//  Created by Milou on 9/1/25.
//

import Foundation
import ReactorKit
import RxSwift
import OSLog

final class RecordListReactor: Reactor {
    enum Action {
        case viewDidLoad
        case selectMonth(Date)
        case refresh
//        case recordSelected(Transaction)
    }
    
    enum Mutation {
        case setSelectMonth(Date)
        case setRecordGroups([RecordGroup])
        case setMonthlySummary(MonthlySummary)
        case setError(Error?)
    }
    
    struct State {
        var selectedMonth = Date()
        var recordGroups: [RecordGroup] = []
        var monthlySummary = MonthlySummary(expense: 0, income: 0, hasRecords: false)
        var error: Error?
        
//        var monthlyExpense: Int { monthlySummary.expense }
//        var monthlyIncome: Int { monthlySummary.income }
    }
    
    struct RecordGroup {
        let date: Date
        let transactions: [Transaction]
        
        var dailyIncome: Int {
            return transactions
                .filter { $0.category.transactionType == .income }
                .reduce(0) { $0 + $1.amount }
        }
        
        var dailyExpense: Int {
            return transactions
                .filter { $0.category.transactionType == .expense }
                .reduce(0) { $0 + $1.amount }
        }
    }
    
    let initialState: State
    private let transactionRepository: TransactionRepositoryInterface
    private let recordUseCase: RecordUseCase
    
    init(
        transactionRepository: TransactionRepositoryInterface,
        recordUseCase: RecordUseCase
    ) {
        self.transactionRepository = transactionRepository
        self.recordUseCase = recordUseCase
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return loadCurrentMonthData()
        case .selectMonth(let date):
            return Observable.concat([
                Observable.just(.setSelectMonth(date)),
                loadMonthData(date)
            ])
        case .refresh:
            return loadMonthData(currentState.selectedMonth)
//        case .recordSelected(_):
//            return Observable.empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setSelectMonth(let month):
            newState.selectedMonth = month
        case .setRecordGroups(let groups):
            newState.recordGroups = groups
        case .setMonthlySummary(let summary):
            newState.monthlySummary = summary
        case .setError(let error):
            newState.error = error
        }
        
        return newState
    }
    
    // MARK: - Private Methods (단순화)
    
    private func loadCurrentMonthData() -> Observable<Mutation> {
        let currentMonth = Date()
        return Observable.concat([
            Observable.just(.setSelectMonth(currentMonth)),
            loadMonthData(currentMonth)
        ])
    }
    
    private func loadMonthData(_ date: Date) -> Observable<Mutation> {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        return Observable.concat([
            Observable.just(.setError(nil)),
            
            Observable.zip(
                transactionRepository.fetchTransactionByMonth(year, month),
                recordUseCase.getMonthlySummary(year: year, month: month)
            )
            .map { transactions, summary -> [Mutation] in
                let groups = self.groupTransactionByDate(transactions)
                return [
                    .setRecordGroups(groups),
                    .setMonthlySummary(summary)
                ]
            }
            .flatMap { Observable.from($0) }
            .catch { error in
                Observable.from([
                    .setError(error),
                    .setRecordGroups([]),
                    .setMonthlySummary(MonthlySummary(expense: 0, income: 0, hasRecords: false))
                ])
            }
        ])
    }
    
    private func groupTransactionByDate(_ transactions: [Transaction]) -> [RecordGroup] {
        let calendar = Calendar.current
        
        let groupedByDate = Dictionary(grouping: transactions) { transaction in
            calendar.startOfDay(for: transaction.date)
        }
        
        let sortedGroups = groupedByDate
            .sorted { $0.key > $1.key }
            .map { date, transactions in
                let sortedTransactions = transactions.sorted { $0.date > $1.date }
                return RecordGroup(date: date, transactions: sortedTransactions)
            }
        
        return sortedGroups
    }
}

extension RecordListReactor.RecordGroup: Equatable {
    static func == (lhs: RecordListReactor.RecordGroup, rhs: RecordListReactor.RecordGroup) -> Bool {
        return lhs.date == rhs.date && lhs.transactions.count == rhs.transactions.count
    }
}
