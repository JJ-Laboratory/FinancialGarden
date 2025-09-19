//
//  AnalysisResultReactor.swift
//  FIG
//
//  Created by estelle on 9/16/25.
//

import RxSwift
import ReactorKit

class AnalysisResultReactor: Reactor {
    
    enum Action {
        case viewDidLoad
        case challengeButtonTapped
    }
    
    enum Mutation {
        case setAnalysisResult(MBTIResult?)
        case navigateToChallengeForm
    }
    
    struct State {
        var analysisResult: MBTIResult?
        var recommendedChallenge: String {
            guard let analysisResult else { return "" }
            return "\(analysisResult.category) \(analysisResult.duration) 챌린지(목표: \(analysisResult.spendingLimit.formattedWithComma)원)"
        }
        @Pulse var isNavigatingToChallengeForm: Void?
    }
    
    private let mbtiResultRepository: MBTIResultRepositoryInterface
    
    let initialState: State
    
    init(mbtiResultRepository: MBTIResultRepositoryInterface) {
        self.mbtiResultRepository = mbtiResultRepository
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return mbtiResultRepository.fetchResult()
                .map{ .setAnalysisResult($0) }
            
        case .challengeButtonTapped:
            return .just(.navigateToChallengeForm)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setAnalysisResult(let result):
            newState.analysisResult = result
        case .navigateToChallengeForm:
            newState.isNavigatingToChallengeForm = ()
        }
        return newState
    }
}
