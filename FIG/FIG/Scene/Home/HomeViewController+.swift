//
//  HomeViewController+.swift
//  FIG
//
//  Created by Milou on 9/3/25.
//

import UIKit

extension HomeViewController {
    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let section = HomeSection(rawValue: sectionIndex) else { return nil }
            
            switch section {
            case .record:
                return self?.createRecordSection()
            case .challenge:
                return self?.createChallengeSection()
            case .chart:
                return self?.createChartSection()
            }
        }
        
        layout.register(
            ChartSectionBackgroundView.self,
            forDecorationViewOfKind: ChartSectionBackgroundView.reuseIdentifier
        )
        
        return layout
    }
    
    private func createRecordSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(104)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(104)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 24, trailing: 20)
        
        section.boundarySupplementaryItems = [createSectionHeader()]
        
        return section
    }
    
    private func createChallengeSection() -> NSCollectionLayoutSection {
        if currentChallengeCount > 1 {
            return createMultipleChallengeSection()
        } else {
            return createSingleChallengeSection()
        }
    }
    
    private func createSingleChallengeSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(160)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(160)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 24, trailing: 20)
        section.orthogonalScrollingBehavior = .none
        section.boundarySupplementaryItems = [createSectionHeader()]
        
        return section
    }
    
    /// 다중 챌린지용 섹션 (2개 이상)
    private func createMultipleChallengeSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(160)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(UIScreen.main.bounds.width - 40),
            heightDimension: .estimated(160)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 24, trailing: 20)
        section.interGroupSpacing = 8
        section.orthogonalScrollingBehavior = .groupPaging
        section.boundarySupplementaryItems = [createSectionHeader()]
        
        return section
    }
    
    private func createChartSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(40)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(40)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)

        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        section.interGroupSpacing = 16

        let decorationItem = NSCollectionLayoutDecorationItem.background(
            elementKind: ChartSectionBackgroundView.reuseIdentifier
        )
        decorationItem.contentInsets = NSDirectionalEdgeInsets(top: 44, leading: 20, bottom: 0, trailing: 20)  // top: 헤더 높이(44)만큼 제외
        section.decorationItems = [decorationItem]
        
        section.boundarySupplementaryItems = [createSectionHeader()]
        
        return section
    }
    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        return sectionHeader
    }
    
    func makeCategoryItemsForHome(from chartItems: [CategoryChartItem], total: Int) -> [CategoryChartItem] {
        let baseItems = chartItems.prefix(4).enumerated().map { (index, data) in
            data.withColor(ChartColor.rank(index))
        }
        guard chartItems.count > 4 else { return baseItems }
        
        let others = chartItems.dropFirst(4)
        return baseItems + [makeOthersCategory(from: others, total: total)]
    }
    
    private func makeOthersCategory(from items: ArraySlice<CategoryChartItem>, total: Int) -> CategoryChartItem {
        let othersAmount = items.reduce(0) { $0 + $1.amount }
        let othersChanged = items.reduce(0) { $0 + $1.changed }
        let othersPercentage = total > 0 ? (Double(othersAmount) / Double(total)) * 100 : 0
        
        return CategoryChartItem(
            category: Category.othersCategory,
            amount: othersAmount,
            percentage: othersPercentage.rounded(to: 2),
            changed: othersChanged,
            iconColor: ChartColor.others.uiColor,
            backgroundColor: ChartColor.others.uiColor.withAlphaComponent(0.1)
        )
    }
}

final class ChartSectionBackgroundView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 10
        clipsToBounds = true
    }
}
