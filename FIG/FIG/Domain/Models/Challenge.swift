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

struct Challenge: Hashable {
    let id: UUID
    let category: Category
    let startDate: Date
    let endDate: Date
    let duration: ChallengeDuration
    var currentSpending: Int
    let spendingLimit: Int
    let requiredSeedCount: Int
    let targetFruitsCount: Int
    var isCompleted: Bool
    var status: ChallengeStatus
    
    init(
        id: UUID = UUID(),
        category: Category,
        startDate: Date = Date(),
        endDate: Date,
        duration: ChallengeDuration,
        currentSpending: Int = 0,
        spendingLimit: Int,
        requiredSeedCount: Int,
        targetFruitsCount: Int = 1,
        isCompleted: Bool = false,
        status: ChallengeStatus = .progress
    ) {
        self.id = id
        self.category = category
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
        self.currentSpending = currentSpending
        self.spendingLimit = spendingLimit
        self.requiredSeedCount = requiredSeedCount
        self.targetFruitsCount = targetFruitsCount
        self.isCompleted = isCompleted
        self.status = status
    }
}

enum ChallengeStatus: String {
    case progress
    case success
    case failure
    
    var title: String {
        switch self {
        case .progress: return "진행 중"
        case .success: return "챌린지 성공!"
        case .failure: return "챌린지 실패!"
        }
    }
    
    var message: String {
        switch self {
        case .progress: return ""
        case .success: return "개의 열매를 수확했어요\n새로운 챌린지에 도전해보세요!"
        case .failure: return "개의 씨앗이 소멸되었어요\n챌린지를 다시 도전해 보세요!"
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .progress: return ""
        case .success: return "새 챌린지 도전하기"
        case .failure: return "챌린지 다시 도전하기"
        }
    }
}

enum FilterType: String, CaseIterable {
    case inProgress = "진행 중"
    case completed = "완료"
}

enum ChallengeSection: Int {
    case gardenInfo
    case challengeList
}

enum ChallengeItem: Hashable {
    case gardenInfo(GardenRecord)
    case challenge(Challenge)
}

import UIKit

enum ProgressStage: Int {
    case level0, level1, level2, level3, level4, level5, level6
    
    init(progress: Float) {
        let level = Int(progress * 7)
        let clampedLevel = min(6, level)
        self = ProgressStage(rawValue: clampedLevel) ?? .level0
    }
    
    var image: UIImage? {
        return UIImage(systemName: "\(self.rawValue).circle")
    }
}
