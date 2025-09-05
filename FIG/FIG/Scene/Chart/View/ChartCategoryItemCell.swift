//
//  ChartCategoryItemCell.swift
//  FIG
//
//  Created by Milou on 9/2/25.
//

import UIKit
import SnapKit
import Then

final class ChartCategoryItemCell: UICollectionViewCell {
    let iconContainerView = UIView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 22
    }
    
    let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        $0.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
        $0.setContentCompressionResistancePriority(UILayoutPriority(1), for: .vertical)
        $0.setContentCompressionResistancePriority(UILayoutPriority(1), for: .horizontal)
    }
    
    let nameLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .body)
        $0.textColor = .charcoal
    }
    
    let rateLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .caption1)
        $0.textColor = .gray1
    }
    
    let totalValueLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .body).withWeight(.semibold)
        $0.textColor = .charcoal
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    let changedValueLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .caption1)
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let stackView = UIStackView(axis: .vertical, spacing: 4) {
            UIStackView(axis: .horizontal, spacing: 4) {
                nameLabel
                totalValueLabel
            }
            UIStackView(axis: .horizontal, spacing: 4) {
                rateLabel
                changedValueLabel
            }
        }
        
        iconContainerView.addSubview(imageView)
        contentView.addSubview(iconContainerView)
        contentView.addSubview(stackView)
        
        iconContainerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.bottom.equalTo(stackView)
            $0.size.equalTo(44)
        }
        
        imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        stackView.snp.makeConstraints {
            $0.leading.equalTo(iconContainerView.snp.trailing).offset(10)
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: CategoryChartItem) {
        imageView.image = item.category.icon
        imageView.tintColor = item.iconColor
        iconContainerView.backgroundColor = item.backgroundColor
        nameLabel.text = item.category.title
        rateLabel.text = "\(item.percentage)%"
        totalValueLabel.text = "\(item.amount.formattedWithComma)원"
        
        let isIncrease = item.changed >= 0
        changedValueLabel.text = "\(isIncrease ? "▲" : "▼") \(abs(item.changed).formattedWithComma)원"
        changedValueLabel.textColor = isIncrease ? .secondary : .gray1
    }
}
