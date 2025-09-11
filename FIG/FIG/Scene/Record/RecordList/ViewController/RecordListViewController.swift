//
//  RecordListViewController.swift
//  FIG
//
//  Created by Milou on 8/29/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit

final class RecordListViewController: UIViewController, View {
    
    weak var coordinator: RecordCoordinator?
    var disposeBag = DisposeBag()
    
    enum Section: Int, CaseIterable {
        case summary = 0
        case sectionHeader = 1
        case records = 2
    }
    
    // MARK: - UI Components
    
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
        collectionView.backgroundColor = .background
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    typealias RecordGroup = RecordListReactor.RecordGroup
    
    init(reactor: RecordListReactor) {
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
        
        reactor?.action.onNext(.viewDidLoad)
    }
    
    func bind(reactor: RecordListReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    private func bindAction(_ reactor: RecordListReactor) {
        monthButton.rx.tap
            .subscribe { [weak self] _ in
                self?.presentMonthPicker()
            }
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: RecordListReactor) {
        reactor.state.map(\.selectedMonth)
            .distinctUntilChanged()
            .subscribe { [weak self] date in
                self?.updateMonthButton(with: date)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map(\.recordGroups)
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            reactor.state.map(\.monthlySummary.expense).distinctUntilChanged(),
            reactor.state.map(\.monthlySummary.income).distinctUntilChanged()
        )
        .observe(on: MainScheduler.instance)
        .subscribe { [weak self] _, _ in
            let summaryIndexSet = IndexSet(integer: Section.summary.rawValue)
            self?.collectionView.reloadSections(summaryIndexSet)
        }
        .disposed(by: disposeBag)
        
        reactor.state.compactMap(\.error)
            .subscribe { [weak self] error in
                self?.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        view.backgroundColor = .background
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupNavigationBar() {
        let monthBarButtonItem = UIBarButtonItem(customView: monthButton)
        navigationItem.leftBarButtonItem = monthBarButtonItem
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        
        collectionView.register(MonthlySummaryCell.self, forCellWithReuseIdentifier: MonthlySummaryCell.identifier)
        collectionView.register(SectionHeaderCell.self, forCellWithReuseIdentifier: SectionHeaderCell.identifier)
        collectionView.register(RecordGroupCell.self, forCellWithReuseIdentifier: RecordGroupCell.identifier)
        collectionView.register(EmptyStateCell.self, forCellWithReuseIdentifier: EmptyStateCell.identifier)
        collectionView.collectionViewLayout.register(GroupBackgroundView.self, forDecorationViewOfKind: GroupBackgroundView.elementKind)
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
    
    @objc private func addButtonTapped() {
        coordinator?.pushRecordForm()
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

extension RecordListViewController {
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let section = Section(rawValue: sectionIndex) else { return nil }
            
            switch section {
            case .summary:
                return self?.createSummarySection()
            case .sectionHeader:
                return self?.createSectionHeaderSection()
            case .records:
                return self?.createRecordsSection()
            }
        }
    }
    
    private func createSummarySection() -> NSCollectionLayoutSection {
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
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 16, trailing: 20)
        
        return section
    }
    
    // 전체내역
    private func createSectionHeaderSection() -> NSCollectionLayoutSection {
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
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 10, trailing: 20)
        
        return section
    }
    
    private func createRecordsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
        section.interGroupSpacing = 20
        
        return section
    }
}

final class GroupBackgroundView: UICollectionReusableView {
    static let elementKind = "GroupBackgroundView"
    
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
