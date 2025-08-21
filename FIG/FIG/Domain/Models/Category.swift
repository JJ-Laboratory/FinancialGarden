//
//  Category.swift
//  FIG
//
//  Created by Milou on 8/21/25.
//

import Foundation

struct Category {
    let id: UUID
    let title: String
    let iconName: String
    let transactionType: TransactionType
    let isDefault: Bool
}

enum TransactionType: String, CaseIterable {
    case income = "수입"
    case expense = "지출"
}
