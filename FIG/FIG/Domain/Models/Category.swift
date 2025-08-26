//
//  Category.swift
//  FIG
//
//  Created by Milou on 8/21/25.
//

import Foundation

enum TransactionType: String, CaseIterable, Codable {
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

struct Category: Codable {
    let id: UUID
    let title: String
    let iconName: String
    let transactionType: TransactionType
    
    enum CodingKeys: String, CodingKey {
            case id, title, iconName, transactionType
        }
}
