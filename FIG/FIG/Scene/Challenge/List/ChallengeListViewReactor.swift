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
    
    private let challengeRepository: ChallengeRepositoryInterface
    private let gardenRepository: GardenRepositoryInterface
    private let transactionRepository: TransactionRepositoryInterface
    
    let initialState: State
    
    init(challengeRepository: ChallengeRepositoryInterface, gardenRepository: GardenRepositoryInterface, transactionRepository: TransactionRepositoryInterface) {
        self.challengeRepository = challengeRepository
        self.gardenRepository = gardenRepository
        self.transactionRepository = transactionRepository
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            let challengesWithSpending = fetchChallengesWithSpending()
            let updatedChallenges = challengesWithSpending
                .flatMap { [weak self] challenges -> Observable<[Challenge]> in
                    guard let self else { return .just([]) }
                    return updateStatus(challenges)
                }
            let gardenInfoObservable = gardenRepository.fetchGardenRecord()
            
            return Observable.zip(updatedChallenges, gardenInfoObservable)
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
    
    private func fetchChallengesWithSpending() -> Observable<[Challenge]> {
        return challengeRepository.fetchAllChallenges()
            .flatMap { [weak self] challenges -> Observable<[Challenge]> in
                guard let self, !challenges.isEmpty else { return .just([]) }
                
                let amountObservables = challenges.map { challenge in
                    self.transactionRepository.fetchTotalAmount(categoryId: challenge.category.id, startDate: challenge.startDate, endDate: challenge.endDate)
                }
                
                return Observable.zip(amountObservables)
                    .map { amounts in
                        var updatedChallenges: [Challenge] = []
                        for (var challenge, amount) in zip(challenges, amounts) {
                            challenge.currentSpending = amount
                            updatedChallenges.append(challenge)
                        }
                        return updatedChallenges
                    }
            }
    }
    
    private func updateStatus(_ challenges: [Challenge]) -> Observable<[Challenge]> {
        var editedChallenge: [Challenge] = []
        var finalChallenges = challenges
        
        for (index, challenge) in challenges.enumerated() {
            var updatedChallenge = challenge
            let progressValue = challenge.startDate.progress(to: challenge.endDate)
            
            if progressValue >= 1 {
                if challenge.currentSpending <= challenge.spendingLimit {
                    updatedChallenge.status = .success
                } else {
                    updatedChallenge.status = .failure
                }
                editedChallenge.append(updatedChallenge)
                finalChallenges[index] = updatedChallenge
            } else if challenge.currentSpending > challenge.spendingLimit {
                updatedChallenge.status = .failure
                editedChallenge.append(updatedChallenge)
                finalChallenges[index] = updatedChallenge
            } else {
                updatedChallenge.status = .progress
                editedChallenge.append(updatedChallenge)
                finalChallenges[index] = updatedChallenge
            }
        }
        
        if editedChallenge.isEmpty {
            return .just(challenges)
        }
        
        let editObservables = editedChallenge.map { updatedChallenge in
            self.challengeRepository.editChallenge(updatedChallenge)
        }
        
        return Observable.zip(editObservables)
            .map { _ in finalChallenges }
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
