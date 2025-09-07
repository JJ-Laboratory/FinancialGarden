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
    
    weak var coordinator: HomeCoordinatorProtocol?
    private let transactionRepository: TransactionRepositoryInterface
    private let challengeRepository: ChallengeRepositoryInterface
    private let categoryService: CategoryService
    
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
        case setChartData([CategoryChartItem])
        case setError(Error)
    }
    
    struct State {
        var selectedMonth: Date = Date()
        var monthlyExpense: Int = 0
        var monthlyIncome: Int = 0
        var currentChallenges: [Challenge] = []
        var chartItems: [CategoryChartItem] = []
        @Pulse var error: Error?
        
        var hasRecords: Bool {
            return monthlyExpense > 0
        }
        
        var categoryTotalAmount: Int {
            return chartItems.reduce(0) { $0 + $1.amount }
        }
        
        var categoryProgressItems: [ChartProgressView.Item] {
            guard categoryTotalAmount > 0 else {
                return [ChartProgressView.Item(value: 100, color: ChartColor.none.uiColor)]
            }
            
            let processedItems = makeCategoryItemsForProgress(from: chartItems, total: categoryTotalAmount)
            
            return processedItems.map { item in
                ChartProgressView.Item(
                    value: Int(item.percentage.rounded()),
                    color: item.iconColor
                )
            }
        }
        
        private func makeCategoryItemsForProgress(from chartItems: [CategoryChartItem], total: Int) -> [CategoryChartItem] {
            let baseItems = chartItems.prefix(4).enumerated().map { (index, data) in
                data.withColor(ChartColor.rank(index))
            }
            guard chartItems.count > 4 else { return baseItems }
            
            let others = chartItems.dropFirst(4)
            return baseItems + [makeOthersCategory(from: others, total: total)]
        }
        
        private func makeOthersCategory(from items: ArraySlice<CategoryChartItem>, total: Int) -> CategoryChartItem {
            let othersAmount = items.reduce(0) { $0 + $1.amount }
            let othersChanged = items.reduce(0) { $0 + $1.changed }
            let othersPercentage = total > 0 ? (Double(othersAmount) / Double(total)) * 100 : 0
            
            return CategoryChartItem(
                category: Category.othersCategory,
                amount: othersAmount,
                percentage: othersPercentage.rounded(to: 2),
                changed: othersChanged,
                iconColor: ChartColor.others.uiColor,
                backgroundColor: ChartColor.others.uiColor.withAlphaComponent(0.1)
            )
        }
    }
    
    let initialState = State()
    
    init(
        transactionRepository: TransactionRepositoryInterface,
        challengeRepository: ChallengeRepositoryInterface,
        categoryService: CategoryService
    ) {
        self.transactionRepository = transactionRepository
        self.challengeRepository = challengeRepository
        self.categoryService = categoryService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad, .refresh:
            return loadHomeData()
        case .selectMonth(let date):
            return Observable.concat([
                .just(.setSelectedMonth(date)),
                loadMonthlySummary(date),
                loadCurrentChallenges(date),
                loadChartData(date)
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
            
        case .setChartData(let items):
            newState.chartItems = items
            
        case .setError(let error):
            newState.error = error
        }
        
        return newState
    }
}

extension HomeReactor {
    
    func loadHomeData() -> Observable<Mutation> {
        return Observable.merge([
            loadMonthlySummary(currentState.selectedMonth),
            loadCurrentChallenges(currentState.selectedMonth),
            loadChartData(currentState.selectedMonth)
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
    
    private func loadCurrentChallenges(_ date: Date) -> Observable<Mutation> {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        return challengeRepository.fetchChallengesByMonth(year, month)
            .flatMap { [weak self] challenges -> Observable<[Challenge]> in
                guard let self = self, !challenges.isEmpty else { return .just([]) }
                
                return updateChallengesWithSpending(challenges)
            }
            .map { challenges in
                return .setCurrentChallenges(challenges)
            }
            .catch { error in
                print("❌ Failed to load current challenges: \(error)")
                return .just(.setCurrentChallenges([]))
            }
    }
    
    private func updateChallengesWithSpending(_ challenges: [Challenge]) -> Observable<[Challenge]> {
        let amountObservables = challenges.map { challenge in
            self.transactionRepository.fetchTotalAmount(
                categoryId: challenge.category.id,
                startDate: challenge.startDate,
                endDate: challenge.endDate
            )
        }
        
        return Observable.zip(amountObservables)
            .map { amounts in
                var updatedChallenges: [Challenge] = []
                for (var challenge, amount) in zip(challenges, amounts) {
                    challenge.currentSpending = amount
                    updatedChallenges.append(challenge)
                }
                return updatedChallenges
            }
    }
    
    private func loadChartData(_ date: Date) -> Observable<Mutation> {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let year = components.year, let month = components.month else {
            return .just(.setChartData([]))
        }
        
        let lastMonthDate = calendar.date(byAdding: .month, value: -1, to: date) ?? date
        let lastMonthComponents = calendar.dateComponents([.year, .month], from: lastMonthDate)
        guard let lastYear = lastMonthComponents.year, let lastMonth = lastMonthComponents.month else {
            return .just(.setChartData([]))
        }
        
        let currentMonthTransactions = transactionRepository.fetchTransactionByMonth(year, month)
        let lastMonthTransactions = transactionRepository.fetchTransactionByMonth(lastYear, lastMonth)
        
        return Observable.zip(currentMonthTransactions, lastMonthTransactions)
            .map { current, last in
                let currentExpenses = current.filter { $0.category.transactionType == .expense }
                let totalAmount = currentExpenses.reduce(0) { $0 + $1.amount }
                
                guard totalAmount > 0 else { return [] }
                
                let expensesByCategory = Dictionary(grouping: currentExpenses, by: { $0.category } )
                let lastExpenses = last.filter { $0.category.transactionType == .expense }
                let lastExpensesByCategory = Dictionary(grouping: lastExpenses, by: { $0.category })
                let lastAmounts = lastExpensesByCategory.mapValues { $0.reduce(0) { $0 + $1.amount } }
                
                let items = expensesByCategory.map { category, transactions -> CategoryChartItem in
                    let amount = transactions.reduce(0) { $0 + $1.amount }
                    let lastAmount = lastAmounts[category] ?? 0
                    let percentage = (Double(amount) / Double(totalAmount)) * 100
                    
                    return CategoryChartItem(
                        category: category,
                        amount: amount,
                        percentage: percentage.rounded(to: 2),
                        changed: amount - lastAmount
                    )
                }
                
                return items.sorted { $0.percentage > $1.percentage }
            }
            .map { .setChartData($0) }
            .catch { error in
                print("❌ Failed to load chart data: \(error)")
                return .just(.setChartData([]))
            }
    }
}
