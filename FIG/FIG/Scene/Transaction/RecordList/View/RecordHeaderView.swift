//
//  RecordHeaderView.swift
//  FIG
//
//  Created by Milou on 8/29/25.
//

import UIKit
import SnapKit
import Then

final class RecordHeaderView: UIView {
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
    
    private let summaryStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .firstBaseline
        $0.distribution = .equalSpacing
        $0.spacing = 4
    }
    
    private let incomeLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .footnote)
        $0.textColor = .primary
        $0.textAlignment = .right
        $0.numberOfLines = 1
    }
    
    private let expenseLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .footnote)
        $0.textColor = .gray2
        $0.textAlignment = .right
        $0.numberOfLines = 1
    }
    
    private let seperatorView = UIView().then {
        $0.backgroundColor = .gray3
    }
    
    private let spacerView = UIView().then {
        $0.backgroundColor = .clear
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
        
        addSubview(mainStackView)
        addSubview(seperatorView)
        addSubview(spacerView)
        
        mainStackView.addArrangedSubview(dateLabel)
        mainStackView.addArrangedSubview(summaryStackView)
        
        summaryStackView.addArrangedSubview(incomeLabel)
        summaryStackView.addArrangedSubview(expenseLabel)
        
        mainStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20))
        }
        
        seperatorView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
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
        
        incomeLabel.text = "+\(income.formattedWithComma)원"
        expenseLabel.text = "• -\(expense.formattedWithComma)원"
    }
    
    private func updateLayoutForContentSize() {
        let isAccessibilityCategory = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        
        if isAccessibilityCategory {
            mainStackView.axis = .vertical
            mainStackView.alignment = .leading
            mainStackView.spacing = 8
            
            summaryStackView.axis = .vertical
            summaryStackView.alignment = .leading
            summaryStackView.spacing = 4
        } else {
            mainStackView.axis = .horizontal
            mainStackView.alignment = .firstBaseline
            mainStackView.spacing = 16
            
            summaryStackView.axis = .horizontal
            summaryStackView.alignment = .firstBaseline
            summaryStackView.spacing = 4
        }
    }
}
