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
        let homeNav = UINavigationController()
        let homeVC = createHomeViewController()
        homeNav.setViewControllers([homeVC], animated: false)
        homeNav.tabBarItem = UITabBarItem(
            title: "홈",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        // 가계부 탭
        let transactionNav = UINavigationController()
        let transactionCoordinator = TransactionCoordinator(navigationController: transactionNav)
        addChildCoordinator(transactionCoordinator)
        transactionCoordinator.start()
        transactionNav.tabBarItem = UITabBarItem(
            title: "가계부",
            image: UIImage(systemName: "list.clipboard"),
            selectedImage: UIImage(systemName: "list.clipboard.fill")
        )
        
        // 챌린지 탭
        let challengeNav = UINavigationController()
        let challengeCoordinator = ChallengeCoordinator(navigationController: challengeNav)
        addChildCoordinator(challengeCoordinator)
        challengeCoordinator.start()
        challengeNav.tabBarItem = UITabBarItem(
            title: "챌린지",
            image: UIImage(systemName: "target"),
            selectedImage: UIImage(systemName: "target")
        )
        
        // 차트 탭
        let chartNav = UINavigationController()
        let chartVC = createChartViewController()
        chartNav.setViewControllers([chartVC], animated: false)
        chartNav.tabBarItem = UITabBarItem(
            title: "차트",
            image: UIImage(systemName: "chart.bar"),
            selectedImage: UIImage(systemName: "chart.bar.fill")
        )
        
        tabBarController.viewControllers = [homeNav, transactionNav, challengeNav, chartNav]
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
