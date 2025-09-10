//
//  Home.swift
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
    case monthlySummary(MonthlySummary)
    case challenge(Challenge)
    case emptyState(EmptyStateType)
    case chartProgress(totalAmount: Int, items: [ChartProgressView.Item])
    case chartCategory(CategoryChartItem)
}
