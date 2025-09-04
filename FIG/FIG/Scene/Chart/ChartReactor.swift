//
//  ChartReactor.swift
//  FIG
//
//  Created by estelle on 9/3/25.
//

import ReactorKit
import RxSwift
import Foundation
import UIKit

class ChartReactor: Reactor {
    
    enum Action {
        case viewDidLoad
        case selectMonth(Date)
    }
    
    enum Mutation {
        case setSelectedMonth(Date)
        case setChartData(category: [CategoryChartItem], summary: [SummaryChartItem])
    }
    
    struct State {
        var selectedMonth: Date = Date()
        var categoryTotalAmount: Int = 0
        var categoryChartItems: [CategoryChartItem] = []
        var summaryChartItems: [SummaryChartItem] = []
        
        var categoryProgressItems: [ChartProgressView.Item] {
            categoryTotalAmount > 0
            ? categoryChartItems.map { ChartProgressView.Item(value: Int($0.percentage.rounded()), color: $0.iconColor) }
            : [ChartProgressView.Item(value: 100, color: ChartColor.none.uiColor)]
        }
        var summaryBarChartItems: [TransactionBarChart.Item] {
            summaryChartItems.map {
                TransactionBarChart.Item.transaction(label: $0.month, income: $0.income, expense: $0.expense)
            }
        }
    }
    
    private let categoryService: CategoryService
    private let transactionRepository: TransactionRepositoryInterface
    
    let initialState: State
    
    init(transactionRepository: TransactionRepositoryInterface, categoryService: CategoryService = CategoryService.shared) {
        self.transactionRepository = transactionRepository
        self.categoryService = categoryService
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return fetchData(date: currentState.selectedMonth).map(Mutation.setChartData)
        case .selectMonth(let date):
            return Observable.concat([
                .just(.setSelectedMonth(date)),
                fetchData(date: date).map(Mutation.setChartData)
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setSelectedMonth(let date):
            newState.selectedMonth = date
            
        case .setChartData(let categoryChartItems, let summaryChartItems):
            let total = categoryChartItems.reduce(0) { $0 + $1.amount }
            newState.categoryTotalAmount = total
            if newState.categoryTotalAmount > 0 {
                newState.categoryChartItems = makeCategoryItems(from: categoryChartItems, total: total)
            } else {
                newState.categoryChartItems = []
            }
            newState.summaryChartItems = summaryChartItems
        }
        return newState
    }
    
    private func makeCategoryItems(from chartItems: [CategoryChartItem], total: Int) -> [CategoryChartItem] {
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
        
        let category = categoryService.fetchCategoryByID(UUID(uuidString: "00000000-0000-0000-0000-000000000016")!)!
        
        return CategoryChartItem(
            category: category,
            amount: othersAmount,
            percentage: othersPercentage.rounded(to: 2),
            changed: othersChanged,
            iconColor: ChartColor.others.uiColor,
            backgroundColor: ChartColor.others.uiColor.withAlphaComponent(0.1)
        )
    }
    
    private func fetchData(date: Date) -> Observable<([CategoryChartItem], [SummaryChartItem])>{
        let categoryChartItemsObservable = createCategoryChartItems(date: date)
        let summaryChartItemsObservable = createSummaryChartItems(date: date)
        return Observable.zip(categoryChartItemsObservable, summaryChartItemsObservable)
    }
    
    private func createCategoryChartItems(date: Date) -> Observable<[CategoryChartItem]> {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let year = components.year, let month = components.month else {
            return .just([])
        }
        
        let lastMonthDate = calendar.date(byAdding: .month, value: -1, to: date)!
        let lastMonthComponents = calendar.dateComponents([.year, .month], from: lastMonthDate)
        guard let lastYear = lastMonthComponents.year, let lastMonth = lastMonthComponents.month else {
            return .just([])
        }
        
        let currentMonthTransactions = transactionRepository.fetchTransactionByMonth(year, month)
        let lastMonthTransactions = transactionRepository.fetchTransactionByMonth(lastYear, lastMonth)
        
        return Observable.zip(currentMonthTransactions, lastMonthTransactions).map { current, last in
            let currentExpenses = current.filter { $0.category.transactionType == .expense }
            let totalAmount = currentExpenses.reduce(0) { $0 + $1.amount }
            let expensesByCategory = Dictionary(grouping: currentExpenses, by: { $0.category })
            
            let lastExpenses = last.filter { $0.category.transactionType == .expense }
            let lastExpensesByCategory = Dictionary(grouping: lastExpenses, by: { $0.category })
            let lastAmounts = lastExpensesByCategory.mapValues { $0.reduce(0) { $0 + $1.amount } }
            
            let items = expensesByCategory.map {category, transactions -> CategoryChartItem in
                let amount = transactions.reduce(0) { $0 + $1.amount }
                let lastAmount = lastAmounts[category] ?? 0
                let percentage = totalAmount > 0 ? (Double(amount) / Double(totalAmount)) * 100 : 0
                
                return CategoryChartItem(
                    category: category, amount: amount, percentage: percentage.rounded(to: 2), changed: amount - lastAmount)
            }
            return items.sorted { $0.percentage > $1.percentage }
        }
    }
    
    private func createSummaryChartItems(date: Date) -> Observable<[SummaryChartItem]> {
        let calendar = Calendar.current
        var monthFetchObservables: [Observable<[Transaction]>] = []
        
        for i in 0..<6 {
            let targetDate = calendar.date(byAdding: .month, value: -i, to: date)!
            let components = calendar.dateComponents([.year, .month], from: targetDate)
            if let year = components.year, let month = components.month {
                monthFetchObservables.append(transactionRepository.fetchTransactionByMonth(year, month))
            }
        }
        
        return Observable.zip(monthFetchObservables).map { transactionsByMonth -> [SummaryChartItem] in
            var summaries : [SummaryChartItem] = []
            
            for (index, transactions) in transactionsByMonth.enumerated() {
                let targetDate = calendar.date(byAdding: .month, value: -index, to: date)!
                let monthString = "\(calendar.component(.month, from: targetDate))"
                
                let income = transactions.filter { $0.category.transactionType == .income }.reduce(0) { $0 + $1.amount }
                let expense = transactions.filter { $0.category.transactionType == .expense }.reduce(0) { $0 + $1.amount }
                
                summaries.append(SummaryChartItem(month: monthString, income: income, expense: expense))
            }
            
            return summaries.reversed()
        }
    }
}
