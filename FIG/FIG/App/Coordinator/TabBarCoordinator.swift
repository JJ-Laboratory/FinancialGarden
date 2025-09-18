//
//  TabBarCoordinator.swift
//  FIG
//
//  Created by Milou on 8/28/25.
//

import UIKit

protocol TabBarCoordinatorProtocol: AnyObject {
    func selectTab(for section: HomeSection)
    func navigateToFormScreen(type: EmptyStateType)
    func navigateToChallenge(with result: MBTIResult)
}

final class TabBarCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: Coordinator?
    
    let tabBarController = UITabBarController()
    private let viewControllerFactory: ViewControllerFactoryInterface
    
    init(viewControllerFactory: ViewControllerFactoryInterface) {
        self.viewControllerFactory = viewControllerFactory
    }
    
    func start() {
        setupTabs()
    }
    
    private func setupTabs() {
        tabBarController.tabBar.backgroundColor = .white
        tabBarController.tabBar.tintColor = .primary
        
        // 홈 탭
        let homeNavController = NavigationController()
        let homeCoordinator = HomeCoordinator(
            navigationController: homeNavController,
            viewControllerFactory: viewControllerFactory
        )
        addChildCoordinator(homeCoordinator)
        homeCoordinator.start()
        homeNavController.tabBarItem = UITabBarItem(
            title: "홈",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        // 가계부 탭
        let recordNavController = NavigationController()
        let recordCoordinator = RecordCoordinator(
            navigationController: recordNavController,
            viewControllerFactory: viewControllerFactory
        )
        addChildCoordinator(recordCoordinator)
        recordCoordinator.start()
        recordNavController.tabBarItem = UITabBarItem(
            title: "가계부",
            image: UIImage(systemName: "list.clipboard"),
            selectedImage: UIImage(systemName: "list.clipboard.fill")
        )
        
        // 챌린지 탭
        let challengeNavController = NavigationController()
        let challengeCoordinator = ChallengeCoordinator(
            navigationController: challengeNavController,
            viewControllerFactory: viewControllerFactory
        )
        challengeCoordinator.parentCoordinator = self
        addChildCoordinator(challengeCoordinator)
        challengeCoordinator.start()
        challengeNavController.tabBarItem = UITabBarItem(
            title: "챌린지",
            image: UIImage(systemName: "apple.meditate"),
            selectedImage: UIImage(systemName: "apple.meditate")
        )
        
        // 차트 탭
        let chartNavController = NavigationController()
        let chartCoordinator = ChartCoordinator(
            navigationController: chartNavController,
            viewControllerFactory: viewControllerFactory
        )
        chartCoordinator.parentCoordinator = self
        addChildCoordinator(chartCoordinator)
        chartCoordinator.start()
        chartNavController.tabBarItem = UITabBarItem(
            title: "차트",
            image: UIImage(systemName: "chart.bar"),
            selectedImage: UIImage(systemName: "chart.bar.fill")
        )
        
        tabBarController.viewControllers = [
            homeNavController,
            recordNavController,
            challengeNavController,
            chartNavController
        ]
    }
}

extension TabBarCoordinator: TabBarCoordinatorProtocol {
    func selectTab(for section: HomeSection) {
        tabBarController.selectedIndex = section.tabIndex
    }
    
    func navigateToFormScreen(type: EmptyStateType) {
        switch type {
        case .transaction:
            navigateToRecordForm()
        case .challenge, .week, .month:
            navigateToChallengeForm()
        case .completed:
            return
        }
    }
    
    private func selectTab(at index: Int) {
        guard index >= 0 && index < tabBarController.viewControllers?.count ?? 0 else {
            return
        }
        
        tabBarController.selectedIndex = index
    }
    
    private func navigateToRecordForm() {
        selectTab(at: 1)
        
        if let recordCoordinator = childCoordinators.first(where: { $0 is RecordCoordinator }) as? RecordCoordinator {
            recordCoordinator.pushRecordForm()
        }
    }
    
    private func navigateToChallengeForm() {
        selectTab(at: 2)
        
        if let challengeCoordinator = childCoordinators.first(where: { $0 is ChallengeCoordinator }) as? ChallengeCoordinator {
            challengeCoordinator.pushChallengeForm()
        }
    }
    
    func navigateToChallenge(with result: MBTIResult) {
        selectTab(at: 2)
        
        if let challengeCoordinator = childCoordinators.first(where: { $0 is ChallengeCoordinator }) as? ChallengeCoordinator {
            challengeCoordinator.pushChallengeEdit(result: result)
        }
    }
}
