//
//  HomeModel.swift
//  FIG
//
//  Created by Milou on 9/2/25.
//

import Foundation

enum HomeSection: Int, CaseIterable, Hashable {
    case record = 0
    case challenge = 1
    case chart = 2
    
    var title: String {
        switch self {
        case .record: return "가계부"
        case .challenge: return "챌린지"
        case .chart: return "차트"
        }
    }
    
    var tabIndex: Int {
        return self.rawValue + 1
    }
}

enum HomeItem: Hashable {
    case monthlySummary(expense: Int, income: Int)
    case challenge(Challenge)
    case emptyState(EmptyStateType)
    case chartProgress(totalAmount: Int, items: [ChartProgressView.Item])
    case chartCategory(CategoryChartItem)
    
    static func == (lhs: HomeItem, rhs: HomeItem) -> Bool {
        switch (lhs, rhs) {
        case (.monthlySummary(let lhsExpense, let lhsIncome), .monthlySummary(let rhsExpense, let rhsIncome)):
            return lhsExpense == rhsExpense && lhsIncome == rhsIncome
            
        case (.challenge(let lhsChallenge), .challenge(let rhsChallenge)):
            return lhsChallenge.id == rhsChallenge.id
            
        case (.emptyState(let lhs), .emptyState(let rhs)):
            return lhs == rhs
        case (.chartProgress(let lhsTotal, let lhsItems), .chartProgress(let rhsTotal, let rhsItems)):
            return lhsTotal == rhsTotal && lhsItems == rhsItems
        case (.chartCategory(let lhs), .chartCategory(let rhs)):
            return lhs.category.id == rhs.category.id
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .monthlySummary(let expense, let income):
            hasher.combine("monthlySummary")
            hasher.combine(expense)
            hasher.combine(income)
        case .challenge(let challenge):
            hasher.combine("challenge")
            hasher.combine(challenge.id)
        case .emptyState(let type):
            hasher.combine("emptyState")
            hasher.combine(type)
        case .chartProgress(let totalAmount, let items):
            hasher.combine("chartProgress")
            hasher.combine(totalAmount)
            hasher.combine(items.count)
        case .chartCategory(let item):
            hasher.combine("chartCategory")
            hasher.combine(item.category.id)
        }
    }
}
