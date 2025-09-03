//
//  ChartSummaryHeaderView.swift
//  FIG
//
//  Created by estelle on 9/2/25.
//

import UIKit
import Then
import SnapKit

final class ChartSummaryHeaderView: UICollectionViewCell {
    let chartView = TransactionBarChart(numberOfSegments: 6).then {
        $0.contentInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        let titleLabel = UILabel().then {
            $0.text = "최근 6개월"
            $0.font = .preferredFont(forTextStyle: .body)
            $0.textColor = .charcoal
            $0.setContentHuggingPriority(UILayoutPriority(249), for: .horizontal)
            $0.setContentCompressionResistancePriority(UILayoutPriority(749), for: .horizontal)
        }
        let incomeLegend = LegendView(color: .primary, title: "수입")
        let expenseLegend = LegendView(color: .secondary, title: "지출")
        let titleStackView = UIStackView(axis: .vertical, spacing: 15) {
            UIStackView(axis: .horizontal, alignment: .center, spacing: 15) {
                titleLabel
                incomeLegend
                expenseLegend
            }
            UIView().then {
                $0.backgroundColor = .gray3
                $0.snp.makeConstraints {
                    $0.height.equalTo(1)
                }
            }
        }
        contentView.addSubview(titleStackView)
        contentView.addSubview(chartView)

        titleStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.trailing.equalToSuperview()
        }
        chartView.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(chartView.snp.width).multipliedBy(0.78)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChartSummaryHeaderView {
    private class LegendView: UIView {
        let indicatorView = UIView().then {
            $0.layer.cornerRadius = 2
        }
        let titleLabel = UILabel().then {
            $0.font = .preferredFont(forTextStyle: .caption1)
            $0.textColor = .charcoal
        }
        
        init(color: UIColor, title: String) {
            super.init(frame: .zero)
            indicatorView.backgroundColor = color
            titleLabel.text = title

            addSubview(indicatorView)
            addSubview(titleLabel)

            indicatorView.snp.makeConstraints {
                $0.leading.equalToSuperview()
                $0.top.bottom.equalTo(titleLabel).inset(2)
                $0.width.equalTo(indicatorView.snp.height)
            }
            titleLabel.snp.makeConstraints {
                $0.leading.equalTo(indicatorView.snp.trailing).offset(5)
                $0.top.bottom.trailing.equalToSuperview()
            }
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

#Preview {
    ChartSummaryHeaderView().then {
        let size = $0.systemLayoutSizeFitting(
            CGSize(width: 360, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        $0.snp.makeConstraints {
            $0.size.equalTo(size)
        }
        $0.chartView.setItems(
            [
                .transaction(label: "1", income: 1_000_000, expense: 200_000),
                .transaction(label: "2", income: 2_000_000, expense: 400_000),
                .transaction(label: "3", income: 3_000_000, expense: 600_000),
                .transaction(label: "4", income: 4_000_000, expense: 800_000),
                .transaction(label: "5", income: 5_000_000, expense: 1_000_000),
                .transaction(label: "6", income: 6_000_000, expense: 1_200_000)
            ],
            animated: true
        )
    }
}
