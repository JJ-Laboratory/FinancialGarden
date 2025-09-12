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
        guard let section = Section(rawValue: section),
             let reactor = reactor else { return 0 }
        
        let hasRecords = !reactor.currentState.recordGroups.isEmpty
        
        switch section {
        case .summary:
            return 1
        case .sectionHeader:
            return 1
        case .records:
            return hasRecords ? reactor.currentState.recordGroups.count : 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section),
              let reactor = reactor else {
            return UICollectionViewCell()
        }
        
        let hasRecords = !reactor.currentState.recordGroups.isEmpty
        
        switch section {
        case .summary:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MonthlySummaryCell.identifier,
                for: indexPath
            ) as? MonthlySummaryCell else {
                return UICollectionViewCell()
            }
            let state = reactor.currentState
            cell.configure(expense: state.monthlySummary.expense, income: state.monthlySummary.income)
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
            if hasRecords {
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: RecordGroupCell.identifier,
                    for: indexPath
                ) as? RecordGroupCell else {
                    return UICollectionViewCell()
                }
                
                let recordGroups = reactor.currentState.recordGroups
                let recordGroup = recordGroups[indexPath.item]
                cell.configure(with: recordGroup)
                
                cell.onRecordTap = { [weak self] transaction in
                    self?.coordinator?.pushRecordFormEdit(transaction: transaction)
                }
                return cell
            } else {
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: EmptyStateCell.identifier,
                    for: indexPath
                ) as? EmptyStateCell else {
                    return UICollectionViewCell()
                }
                
                cell.configure(type: .transaction)
                cell.pushButtonTapped
                    .subscribe { [weak self] _ in
                        self?.coordinator?.pushRecordForm()
                    }
                    .disposed(by: cell.disposeBag)
                return cell
            }
        }
    }
}
