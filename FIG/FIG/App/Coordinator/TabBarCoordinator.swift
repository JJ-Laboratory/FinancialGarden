//
//  TabBarCoordinator.swift
//  FIG
//
//  Created by Milou on 8/28/25.
//

import UIKit

final class TabBarCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: Coordinator?
    
    let tabBarController = UITabBarController()
    
    // navigationController 프로퍼티 제거
    
    func start() {
        setupTabs()
    }

    private func setupTabs() {
        tabBarController.tabBar.backgroundColor = .systemBackground
        tabBarController.tabBar.tintColor = .primary
        
        // 홈 탭
        let homeVC = createHomeViewController()
        let homeNavController = UINavigationController(rootViewController: homeVC)
        homeNavController.tabBarItem = UITabBarItem(
            title: "홈",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        // 가계부 탭
        let transactionVC = RecordListViewController()
        let transactionNavController = UINavigationController(rootViewController: transactionVC)
        let transactionCoordinator = TransactionCoordinator(navigationController: transactionNavController)
        transactionVC.coordinator = transactionCoordinator
        addChildCoordinator(transactionCoordinator)
        
        transactionNavController.tabBarItem = UITabBarItem(
            title: "가계부",
            image: UIImage(systemName: "list.clipboard"),
            selectedImage: UIImage(systemName: "list.clipboard.fill")
        )
        
        // 챌린지 탭
        let challengeVC = ChallengeListViewController(reactor: ChallengeListViewReactor())
        let challengeNavController = UINavigationController(rootViewController: challengeVC)
        let challengeCoordinator = ChallengeCoordinator(navigationController: challengeNavController)
        challengeVC.coordinator = challengeCoordinator
        addChildCoordinator(challengeCoordinator)
        
        challengeNavController.tabBarItem = UITabBarItem(
            title: "챌린지",
            image: UIImage(systemName: "target"),
            selectedImage: UIImage(systemName: "target")
        )
        
        // 차트 탭
        let chartVC = createChartViewController()
        let chartNavController = UINavigationController(rootViewController: chartVC)
        chartNavController.tabBarItem = UITabBarItem(
            title: "차트",
            image: UIImage(systemName: "chart.bar"),
            selectedImage: UIImage(systemName: "chart.bar.fill")
        )
        
        tabBarController.viewControllers = [homeNavController, transactionNavController, challengeNavController, chartNavController]
    }
    
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
