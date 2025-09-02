//
//  ChallengeFormViewReactor.swift
//  FIG
//
//  Created by estelle on 8/31/25.
//

import ReactorKit
import Foundation

class ChallengeFormViewReactor: Reactor {
    
    enum Mode: Equatable {
        case create
        case detail(Challenge)
    }
    
    enum Action {
        case viewDidLoad
        case selectCategory(Category)
        case selectPeriod(ChallengeDuration)
        case selectAmount(ChallengeSpendingLimit)
        case selectFruitCount(Int)
        case createButtonTapped
        case deleteButtonTapped
    }
    
    enum Mutation {
        case setCurrentSeedCount(Int)
        case setCategory(Category)
        case setPeriod(ChallengeDuration)
        case setAmount(Int)
        case setFruitCount(Int)
        case close
        case error(String)
    }
    
    struct State {
        let mode: Mode
        var currentSeedCount: Int = 0
        var selectedCategory: Category?
        var selectedPeriod: ChallengeDuration = .week
        var amount: Int = 0
        var fruitCount: Int = 0
        var isEditingEnable: Bool = true
        @Pulse var isClose: Bool = false
        @Pulse var errorMessage: String?
        var isEnabled: Bool {
            selectedCategory != nil && fruitCount > 0
        }
        
        init(mode: Mode) {
            self.mode = mode
            switch mode {
            case .create: break
            case .detail(let challenge):
                self.selectedCategory = challenge.category
                self.selectedPeriod = challenge.duration
                self.amount = challenge.spendingLimit
                self.fruitCount = challenge.targetFruitsCount
                self.isEditingEnable = false
            }
        }
    }
    
    private let challengeRepository: ChallengeRepositoryInterface
    private let gardenRepository: GardenRepositoryInterface
    
    let initialState: State
    
    init(mode: Mode, challengeRepository: ChallengeRepositoryInterface, gardenRepository: GardenRepositoryInterface) {
        self.challengeRepository = challengeRepository
        self.gardenRepository = gardenRepository
        self.initialState = State(mode: mode)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return gardenRepository.fetchGardenRecord()
                .map { .setCurrentSeedCount($0.totalSeeds) }
            
        case .selectCategory(let category):
            return .just(.setCategory(category))
            
        case .selectPeriod(let period):
            return Observable.concat([
                .just(.setPeriod(period)),
                .just(.setFruitCount(0))
            ])
            
        case .selectAmount(let amount):
            if amount == .zero {
                return .just(.setAmount(0))
            } else {
                return .just(.setAmount(currentState.amount + amount.rawValue))
            }
            
        case .selectFruitCount(let fruitCount):
            let maximum = max(0, currentState.currentSeedCount / currentState.selectedPeriod.requiredSeed)
            let newCount = min(max(0, currentState.fruitCount + fruitCount), maximum)
            return .just(.setFruitCount(newCount))
            
        case .createButtonTapped:
            guard let newChallenge = createChallenge() else {return .empty()}
            let saveChallenge = challengeRepository.saveChallenge(newChallenge)
            let deductSeeds = gardenRepository.add(seeds: -newChallenge.requiredSeedCount, fruits: 0)
            
            return Observable.zip(saveChallenge, deductSeeds)
                .map { _ in .close }
                .catch { error in return .just(.error(error.localizedDescription)) }
            
        case .deleteButtonTapped:
            guard case .detail(let challenge) = currentState.mode else { return .empty() }
            return challengeRepository.deleteChallenge(id: challenge.id)
                .map { _ in .close }
                .catch { error in return .just(.error(error.localizedDescription)) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setCurrentSeedCount(let currentSeedCount):
            newState.currentSeedCount = currentSeedCount
        case .setCategory(let category):
            newState.selectedCategory = category
        case .setPeriod(let period):
            newState.selectedPeriod = period
        case .setAmount(let amount):
            newState.amount = amount
        case .setFruitCount(let fruitCount):
            newState.fruitCount = fruitCount
        case .close:
            newState.isClose = true
        case .error(let message):
            newState.errorMessage = message
        }
        return newState
    }
    
    private func createChallenge() -> Challenge? {
        guard let category = currentState.selectedCategory else { return nil }
        
        let startDate = Date()
        let endDate: Date
        let requiredSeedCount: Int
        if currentState.selectedPeriod == .week {
            endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate) ?? startDate
            requiredSeedCount = currentState.fruitCount * 5
        } else {
            endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate) ?? startDate
            requiredSeedCount = currentState.fruitCount * 3
        }
        
        return Challenge(category: category, endDate: endDate, duration: currentState.selectedPeriod, spendingLimit: currentState.amount, requiredSeedCount: requiredSeedCount, targetFruitsCount: currentState.fruitCount, status: .success)
    }
}
