//
//  ChartCoordinator.swift
//  FIG
//
//  Created by Milou on 9/7/25.
//

import UIKit

protocol ChartCoordinatorProtocol: AnyObject {
    func presentAnalysis()
    func handleChallengeFormRequest(_ result: MBTIResult)
}

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
    
    func presentAnalysis() {
        let analysisNavController = UINavigationController()
        let analysisCoordinator = AnalysisCoordinator(
            navigationController: analysisNavController,
            viewControllerFactory: viewControllerFactory
        )
        
        addChildCoordinator(analysisCoordinator)
        analysisCoordinator.parentCoordinator = self
        analysisCoordinator.start()
        
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.present(analysisNavController, animated: true)
    }
    
    func handleChallengeFormRequest(_ result: MBTIResult) {
        if let tabBarcoordinator = parentCoordinator as? TabBarCoordinatorProtocol {
            tabBarcoordinator.navigateToChallenge(with: result)
        }
    }
}
