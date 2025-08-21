//
//  Challenge.swift
//  FIG
//
//  Created by Milou on 8/21/25.
//

import Foundation

struct Challenge {
    let id: UUID
    let category: Category
    let startDate: Date
    let endDate: Date
    let duration: ChallengeDuration
    let spendingLimit: Int
    let requiredSeedCount: Int
    let targetFruitsCount: Int
    let isCompleted: Bool
    let isSuccess: Bool
}

enum ChallengeDuration: String, CaseIterable {
    case week = "일주일"
    case month = "한달"
    
    var days: Int {
        switch self {
        case .week:
            return 7
        case .month:
            return 30
        }
    }
    
    var requiredSeed: Int {
        switch self {
        case .week:
            return 5
        case .month:
            return 3
        }
    }
}

enum ChallengeSpendingLimit: String, CaseIterable {
    case zero = "무지출"
    case one = "1만원"
    case five = "5만원"
    case ten = "10만원"
    
    var amount: Int {
        switch self {
        case .zero:
            return 0
        case .one:
            return 10_000
        case .five:
            return 50_000
        case .ten:
            return 100_000
        }
    }
}
