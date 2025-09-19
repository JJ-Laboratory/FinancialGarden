//
//  RecordCoordinator.swift
//  FIG
//
//  Created by Milou on 8/28/25.
//

import UIKit
import RxSwift
import RxCocoa

protocol RecordCoordinatorProtocol: AnyObject {
    func pushRecordForm()
    func popRecordForm()
    func pushRecordFormEdit(transaction: Transaction)
}

final class RecordCoordinator: Coordinator, RecordCoordinatorProtocol {
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
        showRecordList()
    }
    
    // MARK: - Navigation Methods
    
    private func showRecordList() {
        let recordListVC =
        viewControllerFactory.makeRecordListViewController()
        recordListVC.coordinator = self
        navigationController.setViewControllers([recordListVC], animated: true)
    }
    
    func pushRecordForm() {
        let recordFormVC = viewControllerFactory.makeRecordFormViewController(editingRecord: nil)
        recordFormVC.coordinator = self
        recordFormVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(recordFormVC, animated: true)
    }
    
    func pushRecordFormEdit(transaction: Transaction) {
        let recordFormVC = viewControllerFactory.makeRecordFormViewController(editingRecord: transaction)
        recordFormVC.coordinator = self
        recordFormVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(recordFormVC, animated: true)
    }
    
    func popRecordForm() {
        navigationController.popViewController(animated: true)
    }
}
