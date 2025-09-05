//
//  ItemPickerController.swift
//  FIG
//
//  Created by Milou on 8/27/25.
//

import UIKit
import SnapKit
import Then

final class ItemPickerController<Item: Hashable>: PickerController {
    private let items: [Item]
    private let selectedItem: Item?
    private let itemImage: (Item) -> UIImage?
    private let itemTitle: (Item) -> String?
    private let itemBackgroundColor: (Item) -> UIColor?
    private let itemIconColor: (Item) -> UIColor?
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: CollectionViewLayout()).then {
        $0.showsVerticalScrollIndicator = false
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
    }
    
    private lazy var dataSource = makeDataSource(collectionView)
    
    var itemSelected: ((Item) -> Void)?
    
    init<S: Sequence>(
        title: String,
        items: S,
        selectedItem: Item?,
        contentHeight: CGFloat,
        itemImage: @escaping (Item) -> UIImage?,
        itemTitle: @escaping (Item) -> String?,
        itemBackgroundColor: @escaping (Item) -> UIColor?,
        itemIconColor: @escaping (Item) -> UIColor?
    ) where S.Element == Item  {
        self.items = Array(items)
        self.selectedItem = selectedItem
        self.itemImage = itemImage
        self.itemTitle = itemTitle
        self.itemBackgroundColor = itemBackgroundColor
        self.itemIconColor = itemIconColor
        super.init(title: title, contentHeight: contentHeight, contentView: collectionView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        dataSource.apply(snapshot) { [unowned self] in
            if let index = items.firstIndex(where: { $0 == selectedItem }) {
                let indexPath = IndexPath(item: index, section: 0)
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
            }
        }
        
        let applyAction = UIAction { [unowned self] _ in
            if let itemSelected, let selectedIndexPath = collectionView.indexPathsForSelectedItems.flatMap(\.first) {
                itemSelected(items[selectedIndexPath.item])
            }
            dismiss(animated: true)
        }
        applyButton.addAction(applyAction, for: .primaryActionTriggered)
    }
    
    private func makeDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, Item> {
        let cellRegistration = UICollectionView.CellRegistration<ItemCell, Item> {
            [itemImage, itemTitle, itemBackgroundColor, itemIconColor] cell, _, item in
            cell.imageView.image = itemImage(item)
            cell.imageBackgroundView.backgroundColor = itemBackgroundColor(item)
            cell.imageView.tintColor = itemIconColor(item)
            cell.titleLabel.text = itemTitle(item)
        }
        return UICollectionViewDiffableDataSource(collectionView: collectionView) {
            collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
}

// MARK: - ItemPickerController.CollectionViewLayout

extension ItemPickerController {
    private class CollectionViewLayout: UICollectionViewCompositionalLayout {
        convenience init() {
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(44)
                )
            )
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(44)
                ),
                subitems: [item]
            )
            let section = NSCollectionLayoutSection(group: group).then {
                $0.interGroupSpacing = 16
            }
            self.init(section: section)
        }
    }
}

// MARK: - ItemPickerController.ItemCell

extension ItemPickerController {
    private class ItemCell: UICollectionViewCell {
        let imageBackgroundView = UIView()
        
        let imageView = UIImageView().then {
            $0.preferredSymbolConfiguration = UIImage.SymbolConfiguration(weight: .bold)
            $0.contentMode = .scaleAspectFit
        }
        
        let titleLabel = UILabel().then {
            $0.font = .preferredFont(forTextStyle: .body)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
        }
        
        let checkImageView = UIImageView(image: UIImage(systemName: "checkmark")).then {
            $0.contentMode = .scaleAspectFill
            $0.isHidden = true
            $0.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .body))
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        
        override var isSelected: Bool {
            didSet {
                checkImageView.isHidden = !isSelected
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(imageBackgroundView)
            imageBackgroundView.snp.makeConstraints {
                $0.top.leading.bottom.equalToSuperview()
                $0.width.equalTo(imageBackgroundView.snp.height)
            }
            
            contentView.addSubview(imageView)
            imageView.snp.makeConstraints {
                $0.directionalEdges.equalTo(imageBackgroundView).inset(10)
            }
            
            contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints {
                $0.leading.equalTo(imageBackgroundView.snp.trailing).offset(10)
                $0.top.bottom.equalToSuperview().inset(12)
            }
            
            contentView.addSubview(checkImageView)
            checkImageView.snp.makeConstraints {
                $0.leading.equalTo(titleLabel.snp.trailing).offset(10)
                $0.trailing.equalToSuperview()
                $0.centerY.equalToSuperview()
            }
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            imageBackgroundView.layer.cornerRadius = bounds.height * 0.5
        }
    }
}
