//
//  RecordListViewController.swift
//  FIG
//
//  Created by Milou on 8/29/25.
//

import UIKit
import SnapKit
import Then

final class RecordListViewController: UIViewController {
    
    weak var coordinator: TransactionCoordinator?
    
    enum Section: Int, CaseIterable {
        case summary = 0
        case sectionHeader = 1
        case records = 2
    }
    
    struct RecordGroup {
        let date: Date
        let transactions: [Transaction]
    }
    
    // MARK: - UI Components
    
    private let monthButton = UIButton(type: .system).then {
        $0.titleLabel?.font = .preferredFont(forTextStyle: .title2).withWeight(.semibold)
        $0.setTitleColor(.label, for: .normal)
        $0.semanticContentAttribute = .forceRightToLeft
        $0.setImage(UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)), for: .normal)
        $0.tintColor = .charcoal
        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .background
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private var selectedMonth = Date()
    var recordGroups: [RecordGroup] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupCollectionView()
        setupMockData()
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
        monthButton.addTarget(self, action: #selector(monthButtonTapped), for: .touchUpInside)
        
        let monthBarButtonItem = UIBarButtonItem(customView: monthButton)
        navigationItem.leftBarButtonItem = monthBarButtonItem
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationItem.rightBarButtonItem = addButton
        
        updateMonthButton()
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        
        collectionView.register(MonthlySummaryCell.self, forCellWithReuseIdentifier: MonthlySummaryCell.identifier)
        collectionView.register(SectionHeaderCell.self, forCellWithReuseIdentifier: SectionHeaderCell.identifier)
        collectionView.register(RecordGroupCell.self, forCellWithReuseIdentifier: RecordGroupCell.identifier)
        
        collectionView.collectionViewLayout.register(GroupBackgroundView.self, forDecorationViewOfKind: GroupBackgroundView.elementKind)
    }
    
    private func updateMonthButton() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월"
        monthButton.setTitle(formatter.string(from: selectedMonth), for: .normal)
    }
    
    // TODO: 현재 날짜 포함된 달까지만 뜨도록
    @objc private func monthButtonTapped() {
        let picker = DatePickerController(title: "월 선택", mode: .yearAndMonth)
        picker.dateSelected = { [weak self] date in
            self?.selectedMonth = date
            self?.updateMonthButton()
        }
        
        present(picker, animated: true)
    }
    
    @objc private func addButtonTapped() {
        coordinator?.pushTransactionInput()
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
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        
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
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 16, trailing: 20)
        section.interGroupSpacing = 16
        
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

extension RecordListViewController {
    private func setupMockData() {
        let calendar = Calendar.current
        let today = Date()
        let categories = createSampleCategories()
        
        var groups: [RecordGroup] = []
        
        // 8월 18일 거래들
        if let date1 = calendar.date(byAdding: .day, value: -11, to: today) {
            let transactions1 = [
                Transaction(amount: 5560, category: categories[0], title: "스타벅스", payment: .card, date: date1),
                Transaction(amount: 5560, category: categories[0], title: "스타벅스", payment: .card, date: date1),
                Transaction(amount: 100000, category: categories[1], title: "알바", payment: .account, date: date1)
            ]
            groups.append(RecordGroup(date: date1, transactions: transactions1))
        }
        
        // 8월 17일 거래들
        if let date2 = calendar.date(byAdding: .day, value: -12, to: today) {
            let transactions2 = [
                Transaction(amount: 5560, category: categories[0], title: "스타벅스", payment: .card, date: date2),
                Transaction(amount: 5560, category: categories[0], title: "스타벅스", payment: .card, date: date2),
                Transaction(amount: 100000, category: categories[1], title: "알바", payment: .account, date: date2)
            ]
            groups.append(RecordGroup(date: date2, transactions: transactions2))
        }
        
        recordGroups = groups
        collectionView.reloadData()
    }

    private func createSampleCategories() -> [Category] {
        return [
            Category(id: UUID(), title: "카페・간식", iconName: "cup.and.heat.waves.fill", transactionType: .expense),
            Category(id: UUID(), title: "급여", iconName: "wonsign.arrow.trianglehead.counterclockwise.rotate.90", transactionType: .income)
        ]
    }
}

@available(iOS 17.0, *)
#Preview {
    RecordListViewController()
}
