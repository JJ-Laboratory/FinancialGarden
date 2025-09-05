//
//  UIStackView+.swift
//  FIG
//
//  Created by Milou on 8/28/25.
//

import UIKit

extension UIStackView {
    
    /// 배열을 직접 파라미터로 받는 편의 초기화 메서드
    convenience init(
        axis: NSLayoutConstraint.Axis,
        distribution: UIStackView.Distribution = .fill,
        alignment: UIStackView.Alignment = .fill,
        spacing: CGFloat = 0,
        margins: NSDirectionalEdgeInsets? = nil,
        arrangedSubviews: [UIView]? = nil
    ) {
        self.init(frame: .zero)
        self.axis = axis
        self.distribution = distribution
        self.alignment = alignment
        self.spacing = spacing
        arrangedSubviews?.forEach(addArrangedSubview(_:))
        if let margins {
            directionalLayoutMargins = margins
            isLayoutMarginsRelativeArrangement = true
        }
    }
    
    /// @resultBuilder를 활용해 선언적 방식으로 서브뷰들을 받아 UIStackView 생성
    convenience init(
        axis: NSLayoutConstraint.Axis,
        distribution: UIStackView.Distribution = .fill,
        alignment: UIStackView.Alignment = .fill,
        spacing: CGFloat = 0,
        margins: NSDirectionalEdgeInsets? = nil,
        @ArrayBuilder<UIView> build: () -> [UIView]
    ) {
        self.init(
            axis: axis,
            distribution: distribution,
            alignment: alignment,
            spacing: spacing,
            margins: margins,
            arrangedSubviews: build()
        )
    }
}
