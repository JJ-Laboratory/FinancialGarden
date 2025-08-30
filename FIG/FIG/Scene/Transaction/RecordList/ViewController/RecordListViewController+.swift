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
            return 1
        case .records:
            return recordGroups.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
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
            cell.configure(expense: 345678, income: 1234567)
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
            let recordGroup = recordGroups[indexPath.item]
            cell.configure(with: recordGroup)
            return cell
        }
    }
}
