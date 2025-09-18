//
//  AnalysisCoordinator.swift
//  FIG
//
//  Created by Milou on 9/18/25.
//

import UIKit

protocol AnalysisCoordinatorProtocol: AnyObject {
    func pushAnalysisResult()
    func popAnalysis()
    func requestChallengeForm(result: MBTIResult)
    func dismiss()
}


final class AnalysisCoordinator: Coordinator, AnalysisCoordinatorProtocol {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: Coordinator?
    
    private var viewControllerFactory: ViewControllerFactoryInterface
    
    init(navigationController: UINavigationController,
         viewControllerFactory: ViewControllerFactoryInterface) {
        self.navigationController = navigationController
        self.viewControllerFactory = viewControllerFactory
    }
    
    func start() {
        showAnalysis()
    }
    
    func showAnalysis() {
        let analysisVC = viewControllerFactory.makeAnalysisViewController()
        analysisVC.coordinator = self
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.setViewControllers([analysisVC], animated: true)
    }
    
    func pushAnalysisResult() {
        let analysisResultVC = viewControllerFactory.makeAnalysisResultViewController()
        analysisResultVC.coordinator = self
        navigationController.pushViewController(analysisResultVC, animated: true)
    }
    
    func popAnalysis() {
        navigationController.popViewController(animated: true)
    }
    
    func requestChallengeForm(result: MBTIResult) {
        (parentCoordinator as? ChartCoordinator)?.handleChallengeFormRequest(result)
        navigationController.presentingViewController?.dismiss(animated: false)
    }
    
    func dismiss() {
        navigationController.presentingViewController?.dismiss(animated: true)
    }
}
