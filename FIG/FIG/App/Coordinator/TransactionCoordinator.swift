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
    
    private let repositoryProvider: RepositoryProviderInterface
    private let disposeBag = DisposeBag()
    
    init(
        navigationController: UINavigationController,
        repositoryProvider: RepositoryProviderInterface = RepositoryProvider.shared
    ) {
        self.navigationController = navigationController
        self.repositoryProvider = repositoryProvider
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
    
    func pushTransactionEdit(transaction: Transaction) {
        let recordFormVC = createRecordFormViewController(editingTransaction: transaction)
        recordFormVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(recordFormVC, animated: true)
    }
    
    // MARK: - ViewController Factory Methods
    
    private func createRecordListViewController() -> RecordListViewController {
        let reactor = RecordListReactor(
            transactionRepository: repositoryProvider.transactionRepository
        )
        let viewController = RecordListViewController(reactor: reactor)
        viewController.coordinator = self
        return viewController
    }
    
    private func createRecordFormViewController(editingTransaction: Transaction? = nil) -> RecordFormViewController {
        let reactor = RecordFormReactor(
            transactionRepository: repositoryProvider.transactionRepository,
            gardenRepository: repositoryProvider.gardenRepository,
            editingRecord: editingTransaction
        )
        let viewController = RecordFormViewController(reactor: reactor)
        viewController.coordinator = self
        return viewController
    }
}
