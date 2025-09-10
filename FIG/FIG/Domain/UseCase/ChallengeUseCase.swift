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
                guard let self = self, !challenges.isEmpty else { return .just([]) }
                return self.updateChallengesWithSpending(challenges)
            }
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
