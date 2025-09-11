//
//  HomeViewController.swift
//  FIG
//
//  Created by Milou on 9/2/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit

final class HomeViewController: UIViewController, View {
    
    var disposeBag = DisposeBag()
    
    var currentChallengeCount = 0
    
    private let backgroundImageView = UIImageView().then {
        $0.image = UIImage(named: "home_background")
        $0.contentMode = .scaleAspectFill
    }
    
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
    
    private lazy var collectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<HomeSection, HomeItem>!
    
    init(reactor: HomeReactor) {
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
        setupUI()
        setupNavigationBar()
        setupCollectionView()
        setupDataSource()
        
//        reactor?.action.onNext(.viewDidLoad)
    }
    
    func bind(reactor: HomeReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    private func bindAction(_ reactor: HomeReactor) {
        monthButton.rx.tap
            .subscribe { [weak self] _ in
                self?.presentMonthPicker()
            }
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: HomeReactor) {
        reactor.state.map(\.selectedMonth)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] date in
                self?.updateMonthButton(with: date)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] state in
                self?.updateSnapshot(with: state)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$error)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] error in
                self?.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
        
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        collectionView.contentInset.bottom = 20
        collectionView.verticalScrollIndicatorInsets.bottom = 20
    }
    
    private func setupNavigationBar() {
        let monthBarButtonItem = UIBarButtonItem(customView: monthButton)
        navigationItem.leftBarButtonItem = monthBarButtonItem
    }
    
    private func setupCollectionView() {
        collectionView.register(MonthlySummaryCell.self, forCellWithReuseIdentifier: MonthlySummaryCell.identifier)
        collectionView.register(ChallengeCell.self, forCellWithReuseIdentifier: ChallengeCell.identifier)
        collectionView.register(ChartCategoryProgressCell.self, forCellWithReuseIdentifier: ChartCategoryProgressCell.identifier)
        collectionView.register(ChartCategoryItemCell.self, forCellWithReuseIdentifier: ChartCategoryItemCell.identifier)
        collectionView.register(EmptyStateCell.self, forCellWithReuseIdentifier: EmptyStateCell.identifier)
        
        collectionView.register(HomeHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeHeaderView.reuseIdentifier)
        collectionView.collectionViewLayout.register(
            ChartSectionBackgroundView.self,
            forDecorationViewOfKind: ChartSectionBackgroundView.reuseIdentifier
        )
    }
    
    private func setupDataSource() {
        let monthlySummaryRegistration = UICollectionView.CellRegistration<MonthlySummaryCell, MonthlySummary> { cell, _, item in
            cell.configure(expense: item.expense, income: item.income)
        }
        
        let challengeRegistration = UICollectionView.CellRegistration<ChallengeCell, Challenge> { cell, _, challenge in
            cell.configure(with: challenge, isHomeMode: true)
        }
        
        let emptyStateRegistration = UICollectionView.CellRegistration<EmptyStateCell, EmptyStateType> { [weak self] cell, _, type in
            cell.configure(type: type)
            cell.pushButtonTapped
                .subscribe { _ in
                    self?.reactor?.action.onNext(.emptyStateButtonTapped(type))
                }
                .disposed(by: cell.disposeBag)
        }
        
        let chartProgressRegistration = UICollectionView.CellRegistration<ChartCategoryProgressCell, (totalAmount: Int, items: [ChartProgressView.Item])> { cell, _, item in
            cell.amountLabel.text = "\(item.totalAmount.formattedWithComma)원"
            cell.progressView.items = item.items
        }
        
        let chartCategoryRegistration = UICollectionView.CellRegistration<ChartCategoryItemCell, CategoryChartItem> { cell, _, item in
            cell.configure(with: item)
        }
        
        dataSource = UICollectionViewDiffableDataSource<HomeSection, HomeItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            switch item {
            case .monthlySummary(let summary):
                return collectionView.dequeueConfiguredReusableCell(
                    using: monthlySummaryRegistration,
                    for: indexPath,
                    item: summary
                )
                
            case .challenge(let challenge):
                return collectionView.dequeueConfiguredReusableCell(
                    using: challengeRegistration,
                    for: indexPath,
                    item: challenge
                )
                
            case .emptyState(let type):
                return collectionView.dequeueConfiguredReusableCell(
                    using: emptyStateRegistration,
                    for: indexPath,
                    item: type
                )
                
            case .chartProgress(let totalAmount, let items):
                return collectionView.dequeueConfiguredReusableCell(
                    using: chartProgressRegistration,
                    for: indexPath,
                    item: (totalAmount: totalAmount, items: items)
                )
                
            case .chartCategory(let item):
                return collectionView.dequeueConfiguredReusableCell(
                    using: chartCategoryRegistration,
                    for: indexPath,
                    item: item
                )
            }
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            return self?.configureHeader(collectionView: collectionView, kind: kind, indexPath: indexPath)
        }
    }
    
    private func configureHeader(collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        guard kind == UICollectionView.elementKindSectionHeader,
              let section = HomeSection(rawValue: indexPath.section) else {
            return nil
        }
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HomeHeaderView.reuseIdentifier, for: indexPath) as? HomeHeaderView else {
            return UICollectionReusableView()
        }
        
        headerView.configure(title: section.title)
        
        // 헤더 탭 이벤트
        headerView.headerTapped
            .subscribe { [weak self] _ in
                self?.reactor?.action.onNext(.headerTapped(section))
            }
            .disposed(by: headerView.disposeBag)
        
        return headerView
    }
    
    // MARK: - Snapshot Update
    
    private func updateSnapshot(with state: HomeReactor.State) {
        guard let dataSource = dataSource else { return }
        
        let newChallengesCount = state.currentChallenges.count
        
        if shouldUpdateLayout(previousCount: currentChallengeCount, currentCount: newChallengesCount) {
            currentChallengeCount = newChallengesCount
            
            let newLayout = createCompositionalLayout()
            collectionView.setCollectionViewLayout(newLayout, animated: true)
        } else {
            // 레이아웃 변경 필요없으면 개수만 업뎃
            currentChallengeCount = newChallengesCount
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeItem>()
        
        // 가계부 섹션
        snapshot.appendSections([.record])
        snapshot.appendItems([.monthlySummary(state.monthlySummary)], toSection: .record)
//            expense: state.monthlyExpense, income: state.monthlyIncome
//        )], toSection: .record)
        
        // 챌린지 섹션
        snapshot.appendSections([.challenge])
        if state.currentChallenges.isEmpty {
            snapshot.appendItems([.emptyState(.challenge)], toSection: .challenge)
        } else {
            let challengeItems = state.currentChallenges.map { HomeItem.challenge($0) }
            snapshot.appendItems(challengeItems, toSection: .challenge)
        }
        
        // 차트 섹션
        snapshot.appendSections([.chart])
        if state.monthlySummary.hasRecords && state.categoryTotalAmount > 0 {
            var chartItems: [HomeItem] = []
            
            // Progress 셀 추가
            chartItems.append(.chartProgress(
                totalAmount: state.categoryTotalAmount,
                items: state.categoryProgressItems
            ))
            
            let categoryItems = state.chartItems.map { HomeItem.chartCategory($0) }
            chartItems.append(contentsOf: categoryItems)
            
            snapshot.appendItems(chartItems, toSection: .chart)
        } else {
            snapshot.appendItems([.emptyState(.transaction)], toSection: .chart)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // 챌린지 갯수에 따라서 레이아웃 업뎃 필요한지 판단
    private func shouldUpdateLayout(previousCount: Int, currentCount: Int) -> Bool {
        let previous = previousCount > 1
        let current = currentCount > 1
        
        return previous != current
    }
    
    private func updateMonthButton(with date: Date) {
        monthButton.setTitle(date.monthString, for: .normal)
    }
    
    private func presentMonthPicker() {
        let currentMonth = reactor?.currentState.selectedMonth ?? Date()
        let picker = DatePickerController(title: "월 선택", date: currentMonth, mode: .yearAndMonth)
        picker.minimumDate = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1))
        picker.maximumDate = Date()
        
        picker.dateSelected = { [weak self] date in
            self?.reactor?.action.onNext(.selectMonth(date))
        }
        
        present(picker, animated: true)
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "오류",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
