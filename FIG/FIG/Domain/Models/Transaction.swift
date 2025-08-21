//
//  Transaction.swift
//  FIG
//
//  Created by Milou on 8/21/25.
//

import Foundation

struct Transaction {
    let id: UUID
    let amount: Int
    let category: Category
    let title: String
    let payment: PaymentMethod
    let date: Date
    let memo: String?
}

enum PaymentMethod {
    case cash
    case card
    case account
    case other
}
