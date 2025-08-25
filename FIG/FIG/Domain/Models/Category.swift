//
//  Category.swift
//  FIG
//
//  Created by Milou on 8/21/25.
//

import Foundation

enum TransactionType: CaseIterable {
    case income
    case expense
    
    var title: String {
        switch self {
        case .income:
            return "수입"
        case .expense:
            return "지출"
        }
    }
}

struct Category {
    let id: UUID
    let title: String
    let iconName: String
    let transactionType: TransactionType
    let isDefault: Bool

    init(
        id: UUID = UUID(),
        title: String,
        iconName: String,
        transactionType: TransactionType,
        isDefault: Bool = false
    ) {
        self.id = id
        self.title = title
        self.iconName = iconName
        self.transactionType = transactionType
        self.isDefault = isDefault
    }
}
