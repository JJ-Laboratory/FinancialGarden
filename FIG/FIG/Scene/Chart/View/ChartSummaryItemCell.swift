//
//  ChartSummaryCell.swift
//  FIG
//
//  Created by estelle on 9/3/25.
//

import UIKit
import SnapKit
import Then

final class ChartSummaryItemCell: UICollectionViewCell {
    let monthLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .body)
        $0.textColor = .charcoal
    }
    
    let balanceLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .body).withWeight(.semibold)
        $0.textColor = .charcoal
    }
    
    let increaseAmountLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .caption1)
        $0.textColor = .primary
    }
    
    let decreaseAmountLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .caption1)
        $0.textColor = .gray1
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let stackView = UIStackView(axis: .horizontal, spacing: 10) {
            monthLabel
            UIStackView(axis: .vertical, alignment: .trailing, spacing: 4) {
                UIStackView(axis: .horizontal, spacing: 4) {
                    increaseAmountLabel
                    decreaseAmountLabel
                }
                balanceLabel
            }
        }
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    ChartSummaryItemCell().then {
        $0.monthLabel.text = "1월"
        $0.increaseAmountLabel.text = "+2,350,000원"
        $0.decreaseAmountLabel.text = "+-645,000원"
        $0.balanceLabel.text = "잔고 1,705,000원"
        let size = $0.systemLayoutSizeFitting(
            CGSize(width: 360, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        $0.snp.makeConstraints {
            $0.size.equalTo(size)
        }
    }
}
