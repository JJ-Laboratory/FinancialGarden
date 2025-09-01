//
//  ChallengeFormViewReactor.swift
//  FIG
//
//  Created by estelle on 8/31/25.
//

import ReactorKit

class ChallengeFormViewReactor: Reactor {
    
    enum Action {
        case viewDidLoad
        case selectCategory(Category)
        case selectPeriod(ChallengeDuration)
        case selectAmount(ChallengeSpendingLimit)
        case selectFruitCount(Int)
        case createButtonTapped
    }
    
    enum Mutation {
        case setCurrentSeedCount(Int)
        case setCategory(Category)
        case setPeriod(ChallengeDuration)
        case setAmount(Int)
        case setFruitCount(Int)
        case setCreate(Bool)
    }
    
    struct State {
        var currentSeedCount: Int = 0
        var selectedCategory: Category?
        var selectedPeriod: ChallengeDuration = .week
        var amount: Int = 0
        var fruitCount: Int = 0
        var availableSeeds: Int = 0
        var isEnabled: Bool = false
        var isCreating: Bool = false
    }
    
    let initialState = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            // 씨앗 개수 로드
            return .just(.setCurrentSeedCount(100))
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
            // 챌린지 생성
            return .just(.setCreate(true))
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
        case .setCreate(let isCreating):
            newState.isCreating = isCreating
        }
        newState.isEnabled = newState.selectedCategory != nil && newState.fruitCount > 0 && !newState.isCreating
        return newState
    }
}
