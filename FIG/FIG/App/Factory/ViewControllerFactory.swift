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
    
    // MARK: - ViewController 생성 메서드들
    
    func makeHomeViewController() -> HomeViewController {
        let reactor = HomeReactor(
            transactionRepository: transactionRepository,
            challengeRepository: challengeRepository,
            categoryService: .shared
        )
        return HomeViewController(reactor: reactor)
    }
    
    func makeRecordListViewController() -> RecordListViewController {
        let reactor = RecordListReactor(
            transactionRepository: transactionRepository
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
            challengeRepository: challengeRepository,
            gardenRepository: gardenRepository,
            transactionRepository: transactionRepository
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
            transactionRepository: transactionRepository
        )
        return ChartViewController(reactor: reactor)
    }
}
