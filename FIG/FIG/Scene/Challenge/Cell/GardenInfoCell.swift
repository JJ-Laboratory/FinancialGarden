//
//  GardenInfoCell.swift
//  FIG
//
//  Created by estelle on 8/28/25.
//

import UIKit
import Then
import SnapKit

class GardenInfoCell: UICollectionViewCell{
    
    private let seedItem = GardenItemView(type: .seed)
    private let fruitItem = GardenItemView(type: .fruit)
    
    private let dividerView = UIView().then {
        $0.backgroundColor = .gray3
    }
    
    private let infoImageView = UIImageView().then {
        $0.tintColor = .gray1
        let config = UIImage.SymbolConfiguration(textStyle: .caption2)
        $0.image = UIImage(systemName: "info.circle",withConfiguration: config)
        $0.adjustsImageSizeForAccessibilityContentSizeCategory = true
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    private let infoLabel = UILabel().then {
        $0.textColor = .gray1
        $0.numberOfLines = 0
        $0.font = .preferredFont(forTextStyle: .caption2)
        $0.text = "챌린지에 씨앗을 심으면 성공 시 열매를 수확할 수 있어요!"
    }
    
    private lazy var seedAndFruitStackView = UIStackView(axis: .horizontal, distribution: .equalSpacing, alignment: .center) {
        seedItem
        dividerView
        fruitItem
    }
    private lazy var infoStackView = UIStackView(axis: .horizontal, alignment: .center, spacing: 8) {
        infoImageView
        infoLabel
    }
    
    private lazy var mainStackView = UIStackView(axis: .vertical, alignment: .fill, spacing: 20) {
        seedAndFruitStackView
        infoStackView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 15
        
        addSubview(mainStackView)
        
        dividerView.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.height.equalTo(seedAndFruitStackView)
        }
        
        mainStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(16)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
        
        seedItem.snp.makeConstraints {
            $0.width.equalTo(fruitItem.snp.width)
        }
        
        updateLayoutForContentSize()
        
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) {
            (self: Self, _: UITraitCollection) in
            self.updateLayoutForContentSize()
        }
    }
    
    private func updateLayoutForContentSize() {
        let isAccessibilityCategory = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        
        seedAndFruitStackView.axis = isAccessibilityCategory ? .vertical: .horizontal
        
        if isAccessibilityCategory {
            dividerView.isHidden = true
            seedAndFruitStackView.alignment = .leading
            seedAndFruitStackView.spacing = 4
            seedItem.setAxis(.horizontal, alignment: .center)
            fruitItem.setAxis(.horizontal, alignment: .center)
        } else {
            dividerView.isHidden = false
            seedAndFruitStackView.alignment = .center
            seedItem.setAxis(.vertical, alignment: .leading)
            fruitItem.setAxis(.vertical, alignment: .leading)
        }
    }
    
    func configure(with: GardenRecord) {
        seedItem.configure(count: with.totlaSeeds)
        fruitItem.configure(count: with.totalFruits)
    }
}
