//
//  MBTIResultRepository.swift
//  FIG
//
//  Created by estelle on 9/16/25.
//

import Foundation
import RxSwift
import OSLog

final class MBTIResultRepository: MBTIResultRepositoryInterface {
    
    private let coreDataService: CoreDataService
    private let logger = Logger.mbti
    private let id: Int16 = 1
    
    init(coreDataService: CoreDataService = .shared) {
        self.coreDataService = coreDataService
    }
    
    func fetchResult() -> Observable<MBTIResult?> {
        return fetchEntity()
            .map { entity in
                return entity.map { self.toModel($0) }
            }
    }
    
    func saveOrUpdateResult(_ result: MBTIResult) -> Observable<MBTIResult> {
        return fetchEntity()
            .flatMap { [weak self] existingEntity -> Observable<MBTIResult> in
                guard let self else { return .error(CoreDataError.contextNotAvailable) }
                
                let context = coreDataService.mainContext
                let entity: MBTIResultEntity
                
                if let existing = existingEntity {
                    logger.info("MBTI 결과 업데이트")
                    entity = existing
                } else {
                    logger.info("새 MBTI 결과 생성")
                    entity = MBTIResultEntity(context: context)
                    entity.id = id
                }
                
                updateEntity(entity, from: result)
                
                return coreDataService.save()
                    .map { result }
            }
    }
    
    private func fetchEntity() -> Observable<MBTIResultEntity?> {
        let predicate = NSPredicate(format: "id == %d", id)
        return coreDataService.fetch(MBTIResultEntity.self, predicate: predicate)
            .map { $0.first }
    }
    
    private func toModel(_ entity: MBTIResultEntity) -> MBTIResult {
        return MBTIResult(
            mbti: entity.mbti ?? "",
            title: entity.title ?? "",
            description: entity.desc ?? "",
            recommend: entity.recommend ?? ""
        )
    }
    
    private func updateEntity(_ entity: MBTIResultEntity, from model: MBTIResult) {
        entity.mbti = model.mbti
        entity.title = model.title
        entity.desc = model.description
        entity.recommend = model.recommend
    }
}
