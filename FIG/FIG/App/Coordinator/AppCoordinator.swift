//
//  AppCoordinator.swift
//  FIG
//
//  Created by Milou on 8/28/25.
//

import UIKit

final class AppCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: Coordinator?

    private let window: UIWindow
    private let viewControllerFactory: ViewControllerFactoryInterface

    init(window: UIWindow) {
        self.window = window
        self.viewControllerFactory = ViewControllerFactory()
        self.navigationController = UINavigationController()
    }

    func start() {
        startTabBarFlow()
    }

    private func startTabBarFlow() {
        let tabBarCoordinator = TabBarCoordinator(
            viewControllerFactory: viewControllerFactory
        )
        addChildCoordinator(tabBarCoordinator)

        window.rootViewController = tabBarCoordinator.tabBarController
        window.makeKeyAndVisible()

        tabBarCoordinator.start()
    }
}
