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
            // TODO: 각 추가화면으로 이동
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
        return .just(.setMonthlySummary(expense: 1234, income: 5678))
    }
    
    private func loadCurrentChallenges() -> Observable<Mutation> {
        return .just(.setCurrentChallenges([]))
    }
}
