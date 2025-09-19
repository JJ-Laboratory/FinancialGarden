//
//  ChallengeCoordinator.swift
//  FIG
//
//  Created by Milou on 8/28/25.
//

import UIKit

protocol ChallengeCoordinatorProtocol: AnyObject {
    func pushChallengeForm(completion: ((ChallengeDuration) -> Void)?)
    func pushChallengeDetail(challenge: Challenge)
    func pushChallengeEdit(result: MBTIResult)
    func popChallengeForm()
}

final class ChallengeCoordinator: Coordinator, ChallengeCoordinatorProtocol {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: Coordinator?
    
    private let viewControllerFactory: ViewControllerFactoryInterface
    
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
    
    private func showChallengeList() {
        let challengeListVC = viewControllerFactory.makeChallengeListViewController()
        challengeListVC.coordinator = self
        navigationController.setViewControllers([challengeListVC], animated: true)
    }
    
    func pushChallengeForm(completion: ((ChallengeDuration) -> Void)? = nil) {
        let challengeFormVC = viewControllerFactory.makeChallengeFormViewController(mode: .create)
        challengeFormVC.onChallengeCreated = completion
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
    
    func pushChallengeEdit(result: MBTIResult) {
        let challengeDetailVC = viewControllerFactory.makeChallengeFormViewController(mode: .edit(result))
        challengeDetailVC.coordinator = self
        challengeDetailVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(challengeDetailVC, animated: true)
    }
    
    func popChallengeForm() {
        navigationController.popViewController(animated: true)
    }
}
