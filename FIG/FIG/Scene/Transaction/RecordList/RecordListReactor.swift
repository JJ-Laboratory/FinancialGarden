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
        case recordSelected(Transaction)
    }
    
    enum Mutation {
        case setSelectMonth(Date)
        case setRecordGroups([RecordGroup])
        case setMonthlySummary(expense: Int, income: Int)
        case setError(Error?)
    }
    
    struct State {
        var selectedMonth: Date = Date()
        var recordGroups: [RecordGroup] = []
        var monthlyExpense: Int = 0
        var monthlyIncome: Int = 0
        var error: Error?
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
    private let logger = Logger.transaction
    
    init(transactionRepository: TransactionRepositoryInterface) {
        self.transactionRepository = transactionRepository
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
        case .recordSelected(let transaction):
            logger.info("거래 선택: \(transaction.title)")
            return Observable.empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setSelectMonth(let month):
            newState.selectedMonth = month
        case .setRecordGroups(let groups):
            newState.recordGroups = groups
        case .setMonthlySummary(let expense, let income):
            newState.monthlyExpense = expense
            newState.monthlyIncome = income
        case .setError(let error):
            newState.error = error
        }
        
        return newState
    }
}

extension RecordListReactor {
    func loadCurrentMonthData() -> Observable<Mutation> {
        let currentMonth = Date()
        return Observable.concat([
            Observable.just(.setSelectMonth(currentMonth)),
            loadMonthData(currentMonth)
        ])
    }
    
    func loadMonthData(_ date: Date) -> Observable<Mutation> {
        let calendar =  Calendar.current
        let year  = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        return Observable.concat([
            Observable.just(.setError(nil)),
            
            transactionRepository.fetchTransactionByMonth(year, month)
                .map { transactions -> [Mutation] in
                    let groups = self.groupTransactionByDate(transactions)
                    let (expense, income) = self.calculateMonthlySummary(transactions)
                    
                    return [
                        .setRecordGroups(groups),
                        .setMonthlySummary(expense: expense, income: income)
                    ]
                }
                .flatMap { Observable.from($0) }
                .catch { error in
                    Observable.from([
                        .setError(error),
                        .setRecordGroups([]),
                        .setMonthlySummary(expense: 0, income: 0)
                    ])
                }
        ])
    }
    
    func groupTransactionByDate(_ transactions: [Transaction]) -> [RecordGroup] {
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
    
    func calculateMonthlySummary(_ transactions: [Transaction]) -> (expense: Int, income: Int) {
        let expense = transactions
            .filter { $0.category.transactionType == .expense }
            .reduce(0) { $0 + $1.amount }
        
        let income = transactions
            .filter { $0.category.transactionType == .income }
            .reduce(0) { $0 + $1.amount }
        
        return (expense, income)
    }
}

extension RecordListReactor.RecordGroup: Equatable {
    static func == (lhs: RecordListReactor.RecordGroup, rhs: RecordListReactor.RecordGroup) -> Bool {
        return lhs.date == rhs.date && lhs.transactions.count == rhs.transactions.count
    }
}
