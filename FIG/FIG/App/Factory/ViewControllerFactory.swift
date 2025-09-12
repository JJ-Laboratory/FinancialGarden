//
//  ViewControllerFactory.swift
//  FIG
//
//  Created by Milou on 9/7/25.
//

import UIKit

protocol ViewControllerFactoryInterface {
    func makeHomeViewController() -> HomeViewController
    func makeRecordListViewController() -> RecordListViewController
    func makeRecordFormViewController(editingRecord: Transaction?) -> RecordFormViewController
    func makeChallengeListViewController() -> ChallengeListViewController
    func makeChallengeFormViewController(mode: ChallengeFormReactor.Mode) -> ChallengeFormViewController
    func makeChartViewController() -> ChartViewController
    func makeAnalysisViewController() -> AnalysisViewController
    func makeAnalysisResultViewController() -> AnalysisResultViewController
}

final class ViewControllerFactory: ViewControllerFactoryInterface {
    
    private lazy var transactionRepository: TransactionRepositoryInterface = {
        TransactionRepository(
            coreDataService: .shared,
            categoryService: .shared
        )
    }()
    
    private lazy var challengeRepository: ChallengeRepositoryInterface = {
        ChallengeRepository(
            coreDataService: .shared,
            categoryService: .shared
        )
    }()
    
    private lazy var gardenRepository: GardenRepositoryInterface = {
        GardenRepository(
            coreDataService: .shared
        )
    }()
    
    private lazy var recordUseCase = RecordUseCase(
        transactionRepository: transactionRepository
    )
    
    private lazy var challengeUseCase = ChallengeUseCase(
        challengeRepository: challengeRepository,
        transactionRepository: transactionRepository
    )
    
    // MARK: - ViewController 생성 메서드들
    
    func makeHomeViewController() -> HomeViewController {
        let reactor = HomeReactor(
            recordUseCase: recordUseCase,
            challengeUseCase: challengeUseCase
        )
        return HomeViewController(reactor: reactor)
    }
    
    func makeRecordListViewController() -> RecordListViewController {
        let reactor = RecordListReactor(
            transactionRepository: transactionRepository, recordUseCase: recordUseCase
        )
        return RecordListViewController(reactor: reactor)
    }
    
    func makeRecordFormViewController(editingRecord: Transaction? = nil) -> RecordFormViewController {
        let reactor = RecordFormReactor(
            transactionRepository: transactionRepository,
            gardenRepository: gardenRepository,
            editingRecord: editingRecord
        )
        return RecordFormViewController(reactor: reactor)
    }
    
    func makeChallengeListViewController() -> ChallengeListViewController {
        let reactor = ChallengeListReactor(
            challengeUseCase: challengeUseCase,
            challengeRepository: challengeRepository,
            gardenRepository: gardenRepository
        )
        return ChallengeListViewController(reactor: reactor)
    }
    
    func makeChallengeFormViewController(mode: ChallengeFormReactor.Mode) -> ChallengeFormViewController {
        let reactor = ChallengeFormReactor(
            mode: mode,
            challengeRepository: challengeRepository,
            gardenRepository: gardenRepository
        )
        return ChallengeFormViewController(reactor: reactor)
    }
    
    func makeChartViewController() -> ChartViewController {
        let reactor = ChartReactor(
            recordUseCase: recordUseCase
        )
        return ChartViewController(reactor: reactor)
    }
    
    
    func makeAnalysisViewController() -> AnalysisViewController {
        return AnalysisViewController()
    }
    
    func makeAnalysisResultViewController() -> AnalysisResultViewController {
        return AnalysisResultViewController()
    }
}
