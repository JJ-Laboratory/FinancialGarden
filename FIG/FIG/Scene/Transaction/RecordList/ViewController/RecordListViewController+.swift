//
//  RecordListViewController+.swift
//  FIG
//
//  Created by Milou on 8/29/25.
//

import UIKit

extension RecordListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        
        switch section {
        case .summary:
            return 1
        case .sectionHeader:
            return reactor?.currentState.recordGroups.isEmpty == false ? 1 : 0
        case .records:
            return reactor?.currentState.recordGroups.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section),
              let reactor = reactor else {
            return UICollectionViewCell()
        }
        
        switch section {
        case .summary:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MonthlySummaryCell.identifier,
                for: indexPath
            ) as? MonthlySummaryCell else {
                return UICollectionViewCell()
            }
            let state = reactor.currentState
            cell.configure(expense: state.monthlyExpense, income: state.monthlyIncome)
            return cell
            
        case .sectionHeader:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SectionHeaderCell.identifier,
                for: indexPath
            ) as? SectionHeaderCell else {
                return UICollectionViewCell()
            }
            return cell
            
        case .records:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RecordGroupCell.identifier,
                for: indexPath
            ) as? RecordGroupCell else {
                return UICollectionViewCell()
            }
            
            let recordGroups = reactor.currentState.recordGroups
            let recordGroup = recordGroups[indexPath.item]
            cell.configure(with: recordGroup)
            return cell
        }
    }
}
