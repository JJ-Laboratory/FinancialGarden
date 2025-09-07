//
//  ChallengeCoordinator.swift
//  FIG
//
//  Created by Milou on 8/28/25.
//

import UIKit
import RxSwift
import RxCocoa

final class ChallengeCoordinator: Coordinator, ChallengeCoordinatorProtocol {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: Coordinator?
    
    private let viewControllerFactory: ViewControllerFactoryInterface
    private let disposeBag = DisposeBag()
    
    init(
        navigationController: UINavigationController,
        viewControllerFactory: ViewControllerFactoryInterface
    ) {
        self.navigationController = navigationController
        self.viewControllerFactory = viewControllerFactory
    }
    
    func start() {
        showChallengeList()
    }
    
    // MARK: - Navigation Methods
    
    private func showChallengeList() {}
    
    func pushChallengeForm() {
        let challengeFormVC = viewControllerFactory.makeChallengeFormViewController(mode: .create)
        challengeFormVC.coordinator = self
        challengeFormVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(challengeFormVC, animated: true)
    }
    
    func pushChallengeDetail(challenge: Challenge) {
        let challengeDetailVC = viewControllerFactory.makeChallengeFormViewController(mode: .detail(challenge))
        challengeDetailVC.coordinator = self
        challengeDetailVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(challengeDetailVC, animated: true)
    }
    
    func popChallengeForm() {
        navigationController.popViewController(animated: true)
    }
}
