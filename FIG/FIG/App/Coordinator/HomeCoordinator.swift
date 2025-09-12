//
//  HomeCoordinator.swift
//  FIG
//
//  Created by Milou on 9/7/25.
//

import UIKit

final class HomeCoordinator: Coordinator {
    
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
        showHome()
    }
    
    private func showHome() {
        let homeVC = viewControllerFactory.makeHomeViewController()
        if let homeReactor = homeVC.reactor {
            homeReactor.coordinator = parentCoordinator as? TabBarCoordinatorProtocol
        }
        navigationController.setViewControllers([homeVC], animated: true)
    }
}
