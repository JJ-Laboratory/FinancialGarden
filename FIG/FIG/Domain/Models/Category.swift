//
//  Category.swift
//  FIG
//
//  Created by Milou on 8/21/25.
//

import UIKit

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

struct Category: Codable, Hashable {
    let id: UUID
    let title: String
    let iconName: String
    let transactionType: TransactionType
    
    enum CodingKeys: String, CodingKey {
        case id, title, iconName, transactionType
    }
}

extension Category {
    var icon: UIImage? {
        return UIImage(systemName: iconName)
    }
    
    var iconColor: UIColor {
        switch transactionType {
        case .income:
            return .primary
        case .expense:
            return .secondary 
        }
    }
    
    var backgroundColor: UIColor {
        switch transactionType {
        case .income:
            return .lightPink
        case .expense:
            return .lightBlue
        }
    }
}
