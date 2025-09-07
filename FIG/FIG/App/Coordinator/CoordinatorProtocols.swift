//
//  CoordinatorProtocols.swift
//  FIG
//
//  Created by Milou on 9/7/25.
//

import Foundation

protocol HomeCoordinatorProtocol: AnyObject {
    func selectTab(for section: HomeSection)
    func navigateToFormScreen(type: EmptyStateType)
}

protocol RecordCoordinatorProtocol: AnyObject {
    func pushRecordForm()
    func popRecordForm()
    func pushRecordFormEdit(transaction: Transaction)
}

protocol ChallengeCoordinatorProtocol: AnyObject {
    func pushChallengeForm()
    func pushChallengeDetail(challenge: Challenge)
    func popChallengeForm()
}
