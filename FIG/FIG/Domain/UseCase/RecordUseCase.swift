//
//  RecordUseCase.swift
//  FIG
//
//  Created by Milou on 9/8/25.
//

import Foundation
import RxSwift

final class RecordUseCase {
    private let transactionRepository: TransactionRepositoryInterface
    
    init(transactionRepository: TransactionRepositoryInterface) {
        self.transactionRepository = transactionRepository
    }
    
    func getMonthlySummary(year: Int, month: Int) -> Observable<MonthlySummary> {
        return transactionRepository.fetchTransactionByMonth(year, month)
            .map { transactions in
                let expense = transactions
                    .filter { $0.category.transactionType == .expense }
                    .reduce(0) { $0 + $1.amount }
                
                let income = transactions
                    .filter { $0.category.transactionType == .income }
                    .reduce(0) { $0 + $1.amount }
                
                return MonthlySummary(
                    expense: expense,
                    income: income,
                    hasRecords: expense > 0 || income > 0
                )
            }
    }
    
    func getCategoryChart(year: Int, month: Int) -> Observable<[CategoryChartItem]> {
        let lastMonthDate = Calendar.current.date(
            from: DateComponents(year: year, month: month-1)
        ) ?? Date()
        
        let lastComponents = Calendar.current.dateComponents([.year, .month], from: lastMonthDate)
        
        let currentMonthRecords = transactionRepository.fetchTransactionByMonth(year, month)
        let lastMonthRecords = transactionRepository.fetchTransactionByMonth(
            lastComponents.year ?? year,
            lastComponents.month ?? month
        )
        
        return Observable.zip(currentMonthRecords, lastMonthRecords)
            .map { current, last in
                self.createCategoryChartItems(current: current, last: last)
            }
    }
    
    func getSummaryChart(baseDate: Date, monthCount: Int) -> Observable<[SummaryChartItem]> {
        let calendar = Calendar.current
        var monthObservables: [Observable<[Transaction]>] = []
        
        for i in 0..<monthCount {
            guard let targetDate = calendar.date(byAdding: .month, value: -i, to: baseDate) else { continue }
            let components = calendar.dateComponents([.year, .month], from: targetDate)
            
            if let year = components.year, let month = components.month {
                monthObservables.append(transactionRepository.fetchTransactionByMonth(year, month))
            }
        }
        
        return Observable.zip(monthObservables)
            .map { transactionsByMonth in
                self.createSummaryChartItems(transactionsByMonth, baseDate: baseDate)
            }
    }
    
    // MARK: - Private Methods
    
    private func createCategoryChartItems(current: [Transaction], last: [Transaction]) -> [CategoryChartItem] {
        let currentExpenses = current
            .filter { $0.category.transactionType == .expense }
        let totalAmount = currentExpenses
            .reduce(0) { $0 + $1.amount }
        
        guard totalAmount > 0 else { return [] }
        
        let expensesByCategory = Dictionary(
            grouping: currentExpenses, by: { $0.category }
        )
        let lastExpenseByCategory = Dictionary(
            grouping: last.filter { $0.category.transactionType == .expense },
            by: { $0.category }
        )
        let lastAmounts = lastExpenseByCategory
            .mapValues { $0.reduce(0) {$0 + $1.amount} }
        
        let items = expensesByCategory
            .map { category, transactions -> CategoryChartItem in
                
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
    
    private func createSummaryChartItems(_ transactionsByMonth: [[Transaction]], baseDate: Date) -> [SummaryChartItem] {
        let calendar = Calendar.current
        var summaries: [SummaryChartItem] = []
        
        for (index, transactions) in transactionsByMonth.enumerated() {
            guard let targetDate = calendar
                .date(byAdding: .month, value: -index, to: baseDate)
            else { continue }
            
            let monthString = "\(calendar.component(.month, from: targetDate))"
            let income = transactions
                .filter { $0.category.transactionType == .income }
                .reduce(0) { $0 + $1.amount }
            let expense = transactions
                .filter { $0.category.transactionType == .expense }
                .reduce(0) { $0 + $1.amount }
            
            summaries.append(
                SummaryChartItem(
                    month: monthString,
                    income: income,
                    expense: expense
                )
            )
        }
        
        return summaries.reversed()
    }
}
