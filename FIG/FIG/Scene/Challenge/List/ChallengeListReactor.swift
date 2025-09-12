//
//  ChallengeListViewReactor.swift
//  FIG
//
//  Created by estelle on 8/29/25.
//

import ReactorKit
import RxSwift
import Foundation

class ChallengeListReactor: Reactor {
    
    enum Action {
        case viewDidLoad
        case selectTab(ChallengeDuration)
        case selectFilter(FilterType)
        case confirmButtonTapped(Challenge)
        case animationFinished
    }
    
    enum Mutation {
        case setGardenInfo(GardenRecord)
        case setChallenges([Challenge])
        case setSelectedTab(ChallengeDuration)
        case setSelectedFilter(FilterType)
        case setProcessedChallenge(Challenge?)
        case fruitIncreaseAnimation(from: Int, to: Int)
        case showPopup(Challenge)
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
        var processedChallenge: Challenge?
        @Pulse var animation: (from: Int, to: Int)?
        @Pulse var challengeForPopup: Challenge?
    }
    
    private let challengeUseCase: ChallengeUseCase
    private let challengeRepository: ChallengeRepositoryInterface
    private let gardenRepository: GardenRepositoryInterface
    
    let initialState: State
    
    init(
        challengeUseCase: ChallengeUseCase,
        challengeRepository: ChallengeRepositoryInterface,
        gardenRepository: GardenRepositoryInterface
    ) {
        self.challengeUseCase = challengeUseCase
        self.challengeRepository = challengeRepository
        self.gardenRepository = gardenRepository
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            let updatedChallenges = challengeUseCase.getAllChallengesWithStatus()
            let gardenInfo = gardenRepository.fetchGardenRecord()
            
            return Observable.zip(updatedChallenges, gardenInfo)
                .flatMap { challenges, gardenInfo -> Observable<Mutation> in
                    return .concat([
                        .just(.setChallenges(challenges)),
                        .just(.setGardenInfo(gardenInfo))
                    ])
                }
            
        case .selectTab(let tab):
            return .just(.setSelectedTab(tab))
        case .selectFilter(let filter):
            return .just(.setSelectedFilter(filter))
            
        case .confirmButtonTapped(let challenge):
            return handleConfirm(challenge)
            
        case .animationFinished:
            guard let challenge = currentState.processedChallenge else {
                return .empty()
            }
            return .concat([
                .just(.showPopup(challenge)),
                .just(.setProcessedChallenge(nil))
            ])
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
        case .setProcessedChallenge(let challenge):
            newState.processedChallenge = challenge
        case .fruitIncreaseAnimation(let from, let to):
            newState.animation = (from, to)
        case .showPopup(let challenge):
            newState.challengeForPopup = challenge
        }
        return newState
    }
    
    private func handleConfirm(_ challenge: Challenge) -> Observable<Mutation> {
        var updatedChallenge = challenge
        updatedChallenge.isCompleted = true
        
        switch challenge.status {
        case .success:
            let editChallengeObservable = challengeRepository.editChallenge(updatedChallenge)
            let addedFruitsObservable = gardenRepository.add(seeds: 0, fruits: challenge.targetFruitsCount)
            return Observable.zip(editChallengeObservable, addedFruitsObservable)
                .flatMap { (editChallenge, updatedRecord) -> Observable<Mutation> in
                    let currentFruitCount = self.currentState.gardenInfo?.totalFruits ?? 0
                    return .concat([
                        .just(.setGardenInfo(updatedRecord)),
                        .just(.setProcessedChallenge(editChallenge)),
                        .just(.fruitIncreaseAnimation(from: currentFruitCount, to: updatedRecord.totalFruits))
                    ])
                }
            
        case .failure:
            return challengeRepository.editChallenge(updatedChallenge)
                .map { .showPopup($0) }
            
        case .progress:
            return .empty()
        }
    }
}
