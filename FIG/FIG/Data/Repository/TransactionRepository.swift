//
//  TransactionRepository.swift
//  FIG
//
//  Created by Milou on 8/22/25.
//

import Foundation
import RxSwift
import CoreData
import OSLog

final class TransactionRepository: TransactionRepositoryInterface {
    
    private let coreDataService: CoreDataService
    private let categoryService: CategoryService
    private let logger = Logger.transaction
    
    init(
        coreDataService: CoreDataService = .shared,
        categoryService: CategoryService = .shared
    ) {
        self.coreDataService = coreDataService
        self.categoryService = categoryService
    }
    
    func saveTransaction(_ transaction: Transaction) -> Observable<Transaction> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(CoreDataError.contextNotAvailable)
                return Disposables.create()
            }
            
            let context = coreDataService.mainContext
            let entity = TransactionEntity(context: context)
            
            entity.id = transaction.id
            entity.amount = Int32(transaction.amount)
            entity.title = transaction.title
            entity.paymentMethod = transaction.payment.rawValue
            entity.categoryID = transaction.category.id
            entity.date = transaction.date
            entity.memo = transaction.memo
            
            return coreDataService.save()
                .map { _ in
                    self.logger.info("✅ 거래 저장완: \(transaction.title)")
                    return transaction
                }
                .subscribe(observer)
        }
    }
    
    func fetchAllTransaction() -> Observable<[Transaction]> {
        return coreDataService.fetch(
            TransactionEntity.self,
            sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)]
        )
        .map { [weak self] entities -> [Transaction] in
            guard let self = self else { return [] }
            
            return entities.compactMap { self.toModel($0) }
        }
    }
    
    func fetchTransactionByMonth(_ year: Int, _ month: Int) -> Observable<[Transaction]> {
        
        let calendar = Calendar.current
        
        guard let startDate = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let endDate = calendar.date(byAdding: .month, value: 1, to: startDate) else {
            return Observable.error(CoreDataError.invalidDate)
        }
        
        let predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            startDate as NSDate,
            endDate as NSDate
        )
        
        return coreDataService.fetch(
            TransactionEntity.self,
            predicate: predicate,
            sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)]
        )
        .map { [weak self] entities -> [Transaction] in
            guard let self = self else { return [] }
            let transactions = entities.compactMap { self.toModel($0) }
            logger.info("✅ \(year). \(month)월의 내역 개수: \(transactions.count)")
            return transactions
        }
    }
    
    func editTransaction(_ transaction: Transaction) -> Observable<Transaction> {
        let predicate = NSPredicate(format: "id == %@", transaction.id as CVarArg)
        
        return coreDataService.fetch(TransactionEntity.self, predicate: predicate)
            .flatMap { [weak self] entities -> Observable<Transaction> in
                guard let self = self else {
                    return Observable.error(CoreDataError.contextNotAvailable)
                }
                
                guard let entity = entities.first else {
                    logger.error("❌ 수정 내역을 찾을수 없음 \(transaction.id)")
                    return Observable.error(CoreDataError.entityNotFound)
                }
                
                entity.amount = Int32(transaction.amount)
                entity.title = transaction.title
                entity.paymentMethod = transaction.payment.rawValue
                entity.categoryID = transaction.category.id
                entity.date = transaction.date
                entity.memo = transaction.memo
                
                return coreDataService.save()
                    .map { _ in
                        self.logger.info("✅ 수정 완: \(transaction.title)")
                        return transaction
                    }
            }
    }
    
    func deleteTransaction(id: UUID) -> Observable<Void> {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return coreDataService.fetch(TransactionEntity.self, predicate: predicate)
            .flatMap { [weak self] entities -> Observable<Void> in
                guard let self = self else {
                    return Observable.error(CoreDataError.contextNotAvailable)
                }
                
                guard let entity = entities.first else {
                    logger.error("❌ 삭제할 내역을 찾을수 없음 \(id)")
                    return Observable.error(CoreDataError.entityNotFound)
                }
                
                return coreDataService.delete(entity)
                    .do { _ in
                        self.logger.info("✅ 삭제 완")
                    }
            }
    }
    
    private func toModel(_ entity: TransactionEntity) -> Transaction? {
        guard let id = entity.id,
              let title = entity.title,
              let date = entity.date,
              let paymentMethodString = entity.paymentMethod,
              let paymentMethod = PaymentMethod(rawValue: paymentMethodString),
              let categoryID = entity.categoryID else {
            logger.warning("❌ Failed to transform TransactionEntity to Transaction")
            return nil
        }
        
        guard let category = categoryService.fetchCategoryByID(categoryID) else {
            logger.warning("❌ 카테고리 없음 \(categoryID)")
            return nil
        }
        
        return Transaction(
            id: id,
            amount: Int(entity.amount),
            category: category,
            title: title,
            payment: paymentMethod,
            date: date,
            memo: entity.memo
        )
    }
}
