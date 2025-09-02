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
        let reator = ChallengeListViewReactor(challengeRepository: ChallengeRepository(), gardenRepository: GardenRepository())
        let viewController = ChallengeListViewController(reactor: reator)
        viewController.coordinator = self
        return viewController
    }
    
    private func createChallengeFormViewController() -> ChallengeFormViewController {
        let reator = ChallengeFormViewReactor(mode: .create, challengeRepository: ChallengeRepository(), gardenRepository: GardenRepository())
        let viewController = ChallengeFormViewController(reactor: reator)
        viewController.coordinator = self
        return viewController
    }
    
    private func createChallengeDetailViewController(challenge: Challenge) -> ChallengeFormViewController {
        let reator = ChallengeFormViewReactor(mode: .detail(challenge), challengeRepository: ChallengeRepository(), gardenRepository: GardenRepository())
        let viewController = ChallengeFormViewController(reactor: reator)
        viewController.coordinator = self
        return viewController
    }
}
