//
//  ChartCategoryHeaderView.swift
//  FIG
//
//  Created by Milou on 9/2/25.
//

import UIKit
import SnapKit
import Then

final class ChartCategoryHeaderView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        let stackView = UIStackView(axis: .vertical, spacing: 10) {
            UIStackView(axis: .horizontal, spacing: 10) {
                UILabel().then {
                    $0.text = "카테고리별 금액"
                    $0.font = .preferredFont(forTextStyle: .body)
                    $0.textColor = .charcoal
                }
                UIStackView(axis: .vertical, alignment: .trailing) {
                    UILabel().then {
                        $0.text = "총액"
                        $0.font = .preferredFont(forTextStyle: .caption1)
                        $0.textColor = .charcoal
                        $0.setContentHuggingPriority(.required, for: .horizontal)
                        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
                    }
                    UILabel().then {
                        $0.text = "지난달 대비"
                        $0.font = .preferredFont(forTextStyle: .caption1)
                        $0.textColor = .gray1
                        $0.setContentHuggingPriority(.required, for: .horizontal)
                        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
                    }
                }
            }
            UIView().then {
                $0.backgroundColor = .gray3
                $0.snp.makeConstraints {
                    $0.height.equalTo(1)
                }
            }
        }
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
