//
//  RecordHeaderCell.swift
//  FIG
//
//  Created by Milou on 8/29/25.
//

import UIKit
import SnapKit
import Then

final class SectionHeaderCell: UICollectionViewCell {
    
    private let titleLabel = UILabel().then {
        $0.text = "전체 내역"
        $0.font = .preferredFont(forTextStyle: .headline)
        $0.textColor = .charcoal
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
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

final class RecordHeaderCell: UICollectionViewCell {
    private let mainStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .firstBaseline
        $0.distribution = .equalSpacing
        $0.spacing = 16
    }
    
    private let dateLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .subheadline)
        $0.textColor = .systemGray
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    private let summaryLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .caption1)
        $0.textColor = .systemGray
        $0.textAlignment = .right
        $0.numberOfLines = 0
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
        backgroundColor = .white
        
        contentView.addSubview(mainStackView)
        
        mainStackView.addArrangedSubview(dateLabel)
        mainStackView.addArrangedSubview(summaryLabel)
        
        mainStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
        
        updateLayoutForContentSize()
        
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) {
            (self: Self, _: UITraitCollection) in
            self.updateLayoutForContentSize()
        }
    }
    
    func configure(date: Date, income: Int, expense: Int) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "d일 EEEE"
        dateLabel.text = formatter.string(from: date)
        
        var summaryParts: [String] = []
        
        // TODO: .primary
        if income > 0 {
            summaryParts.append("+\(income.formattedWithComma)원")
        }
        if expense > 0 {
            summaryParts.append("-\(expense.formattedWithComma)원")
        }
        
        summaryLabel.text = summaryParts.joined(separator: " ・ ")
    }
    
    private func updateLayoutForContentSize() {
        let isAccessibilityCategory = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        
        mainStackView.axis = isAccessibilityCategory ? .vertical : .horizontal
        
        if isAccessibilityCategory {
            mainStackView.alignment = .leading
            mainStackView.spacing = 4
            summaryLabel.textAlignment = .left
        } else {
            mainStackView.alignment = .firstBaseline
            mainStackView.spacing = 16
            summaryLabel.textAlignment = .right
        }
    }
}
