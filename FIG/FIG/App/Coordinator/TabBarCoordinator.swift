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
    
    func start() {
        setupTabs()
    }
    
    private func setupTabs() {
        tabBarController.tabBar.backgroundColor = .systemBackground
        tabBarController.tabBar.tintColor = .primary
        
        // 홈 탭
        let homeReactor = HomeViewReactor(
            transactionRepository: TransactionRepository(),
            challengeRepository: ChallengeRepository()
        )
        homeReactor.coordinator = self
        let homeVC = HomeViewController(reactor: homeReactor)
        let homeNavController = UINavigationController(rootViewController: homeVC)
        homeNavController.tabBarItem = UITabBarItem(
            title: "홈",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        // 가계부 탭
        let transactionNavController = UINavigationController()
        let transactionCoordinator = TransactionCoordinator(navigationController: transactionNavController)
        addChildCoordinator(transactionCoordinator)
        
        transactionCoordinator.start()
        
        transactionNavController.tabBarItem = UITabBarItem(
            title: "가계부",
            image: UIImage(systemName: "list.clipboard"),
            selectedImage: UIImage(systemName: "list.clipboard.fill")
        )
        
        // 챌린지 탭
        let reactor = ChallengeListViewReactor(challengeRepository: ChallengeRepository(), gardenRepository: GardenRepository(), transactionRepository: TransactionRepository())
        let challengeVC = ChallengeListViewController(reactor: reactor)
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
        let chartVC = ChartViewController()
        let chartNavController = UINavigationController(rootViewController: chartVC)
        chartNavController.tabBarItem = UITabBarItem(
            title: "차트",
            image: UIImage(systemName: "chart.bar"),
            selectedImage: UIImage(systemName: "chart.bar.fill")
        )
        
        tabBarController.viewControllers = [homeNavController, transactionNavController, challengeNavController, chartNavController]
    }
    
    func selectTab(for section: HomeSection) {
        selectTab(at: section.tabIndex)
    }
    
    private func selectTab(at index: Int) {
        guard index >= 0 && index < tabBarController.viewControllers?.count ?? 0 else {
            print("Invalid tab index: \(index)")
            return
        }
        
        tabBarController.selectedIndex = index
    }
    
    func navigateToFormScreen(type: EmptyStateType) {
        switch type {
        case .transaction:
            navigateToRecordForm()
        case .challenge, .week, .month:
            navigateToChallengeForm()
        }
    }
    
    private func navigateToRecordForm() {
        selectTab(at: 1)
        
        if let transactionCoordinator = childCoordinators.first(where: { $0 is TransactionCoordinator }) as? TransactionCoordinator {
            transactionCoordinator.pushTransactionInput()
        }
    }
    
    private func navigateToChallengeForm() {
        selectTab(at: 2)
        
        if let challengeCoordinator = childCoordinators.first(where: { $0 is ChallengeCoordinator }) as? ChallengeCoordinator {
            challengeCoordinator.pushChallengeInput()
        }
    }
}
