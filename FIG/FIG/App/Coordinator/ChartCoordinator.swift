//
//  ChartCoordinator.swift
//  FIG
//
//  Created by Milou on 9/7/25.
//

import UIKit

final class ChartCoordinator: Coordinator, ChartCoordinatorProtocol {
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
    
    // MARK: - Navigation Methods
    
    private func showChart() {
        let chartVC = viewControllerFactory.makeChartViewController()
        chartVC.coordinator = self
        navigationController.setViewControllers([chartVC], animated: true)
    }
    
    func pushAnalysis() {
        let analysisVC = viewControllerFactory.makeAnalysisViewController()
        analysisVC.coordinator = self
        analysisVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(analysisVC, animated: true)
    }
    
    func pushAnalysisResult() {
        let analysisResultVC = viewControllerFactory.makeAnalysisResultViewController()
        analysisResultVC.coordinator = self
        analysisResultVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(analysisResultVC, animated: true)
    }
    
    func popAnalysis() {
        navigationController.popViewController(animated: true)
    }
}
