//
//  AnalysisReactor.swift
//  FIG
//
//  Created by estelle on 9/16/25.
//

import RxSwift
import ReactorKit
import Foundation

class AnalysisReactor: Reactor {
    
    enum Action {
        case viewDidLoad
        case resultButtonTapped
        case analyzeButtonTapped
        case analysisStarted
    }
    
    enum Mutation {
        case setResultButtonHidden(Bool)
        case setAlertMessage(String)
        case showStartAlert
        case setLoading(Bool)
        case showResultScreen
    }
    
    struct State {
        var isResultButtonHidden: Bool = true
        var isLoading: Bool = false
        @Pulse var alertMessage: String?
        @Pulse var isShowStartAlert: Bool?
        @Pulse var isShowResultScreen: Bool?
    }
    
    private let mbtiResultRepository: MBTIResultRepositoryInterface
    private let gardenRepository: GardenRepositoryInterface
    private let transactionRepository: TransactionRepositoryInterface
    
    let initialState: State
    
    init(
        mbtiResultRepository: MBTIResultRepositoryInterface,
        gardenRepository: GardenRepositoryInterface,
        transactionRepository: TransactionRepositoryInterface
    ) {
        self.mbtiResultRepository = mbtiResultRepository
        self.gardenRepository = gardenRepository
        self.transactionRepository = transactionRepository
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        let now = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        
        switch action {
        case .viewDidLoad:
            return mbtiResultRepository.fetchResult()
                .map { result in
                    let isHidden = (result == nil)
                    return .setResultButtonHidden(isHidden)
                }
            
        case .resultButtonTapped:
            return .just(.showResultScreen)
            
        case .analyzeButtonTapped:
            let transactions = transactionRepository.fetchTransactionByMonth(year, month)
            let gardenInfo = gardenRepository.fetchGardenRecord()
            
            return Observable.zip(transactions, gardenInfo)
                .map { transactions, gardenInfo -> Mutation in
                    let expenses = transactions.filter { $0.category.transactionType == .expense }
                    if expenses.count < 10 {
                        return .setAlertMessage("분석을 위해 이번 달 거래 내역이 최소 10개 이상 필요해요\n가계부에 거래 내역을 추가해주세요!")
                    } else if gardenInfo.totalFruits < 1 {
                        return .setAlertMessage("분석을 위해 열매 1개가 필요해요\n챌린지를 성공해 열매를 모아보세요!")
                    } else {
                        return .showStartAlert
                    }
                }
            
        case .analysisStarted:
            let startLoading: Observable<Mutation> = .just(.setLoading(true))
            let endLoading: Observable<Mutation> = .just(.setLoading(false))
            
            let analysisProcess = mbtiAnalysis(year: year, month: month)
                .map { _ in Mutation.showResultScreen }
                .catch { error in .just(.setAlertMessage(error.localizedDescription)) }
            
            return .concat([startLoading, analysisProcess, endLoading])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setResultButtonHidden(let isHidden):
            newState.isResultButtonHidden = isHidden
        case .showResultScreen:
            newState.isShowResultScreen = true
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        case .setAlertMessage(let message):
            newState.alertMessage = message
        case .showStartAlert:
            newState.isShowStartAlert = true
        }
        return newState
    }
    
    private func mbtiAnalysis(year: Int, month: Int) -> Observable<MBTIResult> {
        gardenRepository.add(seeds: 0, fruits: -1)
            .flatMap { [weak self] _ -> Observable<[Transaction]> in
                guard let self else { return .empty() }
                return transactionRepository.fetchTransactionByMonth(year, month)
            }
            .flatMap { [weak self] transactions -> Observable<MBTIResult> in
                guard let self else { return .empty() }
                
                let expenses = transactions.filter { $0.category.transactionType == .expense }
                let spendingsByCategory = Dictionary(grouping: expenses, by: { $0.category })
                    .mapValues { $0.reduce(0) { $0 + $1.amount } }
                
                let aiInput = spendingsByCategory.map { category, amount in
                    "\(category.title): \(amount.formattedWithComma)원"
                }
                
                let aiResult = Single<MBTIResult>.create { single in
                    Task {
                        do {
                            guard let result = try await AIMbtiParser.shared.parseMbti(aiInput) else {
                                single(.failure(AIParsingError.noDataFound))
                                return
                            }
                            single(.success(result))
                        } catch {
                            single(.failure(error))
                        }
                    }
                    return Disposables.create()
                }.asObservable()
                
                return aiResult
                    .flatMap { result in
                        self.mbtiResultRepository.saveOrUpdateResult(result)
                    }
            }
    }
}
