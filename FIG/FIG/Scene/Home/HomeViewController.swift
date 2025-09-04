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
    
    init(reactor: HomeViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor?.action.onNext(.refresh)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupCollectionView()
        setupDataSource()
        
        reactor?.action.onNext(.viewDidLoad)
    }
    
    func bind(reactor: HomeViewReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    private func bindAction(_ reactor: HomeViewReactor) {
        monthButton.rx.tap
            .subscribe { [weak self] _ in
                self?.presentMonthPicker()
            }
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: HomeViewReactor) {
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
        dataSource = UICollectionViewDiffableDataSource<HomeSection, HomeItem>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in
            return self?.configureCell(collectionView: collectionView, indexPath: indexPath, item: item)
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            return self?.configureHeader(collectionView: collectionView, kind: kind, indexPath: indexPath)
        }    }
    
    private func configureCell(collectionView: UICollectionView, indexPath: IndexPath, item: HomeItem) -> UICollectionViewCell? {
        
        switch item {
        case .monthlySummary(let expense, let income):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MonthlySummaryCell.identifier, for: indexPath) as? MonthlySummaryCell else {
                return UICollectionViewCell()
            }
            cell.configure(expense: expense, income: income)
            return cell
            
        case .challenge(let challenge):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChallengeCell.identifier, for: indexPath) as? ChallengeCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: challenge, isHomeMode: true)  // 홈모드로 설정
            return cell
            
        case .emptyState(let type):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyStateCell.identifier, for: indexPath) as? EmptyStateCell else {
                return UICollectionViewCell()
            }
            cell.configure(type: type)
            
            cell.pushButtonTapped
                .subscribe { [weak self] _ in
                    self?.reactor?.action.onNext(.emptyStateButtonTapped(type))
                }
                .disposed(by: cell.disposeBag)
            
            return cell
            
        case .chartProgress(let totalAmount, let items):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChartCategoryProgressCell.identifier, for: indexPath) as? ChartCategoryProgressCell else {
                return UICollectionViewCell()
            }
            cell.amountLabel.text = "\(totalAmount.formattedWithComma)원"
            cell.progressView.items = items
            return cell
            
        case .chartCategory(let item):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChartCategoryItemCell.identifier, for: indexPath) as? ChartCategoryItemCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(with: item)
            return cell
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
    
    private func updateSnapshot(with state: HomeViewReactor.State) {
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
        snapshot.appendItems([.monthlySummary(expense: state.monthlyExpense, income: state.monthlyIncome)], toSection: .record)
        
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
        if state.hasRecords && state.categoryTotalAmount > 0 {
            var chartItems: [HomeItem] = []
            
            // Progress 셀 추가
            chartItems.append(.chartProgress(
                totalAmount: state.categoryTotalAmount,
                items: state.categoryProgressItems
            ))
            
            // 상위 4개 카테고리 아이템 추가
            let topCategories = Array(state.chartItems.prefix(4))
            let categoryItems = topCategories.enumerated().map { index, item in
                let coloredItem = item.withColor(ChartColor.rank(index))
                return HomeItem.chartCategory(coloredItem)
            }
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
        let picker = DatePickerController(title: "월 선택", mode: .yearAndMonth)
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
