//
//  Chart.swift
//  FIG
//
//  Created by estelle on 9/3/25.
//

import Foundation
import UIKit

enum ChartSection {
    case category
    case summary
}

enum ChartItem: Hashable {
    case categoryProgress(totalAmount: Int, items: [ChartProgressView.Item])
    case categoryItem(CategoryChartItem)
    case summaryItem(SummaryChartItem)
}

struct CategoryChartItem: Hashable {
    let id: UUID
    let category: Category
    let amount: Int
    let percentage: Double
    let changed: Int
    let iconColor: UIColor
    let backgroundColor: UIColor
    
    init(
        id: UUID = UUID(),
        category: Category,
        amount: Int,
        percentage: Double,
        changed: Int,
        iconColor: UIColor = .gray2,
        backgroundColor: UIColor = .background
    ) {
        self.id = id
        self.category = category
        self.amount = amount
        self.percentage = percentage
        self.changed = changed
        self.iconColor = iconColor
        self.backgroundColor = backgroundColor
    }
}

extension CategoryChartItem {
    func withColor(_ chartColor: ChartColor) -> CategoryChartItem {
        return CategoryChartItem(
            category: self.category,
            amount: self.amount,
            percentage: self.percentage,
            changed: self.changed,
            iconColor: chartColor.uiColor,
            backgroundColor: chartColor.uiColor.withAlphaComponent(0.1)
        )
    }
}

struct SummaryChartItem: Hashable {
    let id = UUID()
    let month: String
    let income: Int
    let expense: Int
    var balance: Int {
        income - expense
    }
}

enum ChartColor {
    case rank(Int)
    case others
    case none
}

extension ChartColor {
    var uiColor: UIColor {
        switch self {
        case .rank(let index):
            switch index {
            case 0: return .pink
            case 1: return .primary
            case 2: return .secondary
            case 3: return .secondaryBlue
            default: return .gray2
            }
        case .others:
            return .gray2
        case .none:
            return .background
        }
    }
}
