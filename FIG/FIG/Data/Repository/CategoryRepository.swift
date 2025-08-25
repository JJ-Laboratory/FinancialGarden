//
//  CategoryRepository.swift
//  FIG
//
//  Created by Milou on 8/22/25.
//

import Foundation
import RxSwift
import CoreData
import OSLog

final class CategoryRepository: CategoryRepositoryInterface {
    
    private let coreDataService: CoreDataService
    private let logger = Logger.category
    
    init(coreDataService: CoreDataService = .shared) {
        self.coreDataService = coreDataService
    }
    
    func fetchAllCategories() -> Observable<[Category]> {
        return coreDataService.fetch(CategoryEntity.self)
            .map { entities in
                entities.compactMap { self.toModel($0) }
            }
    }
    
    func initializeDefaultCategories() -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(CoreDataError.contextNotAvailable)
                return Disposables.create()
            }
            
            let predicate = NSPredicate(format: "isDefault == true")
            
            return coreDataService.fetch(CategoryEntity.self, predicate: predicate)
                .flatMap { entities -> Observable<Void> in
                    if !entities.isEmpty {
                        self.logger.info("기본 카테고리 이미 존재 \(entities.count)")
                        return Observable.just(())
                    }
                    
                    let context = self.coreDataService.mainContext
                    
                    for defaultCategory in Category.defaultCategories {
                        _ = self.toEntity(defaultCategory, context: context)
                    }
                    
                    return self.coreDataService.save(context: context)
                }
                .subscribe(observer)
        }
    }
    
    // MARK: - Mapper
    /// Core Data Entity -> Domain Model
    private func toModel(_ entity: CategoryEntity) -> Category? {
        guard let id = entity.id,
            let title = entity.title,
            let iconName = entity.iconName,
            let transactionType = entity.transactionType // String
        else {
            return nil
        }
        
        return Category(
            title: title,
            iconName: iconName,
            transactionType: TransactionType(rawValue: transactionType) ?? TransactionType.expense,
            isDefault: entity.isDefault
        )
    }
    
    /// Domain Model -> Core Data Entity (초기화 시에만 사용)
    private func toEntity(_ category: Category, context: NSManagedObjectContext) -> CategoryEntity {
        let entity = CategoryEntity(context: context)
        entity.id = category.id
        entity.title = category.title
        entity.iconName = category.iconName
        entity.transactionType = category.transactionType.rawValue
        entity.isDefault = category.isDefault
        
        return entity
    }
}
