//
//  ChartDataProcessor.swift
//  FIG
//
//  Created by Milou on 9/10/25.
//

import Foundation

struct ChartDataProcessor {
    static func makeCategoryItems(from chartItems: [CategoryChartItem], total: Int) -> [CategoryChartItem] {
         let baseItems = chartItems.prefix(4).enumerated().map { (index, data) in
             data.withColor(ChartColor.rank(index))
         }
         guard chartItems.count > 4 else { return baseItems }
         
         let others = chartItems.dropFirst(4)
         return baseItems + [makeOthersCategory(from: others, total: total)]
     }
     
     static func createProgressItems(from chartItems: [CategoryChartItem], totalAmount: Int) -> [ChartProgressView.Item] {
         return totalAmount > 0
             ? chartItems.map { ChartProgressView.Item(value: Int($0.percentage.rounded()), color: $0.iconColor) }
             : [ChartProgressView.Item(value: 100, color: ChartColor.none.uiColor)]
     }
     
     private static func makeOthersCategory(from items: ArraySlice<CategoryChartItem>, total: Int) -> CategoryChartItem {
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
