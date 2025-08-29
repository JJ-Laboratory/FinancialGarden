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
    
    private let disposeBag = DisposeBag()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showChallengeList()
    }
    
    // MARK: - Navigation Methods
    
    private func showChallengeList() {
        let challengeListVC = createChallengeViewController()
        navigationController.setViewControllers([challengeListVC], animated: false)
    }
    
    func pushChallengeInput() {
        let challengeInputVC = createChallengeInputViewController()
        challengeInputVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(challengeInputVC, animated: true)
    }
    
    func popChallengeInput() {
        navigationController.popViewController(animated: true)
    }
    
    // MARK: - ViewController Factory Methods
    
    private func createChallengeViewController() -> ChallengeViewController {
        let viewController = ChallengeViewController()
        viewController.coordinator = self
        return viewController
    }
    
    private func createChallengeInputViewController() -> ChallengeInputViewController {
        let viewController = ChallengeInputViewController()
        viewController.coordinator = self
        return viewController
    }
}
