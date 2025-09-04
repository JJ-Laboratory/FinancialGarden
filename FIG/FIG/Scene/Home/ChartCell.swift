//
//  ChartCell.swift
//  FIG
//
//  Created by Milou on 9/3/25.
//

import UIKit
import SnapKit
import Then

final class ChartCell: UICollectionViewCell {
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    private let placeholderLabel = UILabel().then {
        $0.text = "차트"
        $0.textColor = .gray1
        $0.font = .preferredFont(forTextStyle: .body)
        $0.textAlignment = .center
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(placeholderLabel)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        placeholderLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.edges.equalToSuperview().inset(20)
        }
    }
}
