//
//  ChartCoordinator.swift
//  FIG
//
//  Created by Milou on 9/7/25.
//

import UIKit

final class ChartCoordinator: Coordinator {
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
        showChart()
    }
    
    private func showChart() {
        let chartVC = viewControllerFactory.makeChartViewController()
        chartVC.coordinator = self
        navigationController.setViewControllers([chartVC], animated: false)
    }
}
