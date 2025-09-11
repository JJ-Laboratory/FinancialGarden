//
//  RecordItemView.swift
//  FIG
//
//  Created by Milou on 8/29/25.
//

import UIKit
import SnapKit
import Then

final class RecordItemView: UIView {
    
    private let mainStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 16
    }
    
    private let iconContainerView = UIView().then {
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
    
    var onTap: ((Transaction) -> Void)?
    private var transaction: Transaction?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupTapGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(mainStackView)
        iconContainerView.addSubview(iconImageView)
        
        mainStackView.addArrangedSubview(iconContainerView)
        mainStackView.addArrangedSubview(contentStackView)
        mainStackView.addArrangedSubview(amountLabel)
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(detailLabel)
        
        mainStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 16, right: 20))
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
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(itemTapped))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    @objc private func itemTapped() {
        guard let transaction = transaction else { return }
        onTap?(transaction)
    }
    
    func configure(with transaction: Transaction) {
        self.transaction = transaction
        
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
        
        if isAccessibilityCategory {
            mainStackView.axis = .vertical
            mainStackView.alignment = .leading
            mainStackView.spacing = 8
            amountLabel.textAlignment = .left
            
            iconContainerView.snp.updateConstraints {
                $0.size.equalTo(52)
            }
            iconImageView.snp.updateConstraints {
                $0.size.equalTo(28)
            }
            iconContainerView.layer.cornerRadius = 26
        } else {
            mainStackView.axis = .horizontal
            mainStackView.alignment = .center
            mainStackView.spacing = 16
            amountLabel.textAlignment = .right
            
            iconContainerView.snp.updateConstraints {
                $0.size.equalTo(44)
            }
            iconImageView.snp.updateConstraints {
                $0.size.equalTo(24)
            }
            iconContainerView.layer.cornerRadius = 22
        }
    }
}
