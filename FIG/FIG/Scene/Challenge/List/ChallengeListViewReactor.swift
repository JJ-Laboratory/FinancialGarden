//
//  ChallengeListViewReactor.swift
//  FIG
//
//  Created by estelle on 8/29/25.
//

import ReactorKit
import RxSwift
import Foundation

class ChallengeListViewReactor: Reactor {
    
    enum Action {
        case viewDidLoad
        case selectTab(ChallengeDuration)
        case selectFilter(FilterType)
    }
    
    enum Mutation {
        case setGardenInfo(GardenRecord)
        case setChallenges([Challenge])
        case setSelectedTab(ChallengeDuration)
        case setSelectedFilter(FilterType)
    }
    
    struct State {
        var gardenInfo: GardenRecord?
        var allChallenges: [Challenge] = []
        var selectedTab: ChallengeDuration = .week
        var selectedFilter: FilterType = .inProgress
        var displayedChallenges: [Challenge] {
            let tabFiltered = allChallenges.filter { $0.duration == selectedTab }
            let isCompleted = selectedFilter == .completed
            return tabFiltered.filter { $0.isCompleted == isCompleted }
        }
    }
    
    let initialState = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            let gardenInfo = GardenRecord(totalSeeds: 999, totalFruits: 999)
            let challenges = loadDummyData()
            return Observable.concat([
                .just(.setGardenInfo(gardenInfo)),
                .just(.setChallenges(challenges))
            ])
        case .selectTab(let tab):
            return .just(.setSelectedTab(tab))
        case .selectFilter(let filter):
            return .just(.setSelectedFilter(filter))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setGardenInfo(let gardenInfo):
            newState.gardenInfo = gardenInfo
        case .setChallenges(let challenges):
            newState.allChallenges = challenges
        case .setSelectedTab(let tab):
            newState.selectedTab = tab
        case .setSelectedFilter(let filter):
            newState.selectedFilter = filter
        }
        return newState
    }
    
    private func loadDummyData() -> [Challenge] {
        let allChallenges = [
            // 일주일 챌린지 데이터
            Challenge(category: Category(id: UUID(), title: "의료・건강・피트니스", iconName: "ll", transactionType: .expense), endDate: Date(), duration: .week, spendingLimit: 7897890, requiredSeedCount: 5),
            Challenge(category: Category(id: UUID(), title: "일주일", iconName: "ll", transactionType: .expense), endDate: Date(), duration: .week, spendingLimit: 7897890, requiredSeedCount: 5),
            Challenge(category: Category(id: UUID(), title: "일주일", iconName: "ll", transactionType: .expense), endDate: Date(), duration: .week, spendingLimit: 7897890, requiredSeedCount: 5),
            Challenge(category: Category(id: UUID(), title: "일주일 챌린지 완료", iconName: "ll", transactionType: .expense), endDate: Date(), duration: .week, spendingLimit: 7897890, requiredSeedCount: 5, isCompleted: true),
            // 한달 챌린지 데이터
            Challenge(category: Category(id: UUID(), title: "한달", iconName: "ll", transactionType: .expense), endDate: Date(), duration: .month, spendingLimit: 7897890, requiredSeedCount: 5),
            Challenge(category: Category(id: UUID(), title: "한달 챌린지 완료", iconName: "ll", transactionType: .expense), endDate: Date(), duration: .month, spendingLimit: 7897890, requiredSeedCount: 5, isCompleted: true),
        ]
        return allChallenges
    }
}
