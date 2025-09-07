//
//  RepositoryProvider.swift
//  FIG
//
//  Created by Milou on 9/7/25.
//

import Foundation

protocol RepositoryProviderInterface {
    var transactionRepository: TransactionRepositoryInterface { get }
    var challengeRepository: ChallengeRepositoryInterface { get }
    var gardenRepository: GardenRepositoryInterface { get }
}

final class RepositoryProvider: RepositoryProviderInterface {
    static let shared = RepositoryProvider()
    
    private init() {}
    
    lazy var transactionRepository: TransactionRepositoryInterface = {
        TransactionRepository(
            coreDataService: .shared,
            categoryService: .shared
        )
    }()
    
    lazy var challengeRepository: ChallengeRepositoryInterface = {
        ChallengeRepository(
            coreDataService: .shared,
            categoryService: .shared
        )
    }()
    
    lazy var gardenRepository: GardenRepositoryInterface = {
        GardenRepository(
            coreDataService: .shared
        )
    }()
}
