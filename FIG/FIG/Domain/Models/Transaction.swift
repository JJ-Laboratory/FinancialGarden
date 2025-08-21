//
//  Transaction.swift
//  FIG
//
//  Created by Milou on 8/21/25.
//

import Foundation

enum PaymentMethod {
    case cash
    case card
    case account
    case other
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
