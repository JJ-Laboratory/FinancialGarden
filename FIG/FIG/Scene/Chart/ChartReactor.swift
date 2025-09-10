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

    private let recordUseCase: RecordUseCase
    
    let initialState: State
    
    init(recordUseCase: RecordUseCase) {
        self.recordUseCase = recordUseCase
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return fetchData(date: currentState.selectedMonth)
        case .selectMonth(let date):
            return Observable.concat([
                .just(.setSelectedMonth(date)),
                fetchData(date: date)
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
                newState.categoryChartItems = ChartDataProcessor.makeCategoryItems(from: categoryChartItems, total: total)
            } else {
                newState.categoryChartItems = []
            }
            newState.summaryChartItems = summaryChartItems
        }
        return newState
    }
    
    private func fetchData(date: Date) -> Observable<Mutation> {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        let categoryChartObservable = recordUseCase.getCategoryChart(year: year, month: month)
        let summaryChartObservable = recordUseCase.getSummaryChart(baseDate: date, monthCount: 6)
        
        return Observable.zip(categoryChartObservable, summaryChartObservable)
            .map { .setChartData(category: $0, summary: $1) }
    }
}
