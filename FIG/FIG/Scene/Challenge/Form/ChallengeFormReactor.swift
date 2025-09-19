//
//  ChallengeFormViewReactor.swift
//  FIG
//
//  Created by estelle on 8/31/25.
//

import ReactorKit
import Foundation

class ChallengeFormReactor: Reactor {
    
    enum Mode: Equatable {
        case create
        case detail(Challenge)
        case edit(MBTIResult)
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
        case showAlert(String)
    }
    
    struct State {
        let mode: Mode
        var mbtiResult: MBTIResult?
        var currentSeedCount: Int = 0
        var selectedCategory: Category?
        var selectedPeriod: ChallengeDuration = .week
        var amount: Int = 0
        var fruitCount: Int = 0
        @Pulse var isClose: Bool = false
        @Pulse var alertMessage: String?
        
        init(mode: Mode) {
            self.mode = mode
            switch mode {
            case .create: break
            case .detail(let challenge):
                self.selectedCategory = challenge.category
                self.selectedPeriod = challenge.duration
                self.amount = challenge.spendingLimit
                self.fruitCount = challenge.targetFruitsCount
            case .edit(let mbtiResult):
                self.mbtiResult = mbtiResult
                self.selectedCategory = mbtiResult.categoryData
                self.selectedPeriod = mbtiResult.durationType
                self.amount = mbtiResult.spendingLimit
                self.fruitCount = 0
            }
        }
        
        var isEnabled: Bool {
            selectedCategory != nil && fruitCount > 0
        }
        var isSeedInsufficient: Bool {
            currentSeedCount < selectedPeriod.requiredSeed
        }
        var infoLabelText: String {
            if isSeedInsufficient {
                return "현재 사용 가능한 씨앗이 부족해요.\n가계부 내역을 등록하고 씨앗을 모아보세요!"
            } else {
                return "현재 사용 가능한 씨앗: \(currentSeedCount)개\n열매 1개당 필요 씨앗: 일주일 5개 / 한달 3개"
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
            
            return challengeRepository.fetchAllChallenges()
                .flatMap { [weak self] challenges -> Observable<Mutation> in
                    guard let self = self else { return .empty() }
                    
                    if isChallengeExist(newChallenge, challenges: challenges) {
                        return .just(.showAlert("이미 동일한 카테고리와 기간의 챌린지가 진행 중입니다.\n다른 챌린지를 추가해주세요!"))
                    }
                    let saveChallenge = challengeRepository.saveChallenge(newChallenge)
                    let deductSeeds = gardenRepository.add(seeds: -newChallenge.requiredSeedCount, fruits: 0)
                    
                    return Observable.zip(saveChallenge, deductSeeds)
                        .map { _ in .close }
                        .catchAndReturn(.showAlert("에러가 발생했습니다.\n잠시 후 다시 시도해주세요!"))
                }
            
        case .deleteButtonTapped:
            guard case .detail(let challenge) = currentState.mode else { return .empty() }
            return challengeRepository.deleteChallenge(id: challenge.id)
                .map { _ in .close }
                .catch { error in return .just(.showAlert(error.localizedDescription)) }
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
        case .showAlert(let message):
            newState.alertMessage = message
        }
        return newState
    }
    
    private func createChallenge() -> Challenge? {
        guard let category = currentState.selectedCategory else { return nil }
        
        let startDate = Date()
        let endDate: Date
        let requiredSeedCount: Int
        if currentState.selectedPeriod == .week {
            endDate = Calendar.current.date(byAdding: .day, value: 6, to: startDate) ?? startDate
            requiredSeedCount = currentState.fruitCount * 5
        } else {
            let oneMonthDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate) ?? startDate
            endDate = Calendar.current.date(byAdding: .day, value: -1, to: oneMonthDate) ?? oneMonthDate
            requiredSeedCount = currentState.fruitCount * 3
        }
        
        return Challenge(category: category, endDate: endDate, duration: currentState.selectedPeriod, spendingLimit: currentState.amount, requiredSeedCount: requiredSeedCount, targetFruitsCount: currentState.fruitCount)
    }
    
    private func isChallengeExist(_ newChallenge: Challenge, challenges: [Challenge]) -> Bool {
        let calendar = Calendar.current
        let newStart = calendar.startOfDay(for: newChallenge.startDate)
        let newEnd = calendar.startOfDay(for: newChallenge.endDate)
        
        return challenges.contains { challenge in
            let start = calendar.startOfDay(for: challenge.startDate)
            let end = calendar.startOfDay(for: challenge.endDate)
            return challenge.category.id == newChallenge.category.id &&
            start == newStart &&
            end == newEnd &&
            !challenge.isCompleted
        }
    }
}

extension ChallengeFormReactor.Mode {
    var isCreateButtonHidden: Bool {
        switch self {
        case .create, .edit: return false
        case .detail: return true
        }
    }
    
    var isDeleteButtonHidden: Bool {
        switch self {
        case .create, .edit: return true
        case .detail: return false
        }
    }
    
    var isFormEditable: Bool {
        switch self {
        case .detail: return false
        default: return true
        }
    }
    
    var titleText: String {
        switch self {
        case .edit: return "추천 챌린지를 추가하시나요?"
        default: return "어떤 챌린지를 추가하시나요?"
        }
    }
}
