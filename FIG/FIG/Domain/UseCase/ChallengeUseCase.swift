//
//  ChallengeUseCase.swift
//  FIG
//
//  Created by Milou on 9/9/25.
//

import Foundation
import RxSwift

final class ChallengeUseCase {
    private let challengeRepository: ChallengeRepositoryInterface
    private let transactionRepository: TransactionRepositoryInterface
    
    init(
        challengeRepository: ChallengeRepositoryInterface,
        transactionRepository: TransactionRepositoryInterface
    ) {
        self.challengeRepository = challengeRepository
        self.transactionRepository = transactionRepository
    }
    
    func getCurrentChallenges(year: Int, month: Int) -> Observable<[Challenge]> {
        return challengeRepository.fetchChallengesByMonth(year, month)
            .flatMap { [weak self] challenges -> Observable<[Challenge]> in
                guard let self, !challenges.isEmpty else { return .just([]) }
                return updateChallengesWithSpending(challenges)
            }
            .flatMap { [weak self] challenges -> Observable<[Challenge]> in
                guard let self else { return .just([]) }
                return updateStatus(challenges)
            }
    }
    
    private func updateStatus(_ challenges: [Challenge]) -> Observable<[Challenge]> {
        var editedChallenge: [Challenge] = []
        var finalChallenges = challenges
        
        for (index, challenge) in challenges.enumerated() {
            
            if challenge.isCompleted {
                continue
            }
            
            var updatedChallenge = challenge
            let progressValue = challenge.startDate.progress(to: challenge.endDate)
            
            if progressValue >= 1 {
                if challenge.currentSpending <= challenge.spendingLimit {
                    updatedChallenge.status = .success
                } else {
                    updatedChallenge.status = .failure
                }
                editedChallenge.append(updatedChallenge)
                finalChallenges[index] = updatedChallenge
            } else if challenge.currentSpending > challenge.spendingLimit {
                updatedChallenge.status = .failure
                editedChallenge.append(updatedChallenge)
                finalChallenges[index] = updatedChallenge
            } else {
                updatedChallenge.status = .progress
                editedChallenge.append(updatedChallenge)
                finalChallenges[index] = updatedChallenge
            }
        }
        
        if editedChallenge.isEmpty {
            return .just(challenges)
        }
        
        let editObservables = editedChallenge.map { updatedChallenge in
            self.challengeRepository.editChallenge(updatedChallenge)
        }
        
        return Observable.zip(editObservables)
            .map { _ in finalChallenges }
    }
    
    private func updateChallengesWithSpending(_ challenges: [Challenge]) -> Observable<[Challenge]> {
        let amountObservables = challenges
            .map { [transactionRepository] challenge in
                transactionRepository.fetchTotalAmount(
                    categoryId: challenge.category.id,
                    startDate: challenge.startDate,
                    endDate: challenge.endDate
                )
            }
        
        return Observable.zip(amountObservables)
            .map { amounts in
                var updatedChallenges: [Challenge] = []
                for (var challenge, amount) in zip(challenges, amounts) {
                    challenge.currentSpending = amount
                    updatedChallenges.append(challenge)
                }
                return updatedChallenges
            }
    }
}
