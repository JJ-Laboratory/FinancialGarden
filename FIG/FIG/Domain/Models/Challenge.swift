//
//  Challenge.swift
//  FIG
//
//  Created by Milou on 8/21/25.
//

import Foundation

enum ChallengeDuration: Int, CaseIterable {
    case week = 7
    case month = 30

    var title: String {
        switch self {
        case .week:
            return "일주일"
        case .month:
            return "한달"
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

    init(
        id: UUID = UUID(),
        category: Category,
        startDate: Date = Date(),
        endDate: Date,
        duration: ChallengeDuration,
        spendingLimit: Int,
        requiredSeedCount: Int,
        targetFruitsCount: Int = 1,
        isCompleted: Bool = false,
        isSuccess: Bool = false
    ) {
        self.id = id
        self.category = category
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
        self.spendingLimit = spendingLimit
        self.requiredSeedCount = requiredSeedCount
        self.targetFruitsCount = targetFruitsCount
        self.isCompleted = isCompleted
        self.isSuccess = isSuccess
    }
}
