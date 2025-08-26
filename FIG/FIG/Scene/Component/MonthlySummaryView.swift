//
//  MonthlySummaryView.swift
//  FIG
//
//  Created by Milou on 8/26/25.
//

import UIKit
import SnapKit
import Then

final class MonthlySummaryView: UIView {
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    private let mainVStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.distribution = .fillEqually
    }
    
    private let expenseStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .firstBaseline
        $0.distribution = .equalSpacing
        $0.spacing = 10
    }
    
    private let expenseTitleLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .body)
        $0.adjustsFontForContentSizeCategory = true
        $0.textColor = .gray
        $0.text = "지출"
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    private let expenseAmountLabel = UILabel().then {
        $0.font = .preferredFont(for: .title2, weight: .bold)
        $0.adjustsFontForContentSizeCategory = true
        $0.textAlignment = .right
        $0.textColor = .darkGray
        $0.text = "0원"
    }
    
    private let incomeStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .firstBaseline
        $0.distribution = .equalSpacing
        $0.spacing = 10
    }
    
    private let incomeTitleLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .body)
        $0.adjustsFontForContentSizeCategory = true
        $0.textColor = .gray
        $0.text = "수입"
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    private let incomeAmountLabel = UILabel().then {
        $0.font = .preferredFont(for: .title2, weight: .bold)
        $0.adjustsFontForContentSizeCategory = true
        $0.textAlignment = .right
        $0.textColor = .primary
        $0.text = "0원"
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
        addSubview(containerView)
        containerView.addSubview(mainVStackView)
        
        mainVStackView.addArrangedSubview(expenseStackView)
        mainVStackView.addArrangedSubview(incomeStackView)
        
        expenseStackView.addArrangedSubview(expenseTitleLabel)
        expenseStackView.addArrangedSubview(expenseAmountLabel)
        
        incomeStackView.addArrangedSubview(incomeTitleLabel)
        incomeStackView.addArrangedSubview(incomeAmountLabel)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        mainVStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }
        
        updateLayoutForContentSize()
        
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) {
            (self: Self, _: UITraitCollection) in
            self.updateLayoutForContentSize()
        }
    }
    
    func configure(expense: Int, income: Int) {
        expenseAmountLabel.text = expense.formattedWithComma + "원"
        incomeAmountLabel.text = income.formattedWithComma + "원"
    }
    
    private func updateLayoutForContentSize() {
        let isAccessibilityCategory = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        
        expenseStackView.axis = isAccessibilityCategory ? .vertical: .horizontal
        incomeStackView.axis = isAccessibilityCategory ? .vertical: .horizontal
        
        if isAccessibilityCategory {
            expenseStackView.alignment = .leading
            incomeStackView.alignment = .leading
            expenseStackView.spacing = 4
            incomeStackView.spacing = 4
        } else {
            expenseStackView.alignment = .firstBaseline
            incomeStackView.alignment = .firstBaseline
            expenseStackView.spacing = 10
            incomeStackView.spacing = 10
        }
    }
}
