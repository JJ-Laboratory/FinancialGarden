//
//  ChallengeListViewController.swift
//  FIG
//
//  Created by estelle on 8/28/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit

final class ChallengeListViewController: UIViewController, View {
    
    var disposeBag = DisposeBag()
    weak var coordinator: ChallengeCoordinator?
    private var dataSource: UICollectionViewDiffableDataSource<ChallengeSection, ChallengeItem>!
    
    private let titleLabel = UILabel().then {
        $0.text = "나의 정원"
        $0.textColor = .charcoal
        $0.font = .preferredFont(forTextStyle: .title2).withWeight(.semibold)
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout()).then {
        $0.backgroundColor = .clear
    }
    
    init(reactor: ChallengeListViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reactor?.action.onNext(.viewDidLoad)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureDataSource()
        reactor?.action.onNext(.viewDidLoad)
    }
    
    private func setupUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationController?.navigationBar.tintColor = .charcoal
        
        view.backgroundColor = .background
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func bind(reactor: ChallengeListViewReactor) {
        
        let gardenInfoDriver = reactor.state
            .map(\.gardenInfo)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
        
        let displayedChallengesDriver = reactor.state
            .map(\.displayedChallenges)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
        
        Driver.combineLatest(gardenInfoDriver, displayedChallengesDriver)
            .drive { [weak self] gardenInfo, displayedChallenges in
                self?.applySnapshot(gardenInfo: gardenInfo, challenges: displayedChallenges)
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe { [weak self] indexPath in
                let item = self?.dataSource.itemIdentifier(for: indexPath)
                guard case .challenge(let challenge) = item else { return }
                self?.coordinator?.pushChallengeDetail(challenge: challenge)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$animation)
            .compactMap { $0 }
            .subscribe { [weak self] animation in
                guard let self = self, let reactor = self.reactor else { return }
                if let gardenCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? GardenInfoCell {
                    gardenCell.configure(
                        with: GardenRecord(
                            totalSeeds: reactor.currentState.gardenInfo?.totalSeeds ?? 0,
                            totalFruits: animation.to
                        ),
                        animated: true,
                        completion: { reactor.action.onNext(.animationFinished)}
                    )
                }
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$challengeForPopup)
            .compactMap { $0 }
            .subscribe { [weak self] challenge in
                let count = (challenge.status == .success) ? challenge.targetFruitsCount : challenge.requiredSeedCount
                self?.presentPopup(status: challenge.status, count: count)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureDataSource() {
        let gardenRegistration = UICollectionView.CellRegistration<GardenInfoCell, GardenRecord> { cell, _, data in
            cell.configure(with: data)
        }
        let challengeRegistration = UICollectionView.CellRegistration<ChallengeCell, Challenge> { cell, _, data in
            cell.configure(with: data)
        }
        
        let emptyStateRegistration = UICollectionView.CellRegistration<EmptyStateCell, EmptyStateType> { cell, _, type in
            cell.configure(type: type)
        }
        
        dataSource = UICollectionViewDiffableDataSource<ChallengeSection, ChallengeItem>(collectionView: collectionView) { collectionView, indexPath, data -> UICollectionViewCell? in
            switch data {
            case .gardenInfo(let countData):
                return collectionView.dequeueConfiguredReusableCell(using: gardenRegistration, for: indexPath, item: countData)
            case .challenge(let challengeData):
                let cell = collectionView.dequeueConfiguredReusableCell(using: challengeRegistration, for: indexPath, item: challengeData)
                
                cell.onConfirmButtonTapped = { [weak self] _ in
                    self?.reactor?.action.onNext(.confirmButtonTapped(challengeData))
                }
                return cell
            case .emptyState(let type):
                let cell = collectionView.dequeueConfiguredReusableCell(using: emptyStateRegistration, for: indexPath, item: type)
                cell.pushButtonTapped
                    .subscribe { [weak self] _ in
                        self?.coordinator?.pushChallengeInput()
                    }
                    .disposed(by: cell.disposeBag)
                return cell
            }
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<ChallengeListHeaderView>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] supplementaryView, _, _ in
            guard let self = self, let reactor = reactor else { return }
            
            supplementaryView.rx.tabSelected
                .map { .selectTab($0 == 0 ? .week : .month) }
                .bind(to: reactor.action)
                .disposed(by: supplementaryView.disposeBag)
            
            supplementaryView.rx.filterSelected
                .map { .selectFilter($0) }
                .bind(to: reactor.action)
                .disposed(by: supplementaryView.disposeBag)
            
            reactor.state
                .map(\.selectedFilter.rawValue)
                .distinctUntilChanged()
                .asDriver(onErrorJustReturn: "")
                .drive(supplementaryView.filterButton.rx.title())
                .disposed(by: supplementaryView.disposeBag)
        }
        
        dataSource.supplementaryViewProvider = { collectionView, _, indexPath in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard let sectionType = ChallengeSection(rawValue: sectionIndex) else { return nil }
            
            switch sectionType {
            case .gardenInfo:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(100)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(100)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                return section
                
            case .challengeList:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(100)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(100)
                )
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 20, trailing: 20)
                section.interGroupSpacing = 20
                
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(100)
                )
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                header.pinToVisibleBounds = true
                section.boundarySupplementaryItems = [header]
                
                return section
            }
        }
    }
    
    private func applySnapshot(gardenInfo: GardenRecord?, challenges: [Challenge]) {
        guard let dataSource = dataSource else { return }
        var snapshot = NSDiffableDataSourceSnapshot<ChallengeSection, ChallengeItem>()
        snapshot.appendSections([.gardenInfo, .challengeList])
        
        if let gardenData = gardenInfo {
            snapshot.appendItems([.gardenInfo(gardenData)], toSection: .gardenInfo)
        }
        
        if challenges.isEmpty && reactor?.currentState.selectedFilter == .inProgress {
            let type: EmptyStateType = reactor?.currentState.selectedTab == .week ? .week: .month
            snapshot.appendItems([.emptyState(type)], toSection: .challengeList)
        } else {
            snapshot.appendItems(challenges.map { .challenge($0) }, toSection: .challengeList)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @objc private func addButtonTapped() {
        coordinator?.pushChallengeInput()
    }
    
    private func presentPopup(status: ChallengeStatus, count: Int) {
        let popupVC = PopupViewController(type: status, count: count)
        
        popupVC.onChallengeButtonTapped = { [weak self] in
            self?.dismiss(animated: true, completion: {
                self?.coordinator?.pushChallengeInput()
            })
        }
        popupVC.onCloseButtonTapped = { [weak self] in
            self?.dismiss(animated: true, completion: {
                self?.reactor?.action.onNext(.viewDidLoad)
            })
        }
        present(popupVC, animated: true)
    }
}
