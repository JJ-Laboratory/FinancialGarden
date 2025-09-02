//
//  ChartCategoryProgressCell.swift
//  FIG
//
//  Created by Milou on 9/2/25.
//

import UIKit
import SnapKit
import Then

final class ChartCategoryProgressCell: UICollectionViewCell {
    let amountLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .body).withWeight(.semibold)
        $0.textColor = .charcoal
    }

    let progressView = ChartProgressView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        let stackView = UIStackView(axis: .horizontal, spacing: 20) {
            UILabel().then {
                $0.text = "총 금액"
                $0.font = .preferredFont(forTextStyle: .body).withWeight(.semibold)
                $0.textColor = .gray1
            }
            amountLabel
        }

        contentView.addSubview(stackView)
        contentView.addSubview(progressView)

        stackView.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview()
        }

        progressView.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(24)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    ChartCategoryProgressCell().then {
        $0.amountLabel.text = "\(18882713.formattedWithComma)원"
        $0.progressView.items = [
            .item(value: 1, color: .gray2),
            .item(value: 4, color: .secondary),
            .item(value: 2, color: .primary),
            .item(value: 2, color: .pink)
        ]
        let size = $0.systemLayoutSizeFitting(
            CGSize(width: 320, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        $0.snp.makeConstraints { $0.size.equalTo(size) }
    }
}
