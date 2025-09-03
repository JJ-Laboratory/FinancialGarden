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
        contentView.addSubview(imageView)
        contentView.addSubview(stackView)
        
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.bottom.equalTo(stackView)
            $0.width.equalTo(imageView.snp.height)
        }
        
        stackView.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(10)
            $0.top.bottom.trailing.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
