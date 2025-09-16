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
    }
    
    enum Mutation {
        case setAnalysisResult(MBTIResult?)
    }
    
    struct State {
        var analysisResult: MBTIResult?
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
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setAnalysisResult(let result):
            newState.analysisResult = result
        }
        return newState
    }
}
