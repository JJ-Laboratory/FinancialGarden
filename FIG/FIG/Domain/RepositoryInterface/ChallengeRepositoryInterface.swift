//
//  ChallengeRepositoryInterface.swift
//  FIG
//
//  Created by estelle on 9/1/25.
//

import Foundation
import RxSwift

protocol ChallengeRepositoryInterface {
    
    // MARK: - CREATE
    
    /// 새로운 챌린지를 저장합니다
    func saveChallenge(_ challenge: Challenge) -> Observable<Challenge>
    
    // MARK: - READ
    
    /// 모든 챌린지를 불러옵니다
    func fetchAllChallenges() -> Observable<[Challenge]>
    /// 해당 월에 시작된 챌린지들을 불러옵니다
    func fetchChallengesByMonth(_ year: Int, _ month: Int) -> Observable<[Challenge]>
    
    // MARK: - UPDATE
    
    /// 기존 챌린지를 수정합니다
    func editChallenge(_ challenge: Challenge) -> Observable<Challenge>
    
    // MARK: - DELETE
    
    /// 기존 챌린지를 삭제합니다
    func deleteChallenge(id: UUID) -> Observable<Void>
}
