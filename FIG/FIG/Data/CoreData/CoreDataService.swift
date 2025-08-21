//
//  CoreDataService.swift
//  FIG
//
//  Created by Milou on 8/20/25.
//

import Foundation
import CoreData
import RxSwift

final class CoreDataService {
    
    static let shared = CoreDataService()
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "FIG")
        
        let storeDescription = container.persistentStoreDescriptions.first
        // 데이터 변경 이력 추적
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        // 데이터 변경 있을 경우 알림
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("❌ Core Data 로드 실패: \(error)")
            } else {
                print("🧪 Core Data 로드 성공")
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
                observer.onError(CoreDataError.contextNotAvailable)
                return Disposables.create()
            }
            
            let context = context ?? self.mainContext
            
            if context.hasChanges {
                do {
                    try context.save()
                    observer.onNext(())
                    observer.onCompleted()
                } catch {
                    observer.onError(CoreDataError.saveFailed(error))
                }
            } else {
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
                observer.onError(CoreDataError.contextNotAvailable)
                return Disposables.create()
            }
            
            let fetchRequest = NSFetchRequest<T>(entityName: String(describing: entityType))
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = sortDescriptors
            
            if let limit = fetchLimit {
                fetchRequest.fetchLimit = limit
            }
            
            do {
                let results = try self.mainContext.fetch(fetchRequest)
                observer.onNext(results)
                observer.onCompleted()
            } catch {
                observer.onError(CoreDataError.fetchFailed(error))
            }
            return Disposables.create()
        }
    }
    
    // MARK: - Delete
    func delete<T: NSManagedObject>(_ object: T) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(CoreDataError.contextNotAvailable)
                return Disposables.create()
            }
            
            self.mainContext.delete(object)
            
            return self.save()
                .subscribe (
                    onNext: {
                        observer.onNext(())
                        observer.onCompleted()
                    }, onError: { error in
                        observer.onError(CoreDataError.deleteFailed(error))
                    }
                )
        }
    }
}
