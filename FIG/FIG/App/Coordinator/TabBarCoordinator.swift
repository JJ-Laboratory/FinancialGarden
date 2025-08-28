//
//  TabBarCoordinator.swift
//  FIG
//
//  Created by Milou on 8/28/25.
//

import UIKit

final class TabBarCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: Coordinator?
    
    private let tabBarController = UITabBarController()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        setupTabs()
        navigationController.setViewControllers([tabBarController], animated: false)
    }

    private func setupTabs() {
        tabBarController.tabBar.backgroundColor = .systemBackground
        tabBarController.tabBar.tintColor = .primary
        
        // 홈 탭
        let homeVC = createHomeViewController()
        homeVC.tabBarItem = UITabBarItem(
            title: "홈",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        // 가계부 탭
        let transactionVC = TransactionViewController()
        let transactionCoordinator = TransactionCoordinator(navigationController: navigationController)
        transactionVC.coordinator = transactionCoordinator
        addChildCoordinator(transactionCoordinator)
        
        transactionVC.tabBarItem = UITabBarItem(
            title: "가계부",
            image: UIImage(systemName: "list.clipboard"),
            selectedImage: UIImage(systemName: "list.clipboard.fill")
        )
        
        // 챌린지 탭
        let challengeVC = ChallengeViewController()
        let challengeCoordinator = ChallengeCoordinator(navigationController: navigationController)
        addChildCoordinator(challengeCoordinator)
        challengeCoordinator.start()
        challengeVC.tabBarItem = UITabBarItem(
            title: "챌린지",
            image: UIImage(systemName: "target"),
            selectedImage: UIImage(systemName: "target")
        )
        
        // 차트 탭
        let chartVC = createChartViewController()
        chartVC.tabBarItem = UITabBarItem(
            title: "차트",
            image: UIImage(systemName: "chart.bar"),
            selectedImage: UIImage(systemName: "chart.bar.fill")
        )
        
        tabBarController.viewControllers = [homeVC, transactionVC, challengeVC, chartVC]
    }
    
    // 임시 ViewController
    private func createHomeViewController() -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .lightPink
        vc.title = "홈"
        return vc
    }
    
    private func createChartViewController() -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .lightBlue
        vc.title = "차트"
        return vc
    }
}
