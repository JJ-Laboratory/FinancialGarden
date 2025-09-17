//
//  CoordinatorProtocols.swift
//  FIG
//
//  Created by Milou on 9/7/25.
//

import Foundation

protocol TabBarCoordinatorProtocol: AnyObject {
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
    func pushChallengeEdit(result: MBTIResult)
    func popChallengeForm()
    func navigateToChallengeList()
}

protocol ChartCoordinatorProtocol: AnyObject {
    func pushAnalysis()
    func popAnalysis()
    func pushAnalysisResult()
    func navigateToChallengeList()
}
