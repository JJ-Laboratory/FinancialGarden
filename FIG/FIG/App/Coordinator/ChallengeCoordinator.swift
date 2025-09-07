//
//  ChallengeCoordinator.swift
//  FIG
//
//  Created by Milou on 8/28/25.
//

import UIKit
import RxSwift
import RxCocoa

final class ChallengeCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: Coordinator?
    
    private let repositoryProvider: RepositoryProviderInterface
    private let disposeBag = DisposeBag()
    
    init(navigationController: UINavigationController,
         repositoryProvider: RepositoryProviderInterface = RepositoryProvider.shared
    ) {
        self.navigationController = navigationController
        self.repositoryProvider = repositoryProvider
    }
    
    func start() {
        showChallengeList()
    }
    
    // MARK: - Navigation Methods
    
    private func showChallengeList() {
        _ = createChallengeViewController()
    }
    
    func pushChallengeInput() {
        let challengeInputVC = createChallengeFormViewController()
        challengeInputVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(challengeInputVC, animated: true)
    }
    
    func pushChallengeDetail(challenge: Challenge) {
        let challengeDetailVC = createChallengeDetailViewController(challenge: challenge)
        challengeDetailVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(challengeDetailVC, animated: true)
    }
    
    func popChallengeInput() {
        navigationController.popViewController(animated: true)
    }
    
    // MARK: - ViewController Factory Methods
    
    private func createChallengeViewController() -> ChallengeListViewController {
        let reator = ChallengeListReactor(
            challengeRepository: repositoryProvider.challengeRepository,
            gardenRepository: repositoryProvider.gardenRepository,
            transactionRepository: repositoryProvider.transactionRepository
        )
        let viewController = ChallengeListViewController(reactor: reator)
        viewController.coordinator = self
        return viewController
    }
    
    private func createChallengeFormViewController() -> ChallengeFormViewController {
        let reator = ChallengeFormReactor(
            mode: .create,
            challengeRepository: repositoryProvider.challengeRepository,
            gardenRepository: repositoryProvider.gardenRepository)
        let viewController = ChallengeFormViewController(reactor: reator)
        viewController.coordinator = self
        return viewController
    }
    
    private func createChallengeDetailViewController(challenge: Challenge) -> ChallengeFormViewController {
        let reator = ChallengeFormReactor(
            mode: .detail(challenge),
            challengeRepository: repositoryProvider.challengeRepository,
            gardenRepository: repositoryProvider.gardenRepository
        )
        let viewController = ChallengeFormViewController(reactor: reator)
        viewController.coordinator = self
        return viewController
    }
}
