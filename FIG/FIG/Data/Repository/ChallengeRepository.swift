//
//  ChallengeRepository.swift
//  FIG
//
//  Created by estelle on 9/1/25.
//

import Foundation
import RxSwift
import CoreData
import OSLog

final class ChallengeRepository: ChallengeRepositoryInterface {
    
    private let coreDataService: CoreDataService
    private let categoryService: CategoryService
    private let logger = Logger.challenge
    
    init(
        coreDataService: CoreDataService = .shared,
        categoryService: CategoryService = .shared
    ) {
        self.coreDataService = coreDataService
        self.categoryService = categoryService
    }
    
    func saveChallenge(_ challenge: Challenge) -> Observable<Challenge> {
        let context = coreDataService.mainContext
        let entity = ChallengeEntity(context: context)
        updateEntity(entity, from: challenge)
        
        return coreDataService.save()
            .map { [weak self] _ in
                self?.logger.info("✅ 챌린지 저장 완료: \(challenge.category.title)")
                return challenge
            }
    }
    
    func fetchAllChallenges() -> Observable<[Challenge]> {
        return coreDataService.fetch(
            ChallengeEntity.self,
            sortDescriptors: [NSSortDescriptor(key: "startDate", ascending: false)]
        )
        .map { [weak self] entities -> [Challenge] in
            guard let self = self else { return [] }
            let challenges = entities.compactMap { self.toModel($0) }
            logger.info("✅ 전체 챌린지 \(challenges.count)개 로드")
            return challenges
        }
    }
    
    func fetchChallengesByMonth(_ year: Int, _ month: Int) -> Observable<[Challenge]> {
        let calendar = Calendar.current
        
        guard let startDate = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let endDate = calendar.date(byAdding: .month, value: 1, to: startDate) else {
            return Observable.error(CoreDataError.invalidDate)
        }
        
        let predicate = NSPredicate(
            format: "startDate >= %@ AND startDate < %@",
            startDate as NSDate,
            endDate as NSDate
        )
        
        return coreDataService.fetch(
            ChallengeEntity.self,
            predicate: predicate,
            sortDescriptors: [NSSortDescriptor(key: "startDate", ascending: false)]
        )
        .map { [weak self] entities -> [Challenge] in
            guard let self else { return [] }
            let challenges = entities.compactMap { self.toModel($0) }
            return challenges
        }
    }
    
    
    func editChallenge(_ challenge: Challenge) -> Observable<Challenge> {
        let predicate = NSPredicate(format: "id == %@", challenge.id as CVarArg)
        
        return coreDataService.fetch(ChallengeEntity.self, predicate: predicate)
            .flatMap { [weak self] entities -> Observable<Challenge> in
                guard let self = self else {
                    return .error(CoreDataError.contextNotAvailable)
                }
                
                guard let entity = entities.first else {
                    logger.error("❌ 수정할 챌린지를 찾을 수 없음: \(challenge.id)")
                    return .error(CoreDataError.entityNotFound)
                }
                
                updateEntity(entity, from: challenge)
                
                return self.coreDataService.save()
                    .map { _ in
                        self.logger.info("✅ 챌린지 수정 완료: \(challenge.category.title)")
                        return challenge
                    }
            }
    }
    
    func deleteChallenge(id: UUID) -> Observable<Void> {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return coreDataService.fetch(ChallengeEntity.self, predicate: predicate)
            .flatMap { [weak self] entities -> Observable<Void> in
                guard let self = self else {
                    return .error(CoreDataError.contextNotAvailable)
                }
                
                guard let entity = entities.first else {
                    logger.error("❌ 삭제할 챌린지를 찾을 수 없음: \(id)")
                    return .error(CoreDataError.entityNotFound)
                }
                
                return self.coreDataService.delete(entity)
                    .do(onNext: { _ in
                        self.logger.info("✅ 챌린지 삭제 완료: \(id)")
                    })
            }
    }
    
    private func toModel(_ entity: ChallengeEntity) -> Challenge? {
        guard let id = entity.id,
              let startDate = entity.startDate,
              let endDate = entity.endDate,
              let durationInt = Int(entity.duration ?? "7"),
              let duration = ChallengeDuration(rawValue: durationInt),
              let statusString = entity.status,
              let status = ChallengeStatus(rawValue: statusString),
              let categoryID = entity.categoryID else {
            logger.warning("❌ ChallengeEntity -> Challenge 모델 변환 실패")
            return nil
        }
        
        guard let category = categoryService.fetchCategoryByID(categoryID) else {
            logger.warning("❌ 챌린지에 연결된 카테고리를 찾을 수 없음: \(categoryID)")
            return nil
        }
        
        return Challenge(
            id: id,
            category: category,
            startDate: startDate,
            endDate: endDate,
            duration: duration,
            spendingLimit: Int(entity.spendingLimit),
            requiredSeedCount: Int(entity.requiredSeedCount),
            targetFruitsCount: Int(entity.targetFruitsCount),
            isCompleted: entity.isCompleted,
            status: status
        )
    }
    
    private func updateEntity(_ entity: ChallengeEntity, from model: Challenge) {
        entity.id = model.id
        entity.categoryID = model.category.id
        entity.startDate = model.startDate
        entity.endDate = model.endDate
        entity.duration = "\(model.duration.rawValue)"
        entity.spendingLimit = Int32(model.spendingLimit)
        entity.requiredSeedCount = Int16(model.requiredSeedCount)
        entity.targetFruitsCount = Int16(model.targetFruitsCount)
        entity.isCompleted = model.isCompleted
        entity.status = model.status.rawValue
    }
}
