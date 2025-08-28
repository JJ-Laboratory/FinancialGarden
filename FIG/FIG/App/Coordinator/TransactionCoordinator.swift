//
//  TransactionCoordinator.swift
//  FIG
//
//  Created by Milou on 8/28/25.
//

import UIKit
import RxSwift
import RxCocoa

final class TransactionCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: Coordinator?
    
    private let disposeBag = DisposeBag()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showTransactionList()
    }
    
    // MARK: - Navigation Methods
    
    private func showTransactionList() {
        let transactiontVC = createTransactionViewController()
//        navigationController.setViewControllers([transactiontVC], animated: false)
    }
    
    func pushTransactionInput() {
        let recordFormVC = createRecordFormViewController()
        navigationController.pushViewController(recordFormVC, animated: true)
    }
    
    func popTransactionInput() {
        navigationController.popViewController(animated: true)
    }
    
    // MARK: - ViewController Factory Methods
    
    private func createTransactionViewController() -> RecordListViewController {
        let viewController = RecordListViewController()
        viewController.coordinator = self
        return viewController
    }
    
    private func createRecordFormViewController() -> RecordFormViewController {
        let viewController = RecordFormViewController()
        viewController.coordinator = self
        return viewController
    }
}
