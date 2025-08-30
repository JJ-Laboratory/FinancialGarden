//
//  Transaction.swift
//  FIG
//
//  Created by Milou on 8/21/25.
//

import UIKit

enum PaymentMethod: String, CaseIterable, Hashable {
    case cash
    case card
    case account
    case other
    
    var title: String {
        switch self {
        case .cash:
            return "현금"
        case .card:
            return "카드"
        case .account:
            return "계좌"
        case .other:
            return "페이∙기타금융"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .cash:
            return UIImage(systemName: "banknote")
        case .card:
            return UIImage(systemName: "creditcard")
        case .account:
            return UIImage(systemName: "building.columns")
        case .other:
            return UIImage(systemName: "ellipsis.circle")
        }
    }
}

struct Transaction {
    let id: UUID
    let amount: Int
    let category: Category
    let title: String
    let payment: PaymentMethod
    let date: Date
    let memo: String?

    init(
        id: UUID = UUID(),
        amount: Int,
        category: Category,
        title: String,
        payment: PaymentMethod,
        date: Date = Date(),
        memo: String? = nil
    ) {
        self.id = id
        self.amount = amount
        self.category = category
        self.title = title
        self.payment = payment
        self.date = date
        self.memo = memo
    }
}
