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
        let recordListVC = createRecordListViewController()
        navigationController.setViewControllers([recordListVC], animated: false)
    }
    
    func pushTransactionInput() {
        let recordFormVC = createRecordFormViewController()
        recordFormVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(recordFormVC, animated: true)
    }
    
    func popTransactionInput() {
        navigationController.popViewController(animated: true)
    }
    
    // MARK: - ViewController Factory Methods
    
    private func createRecordListViewController() -> RecordListViewController {
        let reactor = RecordListReactor()
        let viewController = RecordListViewController(reactor: reactor)
        viewController.coordinator = self
        return viewController
    }
    
    private func createRecordFormViewController() -> RecordFormViewController {
        let reactor = RecordFormReactor()
        let viewController = RecordFormViewController(reactor: reactor)
        viewController.coordinator = self
        return viewController
    }
}
