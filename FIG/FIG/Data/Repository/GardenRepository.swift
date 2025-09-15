//
//  GardenRepository.swift
//  FIG
//
//  Created by estelle on 9/1/25.
//

import Foundation
import RxSwift
import CoreData
import OSLog

final class GardenRepository: GardenRepositoryInterface {
    
    private let coreDataService: CoreDataService
    private let logger = Logger.garden
    
    init(coreDataService: CoreDataService = .shared) {
        self.coreDataService = coreDataService
    }
    
    func fetchGardenRecord() -> Observable<GardenRecord> {
        return fetchOrCreateEntity()
            .map { self.toModel($0) }
    }
    
    func add(seeds: Int, fruits: Int) -> Observable<GardenRecord> {
        return fetchOrCreateEntity()
            .flatMap { [weak self] entity -> Observable<GardenRecord> in
                guard let self = self else { return .error(CoreDataError.contextNotAvailable) }
                
                let currentSeeds = entity.totalSeeds
                let currentFruits = entity.totalFruits
                entity.totalSeeds = max(0, currentSeeds + Int16(seeds))
                entity.totalFruits = max(0, currentFruits + Int16(fruits))
                
                return coreDataService.save()
                    .map { _ in
                        return self.toModel(entity)
                    }
            }
    }
    
    private func fetchOrCreateEntity() -> Observable<GardenRecordEntity> {
        return coreDataService.fetch(GardenRecordEntity.self)
            .flatMap { [weak self] entities -> Observable<GardenRecordEntity> in
                guard let self = self else { return .error(CoreDataError.contextNotAvailable) }
                
                if let existingEntity = entities.first {
                    return .just(existingEntity)
                }
                
                logger.info("ℹ️ 기존 정원 기록 없음. 새로 생성")
                let context = coreDataService.mainContext
                let newEntity = GardenRecordEntity(context: context)
                newEntity.totalSeeds = 0
                newEntity.totalFruits = 0
                
                return coreDataService.save()
                    .map { _ in newEntity }
                    .catch { error in
                        self.logger.error("❌ 정원 기록 Entity 저장 실패: \(error.localizedDescription)")
                        return .error(error)
                    }
            }
    }
    
    private func toModel(_ entity: GardenRecordEntity) -> GardenRecord {
        return GardenRecord(
            totalSeeds: Int(entity.totalSeeds),
            totalFruits: Int(entity.totalFruits)
        )
    }
}
