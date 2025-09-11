//
//  HomeReactor.swift
//  FIG
//
//  Created by Milou on 9/2/25.
//

import Foundation
import ReactorKit
import RxSwift

final class HomeReactor: Reactor {
    
    weak var coordinator: TabBarCoordinatorProtocol?

    private let recordUseCase: RecordUseCase
    private let challengeUseCase: ChallengeUseCase
    
    enum Action {
        case viewDidLoad
        case refresh
        case selectMonth(Date)
        case headerTapped(HomeSection)
        case emptyStateButtonTapped(EmptyStateType)
    }
    
    enum Mutation {
        case setSelectedMonth(Date)
        case setMonthlySummary(MonthlySummary)
        case setCurrentChallenges([Challenge])
        case setChartData([CategoryChartItem])
        case setError(Error)
    }
    
    struct State {
        var selectedMonth: Date = Date()
        var monthlySummary: MonthlySummary = MonthlySummary(expense: 0, income: 0, hasRecords: false)
        var currentChallenges: [Challenge] = []
        var chartItems: [CategoryChartItem] = []
        @Pulse var error: Error?
        
        var monthlyExpense: Int { monthlySummary.expense }
        var monthlyIncome: Int { monthlySummary.income }
        var hasRecords: Bool { monthlySummary.hasRecords }
        
        var categoryTotalAmount: Int {
            return chartItems.reduce(0) { $0 + $1.amount }
        }
        
        var categoryProgressItems: [ChartProgressView.Item] {
            categoryTotalAmount > 0
            ? chartItems.map { ChartProgressView.Item(value: Int($0.percentage.rounded()), color: $0.iconColor) }
            : [ChartProgressView.Item(value: 100, color: ChartColor.none.uiColor)]
        }
    }
    
    let initialState = State()
    
    init(
        recordUseCase: RecordUseCase,
        challengeUseCase: ChallengeUseCase
    ) {
        self.recordUseCase = recordUseCase
        self.challengeUseCase = challengeUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad, .refresh:
            return loadHomeData()
        case .selectMonth(let date):
            return Observable.concat([
                .just(.setSelectedMonth(date)),
                loadHomeDataForMonth(date)
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
        case .setMonthlySummary(let summary):
            newState.monthlySummary = summary
        case .setCurrentChallenges(let challenges):
            newState.currentChallenges = challenges
        case .setChartData(let items):
            let total = items.reduce(0) { $0 + $1.amount }
            if total > 0 {
                newState.chartItems = ChartDataProcessor.makeCategoryItems(from: items, total: total)
            } else {
                newState.chartItems = []
            }
        case .setError(let error):
            newState.error = error
        }
        
        return newState
    }
}

extension HomeReactor {
    
    func loadHomeData() -> Observable<Mutation> {
        return loadHomeDataForMonth(currentState.selectedMonth)
    }
    
    private func loadHomeDataForMonth(_ date: Date) -> Observable<Mutation> {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        return Observable.merge([
            recordUseCase.getMonthlySummary(year: year, month: month)
                .map { .setMonthlySummary($0) },
            
            challengeUseCase.getCurrentChallenges(year: year, month: month)
                .map { .setCurrentChallenges($0) },
            
            recordUseCase.getCategoryChart(year: year, month: month)
                .map { .setChartData($0) }
        ])
        .catch { error in
            .just(.setError(error))
        }
    }
}
