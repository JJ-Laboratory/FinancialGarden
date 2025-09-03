//
//  ChartViewController.swift
//  FIG
//
//  Created by estelle on 9/3/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class ChartViewController: UIViewController {
    static let elementKindSectionHeader = "elementKindSectionHeader"
    static let elementKindSectionBackground = "elementKindSectionBackground"

    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: collectionViewLayout()
    )

    private lazy var dataSource = collectionViewDataSource(collectionView)

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .background
        collectionView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
          $0.top.bottom.equalToSuperview()
          $0.leading.trailing.equalToSuperview()
        }

        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.category, .summary])
        snapshot.appendItems([.categoryProgress(0)], toSection: .category)
        snapshot.appendItems((1...5).map { .categoryItem($0) }, toSection: .category)
        snapshot.appendItems((11...16).map { .summaryItem($0) }, toSection: .summary)
        dataSource.apply(snapshot)
    }
}

extension ChartViewController {
    private func collectionViewLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { [weak self] sectionIndex, environment in
            guard let section = self?.dataSource.sectionIdentifier(for: sectionIndex) else {
                return nil
            }
            let boundaryItem = switch section {
            case .category:
                NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(40)
                    ),
                    elementKind: Self.elementKindSectionHeader,
                    alignment: .top
                )
            case .summary:
                NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(300)
                    ),
                    elementKind: Self.elementKindSectionHeader,
                    alignment: .top
                )
            }
            
            let layoutItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(40)
                )
            )
            let layoutGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(40)
                ),
                subitems: [layoutItem]
            )

            let decorationItem = NSCollectionLayoutDecorationItem.background(
                elementKind: Self.elementKindSectionBackground
            )
            return NSCollectionLayoutSection(group: layoutGroup).then {
                $0.interGroupSpacing = 16
                $0.boundarySupplementaryItems = [boundaryItem]
                $0.decorationItems = [decorationItem]
                $0.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
            }
        }
        let configuration = UICollectionViewCompositionalLayoutConfiguration().then {
            $0.interSectionSpacing = 30
            $0.contentInsetsReference = .layoutMargins
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: configuration).then {
            $0.register(SectionBackgroundView.self, forDecorationViewOfKind: Self.elementKindSectionBackground)
        }
    }
    
    private func collectionViewDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Section, Item> {
        typealias SupplementaryRegistration = UICollectionView.SupplementaryRegistration
        typealias CellRegistration = UICollectionView.CellRegistration

        let categoryProgressCellRegistration = CellRegistration<ChartCategoryProgressCell, Void> { cell, indexPath, item in
            cell.amountLabel.text = "\(18882713.formattedWithComma)원"
            cell.progressView.items = [
                .item(value: 1, color: .gray2),
                .item(value: 4, color: .secondary),
                .item(value: 2, color: .primary),
                .item(value: 2, color: .pink)
            ]
        }
        let categoryItemCellRegistration = CellRegistration<ChartCategoryItemCell, Void> { cell, indexPath, item in
            cell.imageView.image = UIImage(systemName: "apple.logo")
            cell.nameLabel.text = "식비"
            cell.rateLabel.text = "30%"
            cell.totalValueLabel.text = "316,830원"
            cell.changedValueLabel.text = "49,687원"
        }
        let summaryItemCellRegistration = CellRegistration<ChartSummaryItemCell, Void> { cell, indexPath, item in
            cell.monthLabel.text = "1월"
            cell.increaseAmountLabel.text = "+2,350,000원"
            cell.decreaseAmountLabel.text = "+645,000원"
            cell.balanceLabel.text = "잔고 1,705,000원"
        }
        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .categoryProgress:
                return collectionView.dequeueConfiguredReusableCell(using: categoryProgressCellRegistration, for: indexPath, item: ())
            case .categoryItem:
                return collectionView.dequeueConfiguredReusableCell(using: categoryItemCellRegistration, for: indexPath, item: ())
            case .summaryItem:
                return collectionView.dequeueConfiguredReusableCell(using: summaryItemCellRegistration, for: indexPath, item: ())
            }
        }
        
        let kind = Self.elementKindSectionHeader
        let categoryHeaderRegistration = SupplementaryRegistration<ChartCategoryHeaderView>(elementKind: kind) { _, _, _ in
        }
        let summaryHeaderRegistration = SupplementaryRegistration<ChartSummaryHeaderView>(elementKind: kind) { view, _, _ in
            view.chartView.setItems(
                [
                    .transaction(label: "1", income: 1_000_000, expense: 200_000),
                    .transaction(label: "2", income: 2_000_000, expense: 400_000),
                    .transaction(label: "3", income: 3_000_000, expense: 600_000),
                    .transaction(label: "4", income: 4_000_000, expense: 800_000),
                    .transaction(label: "5", income: 5_000_000, expense: 1_000_000),
                    .transaction(label: "6", income: 6_000_000, expense: 1_200_000)
                ],
                animated: true
            )
        }
        dataSource.supplementaryViewProvider = { [weak self] collectionView, _, indexPath in
            guard let section = self?.dataSource.sectionIdentifier(for: indexPath.section) else {
                return nil
            }
            switch section {
            case .category:
                return collectionView.dequeueConfiguredReusableSupplementary(using: categoryHeaderRegistration, for: indexPath)
            case .summary:
                return collectionView.dequeueConfiguredReusableSupplementary(using: summaryHeaderRegistration, for: indexPath)
            }
        }
        return dataSource
    }
}

extension ChartViewController {
    enum Section {
        case category
        case summary
    }
}

extension ChartViewController {
    enum Item: Hashable {
        case categoryProgress(Int)
        case categoryItem(Int)
        case summaryItem(Int)
    }
}

extension ChartViewController {
    final class SectionBackgroundView: UICollectionReusableView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .white
            layer.cornerRadius = 10
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

#Preview {
    UINavigationController(
        rootViewController: ChartViewController()
    )
}
