//
//  ChallengeSpendingLimit.swift
//  FIG
//
//  Created by Milou on 8/21/25.
//

import Foundation

enum ChallengeSpendingLimit: Int, CaseIterable {
    case zero = 0
    case one = 10_000
    case five = 50_000
    case ten = 100_000
    
    var title: String {
        switch self {
        case .zero:
            return "무지출"
        case .one:
            return "1만원"
        case .five:
            return "5만원"
        case .ten:
            return "10만원"
        }
    }
}
