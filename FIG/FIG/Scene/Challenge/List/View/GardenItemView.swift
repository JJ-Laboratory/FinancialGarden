//
//  GardenItemView.swift
//  FIG
//
//  Created by estelle on 8/29/25.
//

import UIKit
import Then
import SnapKit

enum GardenItemType {
    case seed
    case fruit
    
    var icon: UIImage? {
        switch self {
        case .seed: return UIImage(systemName: "wonsign.circle")
        case .fruit: return UIImage(systemName: "wonsign.circle")
        }
    }
    
    var title: String {
        switch self {
        case .seed: return "씨앗"
        case .fruit: return "열매"
        }
    }
}

class GardenItemView: UIStackView {
    
    private let iconView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .gray1
        $0.font = .preferredFont(forTextStyle: .callout)
    }
    
    private let countLabel = UILabel().then {
        $0.textColor = .charcoal
        $0.font = .preferredFont(forTextStyle: .title3).withWeight(.semibold)
    }
    
    private lazy var labelStack = UIStackView(axis: .vertical, alignment: .leading, spacing: 2) {
        titleLabel
        countLabel
    }
    
    init(type: GardenItemType) {
        super.init(frame: .zero)
        
        axis = .horizontal
        spacing = 8
        alignment = .center
        
        titleLabel.text = type.title
        iconView.image = type.icon
        iconView.snp.makeConstraints { $0.width.height.equalTo(40) }
        
        [iconView, labelStack].forEach { addArrangedSubview($0) }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(count: Int) {
        countLabel.text = "\(count)개"
    }
    
    func setAxis(_ axis: NSLayoutConstraint.Axis, alignment: UIStackView.Alignment) {
        labelStack.axis = axis
        labelStack.alignment = alignment
    }
}
