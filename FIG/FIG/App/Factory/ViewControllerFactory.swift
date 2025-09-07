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
    
    private let repositoryProvider: RepositoryProviderInterface
    
    init(repositoryProvider: RepositoryProviderInterface) {
        self.repositoryProvider = repositoryProvider
    }
    
    func makeHomeViewController() -> HomeViewController {
        let reactor = HomeReactor(
            transactionRepository: repositoryProvider.transactionRepository,
            challengeRepository: repositoryProvider.challengeRepository,
            categoryService: .shared
        )
        return HomeViewController(reactor: reactor)
    }
    
    func makeRecordListViewController() -> RecordListViewController {
        let reactor = RecordListReactor(
            transactionRepository: repositoryProvider.transactionRepository
        )
        return RecordListViewController(reactor: reactor)
    }
    
    func makeRecordFormViewController(editingRecord:
                                      Transaction? = nil) -> RecordFormViewController {
        let reactor = RecordFormReactor(
            transactionRepository: repositoryProvider.transactionRepository,
            gardenRepository: repositoryProvider.gardenRepository,
            editingRecord: editingRecord
        )
        return RecordFormViewController(reactor: reactor)
    }
    
    func makeChallengeListViewController() -> ChallengeListViewController {
        let reactor = ChallengeListReactor(
            challengeRepository: repositoryProvider.challengeRepository,
            gardenRepository: repositoryProvider.gardenRepository,
            transactionRepository: repositoryProvider.transactionRepository
        )
        return ChallengeListViewController(reactor: reactor)
    }
    
    func makeChallengeFormViewController(mode: ChallengeFormReactor.Mode) ->
    ChallengeFormViewController {
        let reactor = ChallengeFormReactor(
            mode: mode,
            challengeRepository: repositoryProvider.challengeRepository,
            gardenRepository: repositoryProvider.gardenRepository
        )
        return ChallengeFormViewController(reactor: reactor)
    }
    
    func makeChartViewController() -> ChartViewController {
        let reactor = ChartReactor(
            transactionRepository: repositoryProvider.transactionRepository
        )
        return ChartViewController(reactor: reactor)
    }
}
