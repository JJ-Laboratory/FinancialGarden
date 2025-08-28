//
//  RecordCell.swift
//  FIG
//
//  Created by Milou on 8/29/25.
//

import UIKit
import SnapKit
import Then

final class RecordCell: UITableViewCell {
    private let mainStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
    }
    
    private let iconContainerView = UIView().then {
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.spacing = 2
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .body)
        $0.textColor = .charcoal
        $0.numberOfLines = 1
    }
    
    private let detailLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .footnote)
        $0.textColor = .gray1
        $0.numberOfLines = 1
    }
    
    private let amountLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .body).withWeight(.bold)
        $0.textAlignment = .right
        $0.numberOfLines = 1
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        selectionStyle = .none
        
        contentView.addSubview(mainStackView)
        iconContainerView.addSubview(iconImageView)
        
        mainStackView.addArrangedSubview(iconContainerView)
        mainStackView.addArrangedSubview(contentStackView)
        mainStackView.addArrangedSubview(amountLabel)
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(detailLabel)
        
        mainStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        iconContainerView.snp.makeConstraints {
            $0.size.equalTo(44)
        }
        
        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        updateLayoutForContentSize()
        
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) {
            (self: Self, _: UITraitCollection) in
            self.updateLayoutForContentSize()
        }
    }
    
    func configure(with transaction: Transaction) {
        titleLabel.text = transaction.title
        
        detailLabel.text = "\(transaction.category.title) | \(transaction.payment.title)"
        
        iconImageView.image = transaction.category.icon
        iconImageView.tintColor = transaction.category.iconColor
        iconContainerView.backgroundColor = transaction.category.backgroundColor
        
        let formattedAmount = transaction.amount.formattedWithComma + "원"
        if transaction.category.transactionType == .income {
            amountLabel.text = "+\(formattedAmount)"
            amountLabel.textColor = .primary
        } else {
            amountLabel.text = "-\(formattedAmount)"
            amountLabel.textColor = .charcoal
        }
    }
    
    private func updateLayoutForContentSize() {
        let isAccessibilityCategory = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        
        mainStackView.axis = isAccessibilityCategory ? .vertical : .horizontal
        
        if isAccessibilityCategory {
            mainStackView.alignment = .leading
            mainStackView.spacing = 8
            amountLabel.textAlignment = .left
        } else {
            mainStackView.alignment = .center
            mainStackView.spacing = 12
            amountLabel.textAlignment = .right
        }
    }
}
