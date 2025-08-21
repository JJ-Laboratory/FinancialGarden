//
//  CoreDataService.swift
//  FIG
//
//  Created by Milou on 8/20/25.
//

import Foundation
import CoreData
import RxSwift
import OSLog

final class CoreDataService {
    
    static let shared = CoreDataService()
    private let logger = Logger.coreData
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        
        let container = NSPersistentCloudKitContainer(name: "FIG")
        
        let storeDescription = container.persistentStoreDescriptions.first
        // 데이터 변경 이력 추적
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        // 데이터 변경 있을 경우 알림
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                self.logger.error("❌ Core Data 로드 실패: \(error, privacy: .public)")
                self.logger.debug("Error UserInfo: \(error.userInfo, privacy: .private)")
            } else {
                self.logger.info("✅ Core Data 로드 성공")
                // parent context(백그라운드)에서 변경된 내용이 자동으로 viewContext(메인 스레드)로 병합
                container.viewContext.automaticallyMergesChangesFromParent = true
                // 외부(parent)에서 들어온 변경 사항이 메모리(viewContext)에 있는 기존 객체의 속성 값을 덮어씀
                container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            }
        }
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {}
    
    // MARK: - Save
    
    func save(context: NSManagedObjectContext? = nil) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                self?.logger.error("❌ CoreDataService 인스턴스 nil")
                observer.onError(CoreDataError.contextNotAvailable)
                return Disposables.create()
            }
            
            let context = context ?? self.mainContext
            
            if context.hasChanges {
                self.logger.debug("🧪 변경사항 저장 시작")
                
                do {
                    try context.save()
                    
                    // 로깅 위한 변수들
                    let insertedCount = context.insertedObjects.count
                    let updatedCount = context.updatedObjects.count
                    let deletedCount = context.deletedObjects.count
                    self.logger.info("✅ 저장 완료 - 추가: \(insertedCount), 수정: \(updatedCount), 삭제: \(deletedCount)")
                    
                    observer.onNext(())
                    observer.onCompleted()
                } catch {
                    self.logger.error("❌ 저장 실패: \(error.localizedDescription, privacy: .public)")
                    observer.onError(CoreDataError.saveFailed(error))
                }
            } else {
                self.logger.debug("🧪 변경사항 없음")
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    // MARK: - Fetch
    
    func fetch<T: NSManagedObject>(
        _ entityType: T.Type,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        fetchLimit: Int? = nil
    ) -> Observable<[T]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                self?.logger.error("❌ CoreDataService 인스턴스 nil")
                observer.onError(CoreDataError.contextNotAvailable)
                return Disposables.create()
            }
            
            let entityName = String(describing: entityType)
            self.logger.debug("🧪 Fetch 시작 - Entity: \(entityName, privacy: .public)")
            
            let fetchRequest = NSFetchRequest<T>(entityName: entityName)
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = sortDescriptors
            
            if let limit = fetchLimit {
                fetchRequest.fetchLimit = limit
            }
            
            do {
                let results = try self.mainContext.fetch(fetchRequest)
                self.logger.info("✅ Fetch 성공 - \(entityName): \(results.count)개")
                
                observer.onNext(results)
                observer.onCompleted()
            } catch {
                self.logger.error("❌ Fetch 실패 - \(entityName): \(error.localizedDescription, privacy: .public)")
                observer.onError(CoreDataError.fetchFailed(error))
            }
            return Disposables.create()
        }
    }
    
    // MARK: - Delete
    
    func delete<T: NSManagedObject>(_ object: T) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                self?.logger.error("❌ CoreDataService 인스턴스 nil")
                observer.onError(CoreDataError.contextNotAvailable)
                return Disposables.create()
            }
            
            let entityName = String(describing: type(of: object))
            self.logger.debug("🧪 Delete 시작 - Entity: \(entityName, privacy: .public)")
            
            self.mainContext.delete(object)
            
            return self.save()
                .subscribe (
                    onNext: {
                        self.logger.info("✅ Delete 성공 - \(entityName)")
                        observer.onNext(())
                        observer.onCompleted()
                    }, onError: { error in
                        self.logger.error("❌ Delete 실패 - \(entityName): \(error.localizedDescription, privacy: .public)")
                        observer.onError(CoreDataError.deleteFailed(error))
                    }
                )
        }
    }
}
