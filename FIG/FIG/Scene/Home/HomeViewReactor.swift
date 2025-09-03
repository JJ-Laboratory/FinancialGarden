//
//  HomeViewReactor.swift
//  FIG
//
//  Created by Milou on 9/2/25.
//

import Foundation
import ReactorKit
import RxSwift

final class HomeViewReactor: Reactor {
    
    weak var coordinator: TabBarCoordinator?
    private let transactionRepository: TransactionRepositoryInterface
    private let challengeRepository: ChallengeRepositoryInterface
    
    enum Action {
        case viewDidLoad
        case refresh
        case selectMonth(Date)
        case headerTapped(HomeSection)
        case emptyStateButtonTapped(EmptyStateType)
    }
    
    enum Mutation {
        case setSelectedMonth(Date)
        case setMonthlySummary(expense: Int, income: Int)
        case setCurrentChallenges([Challenge])
        case setError(Error)
    }
    
    struct State {
        var selectedMonth: Date = Date()
        var monthlyExpense: Int = 0
        var monthlyIncome: Int = 0
        var currentChallenges: [Challenge] = []
        @Pulse var error: Error?
        
        var hasRecords: Bool {
            return monthlyExpense > 0
        }
    }
    
    let initialState = State()
    
    init(
        transactionRepository: TransactionRepositoryInterface = TransactionRepository(),
        challengeRepository: ChallengeRepositoryInterface = ChallengeRepository()
    ) {
        self.transactionRepository = transactionRepository
        self.challengeRepository = challengeRepository
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad, .refresh:
            return loadHomeData()
        case .selectMonth(let date):
            return Observable.concat([
                .just(.setSelectedMonth(date)),
                loadMonthlySummary(date)
            ])
        case .headerTapped(let homeSection):
            coordinator?.selectTab(for: homeSection)
            return .empty()
        case .emptyStateButtonTapped(let emptyStateType):
            coordinator?.navigateToFormScreen(type: emptyStateType)
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setSelectedMonth(let date):
            newState.selectedMonth = date
            
        case .setMonthlySummary(let expense, let income):
            newState.monthlyExpense = expense
            newState.monthlyIncome = income
            
        case .setCurrentChallenges(let challenges):
            newState.currentChallenges = challenges
            
        case .setError(let error):
            newState.error = error
        }
        
        return newState
    }
}

extension HomeViewReactor {
    
    func loadHomeData() -> Observable<Mutation> {
        return Observable.merge([
            loadMonthlySummary(currentState.selectedMonth),
            loadCurrentChallenges()
        ])
        .catch { error in
                .just(.setError(error))
        }
    }
    
    private func loadMonthlySummary(_ date: Date) -> Observable<Mutation> {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        return transactionRepository.fetchTransactionByMonth(year, month)
            .map { transactions -> (expense: Int, income: Int) in
                let expense = transactions
                    .filter { $0.category.transactionType == .expense }
                    .reduce(0) { $0 + $1.amount }
                
                let income = transactions
                    .filter { $0.category.transactionType == .income }
                    .reduce(0) { $0 + $1.amount }
                
                return (expense: expense, income: income)
            }
            .map { .setMonthlySummary(expense: $0.expense, income: $0.income) }
            .catch { error in
                print("❌ Failed to load monthly summary: \(error)")
                return .just(.setMonthlySummary(expense: 0, income: 0))
            }
    }
    
    private func loadCurrentChallenges() -> Observable<Mutation> {
        return .just(.setCurrentChallenges([]))
    }
}
