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
import ReactorKit

final class ChartViewController: UIViewController, View {
    
    weak var coordinator: ChartCoordinator?
    var disposeBag = DisposeBag()
    
    static let elementKindSectionHeader = "elementKindSectionHeader"
    static let elementKindSectionBackground = "elementKindSectionBackground"
    
    private let monthButton = UIButton(configuration: .plain()).then {
        $0.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.foregroundColor = .charcoal
            outgoing.font = .preferredFont(forTextStyle: .title2).withWeight(.semibold)
            return outgoing
        }
        $0.configuration?.image = UIImage(
            systemName: "chevron.down",
            withConfiguration: UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .title2).withWeight(.semibold))
                .applying(UIImage.SymbolConfiguration(scale: .small))
        )
        $0.configuration?.imagePlacement = .trailing
        $0.configuration?.imagePadding = 8
        $0.tintColor = .charcoal
        
        $0.contentHorizontalAlignment = .leading
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: collectionViewLayout()
    )
    
    private lazy var dataSource = collectionViewDataSource(collectionView)
    
    init(reactor: ChartReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor?.action.onNext(.viewDidLoad)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: monthButton)
        collectionView.backgroundColor = .background
        collectionView.showsVerticalScrollIndicator = false
        collectionView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        view.addSubview(collectionView)
        view.backgroundColor = .background
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        collectionView.contentInset.bottom = 20
        collectionView.verticalScrollIndicatorInsets.bottom = 20
    }
    
    func bind(reactor: ChartReactor) {
        monthButton.rx.tap
            .withUnretained(self)
            .flatMap { viewController, _ -> Observable<Date> in
                let currentMonth = viewController.reactor?.currentState.selectedMonth ?? Date()
                let picker = DatePickerController(title: "월 선택", date: currentMonth, mode: .yearAndMonth)
                picker.minimumDate = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1))
                picker.maximumDate = Date()
                
                viewController.present(picker, animated: true)
                return picker.rx.dateSelected.asObservable()
            }
            .subscribe { [weak self] date in
                self?.reactor?.action.onNext(.selectMonth(date))
            }
            .disposed(by: disposeBag)
        
        let monthDriver = reactor.state
            .map(\.selectedMonth)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
        
        let categoryItemsDriver = reactor.state
            .map { state -> [ChartItem] in
                [.categoryProgress(totalAmount: state.categoryTotalAmount, items: state.categoryProgressItems)]
                + state.categoryChartItems.map { .categoryItem($0) }
            }
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
        
        let summaryItemsDriver = reactor.state
            .map { state -> [ChartItem] in state.summaryChartItems.map { .summaryItem($0) }}
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
        
        Driver.combineLatest( monthDriver, categoryItemsDriver, summaryItemsDriver)
            .drive(onNext: { [weak self] month, categoryItems, summaryItems in
                self?.monthButton.setTitle(month.monthString, for: .normal)
                
                var snapshot = NSDiffableDataSourceSnapshot<ChartSection, ChartItem>()
                snapshot.appendSections([.category, .summary])
                snapshot.appendItems(categoryItems, toSection: .category)
                snapshot.appendItems(summaryItems, toSection: .summary)
                self?.dataSource.apply(snapshot)
            })
            .disposed(by: disposeBag)
    }
}

extension ChartViewController {
    private func collectionViewLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { [weak self] sectionIndex, _ in
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
            
            let contentInsets: NSDirectionalEdgeInsets
            switch section {
            case .category:
                contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
            case .summary:
                contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
            }
            
            return NSCollectionLayoutSection(group: layoutGroup).then {
                $0.interGroupSpacing = 16
                $0.boundarySupplementaryItems = [boundaryItem]
                $0.decorationItems = [decorationItem]
                $0.contentInsets = contentInsets
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
    
    private func collectionViewDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<ChartSection, ChartItem> {
        typealias SupplementaryRegistration = UICollectionView.SupplementaryRegistration
        typealias CellRegistration = UICollectionView.CellRegistration
        
        let categoryProgressCellRegistration = CellRegistration<ChartCategoryProgressCell, (totalAmount: Int, items: [ChartProgressView.Item])> { cell, indexPath, item in
            cell.amountLabel.text = "\(item.totalAmount.formattedWithComma)원"
            cell.progressView.items = item.items
            print(item.items)
        }
        let categoryItemCellRegistration = CellRegistration<ChartCategoryItemCell, CategoryChartItem> { cell, indexPath, item in
            cell.configure(with: item)
        }
        let summaryItemCellRegistration = CellRegistration<ChartSummaryItemCell, SummaryChartItem> { cell, indexPath, item in
            cell.monthLabel.text = item.month + "월"
            cell.increaseAmountLabel.text = "+\(item.income.formattedWithComma)원"
            cell.decreaseAmountLabel.text = "-\(item.expense.formattedWithComma)원"
            cell.balanceLabel.text = "잔고 \(item.balance.formattedWithComma)원"
        }
        let dataSource = UICollectionViewDiffableDataSource<ChartSection, ChartItem>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .categoryProgress(let totalAmount, let progressViewItem):
                return collectionView.dequeueConfiguredReusableCell(using: categoryProgressCellRegistration, for: indexPath, item: (totalAmount, progressViewItem))
            case .categoryItem(let categoryData):
                return collectionView.dequeueConfiguredReusableCell(using: categoryItemCellRegistration, for: indexPath, item: categoryData)
            case .summaryItem(let summaryData):
                return collectionView.dequeueConfiguredReusableCell(using: summaryItemCellRegistration, for: indexPath, item: summaryData)
            }
        }
        
        let kind = Self.elementKindSectionHeader
        let categoryHeaderRegistration = SupplementaryRegistration<ChartCategoryHeaderView>(elementKind: kind) { _, _, _ in
        }
        let summaryHeaderRegistration = SupplementaryRegistration<ChartSummaryHeaderView>(elementKind: kind) { [weak self] view, _, _ in
            guard let self = self, let reactor = self.reactor else { return }
            
            reactor.state
                .map(\.summaryBarChartItems)
                .distinctUntilChanged()
                .asDriver(onErrorJustReturn: [])
                .drive(onNext: { items in
                    view.chartView.setItems(items, animated: true)
                })
                .disposed(by: self.disposeBag)
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
