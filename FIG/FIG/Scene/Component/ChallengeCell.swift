//
//  CallengeCell.swift
//  FIG
//
//  Created by estelle on 8/27/25.
//

import UIKit
import SnapKit
import Then

class ChallengeCell: UICollectionViewCell {
    
    private let titleLabel = UILabel().then {
        $0.textColor = .charcoal
        $0.numberOfLines = 0
        $0.font = .preferredFont(forTextStyle: .body)
        $0.adjustsFontForContentSizeCategory = true
    }
    
    private let dDayLabel = UILabel().then {
        $0.textColor = .primary
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
        $0.textAlignment = .center
        $0.backgroundColor = .lightPink
        $0.font = .preferredFont(forTextStyle: .caption1)
        $0.adjustsFontForContentSizeCategory = true
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private let dateIcon = UIImageView().then {
        $0.tintColor = .gray1
        let config = UIImage.SymbolConfiguration(textStyle: .subheadline)
        $0.image = UIImage(systemName: "calendar", withConfiguration: config)
        $0.adjustsImageSizeForAccessibilityContentSizeCategory = true
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    private let dateLabel = UILabel().then {
        $0.textColor = .gray1
        $0.numberOfLines = 0
        $0.font = .preferredFont(forTextStyle: .subheadline)
        $0.adjustsFontForContentSizeCategory = true
    }
    
    private let amountIcon = UIImageView().then {
        $0.tintColor = .gray1
        let config = UIImage.SymbolConfiguration(textStyle: .subheadline)
        $0.image = UIImage(systemName: "wonsign.circle", withConfiguration: config)
        $0.adjustsImageSizeForAccessibilityContentSizeCategory = true
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    private let amountLabel = UILabel().then {
        let text = NSMutableAttributedString(
            string: "1,200,793원",
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor.secondary
            ]
        )
        text.append(NSAttributedString(
            string: " / 1,300,000원",
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .subheadline),
                .foregroundColor: UIColor.gray1
            ]
        ))
        $0.attributedText = text
        $0.numberOfLines = 0
        $0.adjustsFontForContentSizeCategory = true
    }
    
    private let statusImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let progressView = UIProgressView().then {
        $0.progressViewStyle = .default
        $0.progressTintColor = .primary
        $0.trackTintColor = .background
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    private let messageLabel = UILabel().then {
        $0.textColor = .gray1
        $0.numberOfLines = 0
        $0.font = .preferredFont(forTextStyle: .footnote)
        $0.adjustsFontForContentSizeCategory = true
    }
    
    private let confirmButton = CustomButton(style: .filled).then {
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private lazy var titleStackView = UIStackView(arrangedSubviews: [titleLabel, dDayLabel]).then {
        $0.spacing = 8
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalCentering
    }
    
    private lazy var dateStackView = UIStackView(arrangedSubviews: [dateIcon, dateLabel]).then {
        $0.spacing = 8
        $0.axis = .horizontal
        $0.alignment = .center
    }
    
    private lazy var amountStackView = UIStackView(arrangedSubviews: [amountIcon, amountLabel]).then {
        $0.spacing = 8
        $0.axis = .horizontal
        $0.alignment = .center
    }
    
    private lazy var dateAndAmountStackView = UIStackView(arrangedSubviews: [dateStackView, amountStackView]).then {
        $0.spacing = 8
        $0.axis = .vertical
        $0.alignment = .leading
    }
    
    private lazy var contentStackView = UIStackView(arrangedSubviews: [dateAndAmountStackView, statusImageView]).then {
        $0.spacing = 8
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalCentering
    }
    
    private lazy var bottomStackView = UIStackView(arrangedSubviews: [messageLabel, confirmButton]).then {
        $0.spacing = 8
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalCentering
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 16
        
        [titleStackView, contentStackView, progressView, bottomStackView].forEach {
            contentView.addSubview($0)
        }
        
        titleStackView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(15)
        }
        
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(15)
        }
        
        progressView.snp.makeConstraints {
            $0.top.equalTo(contentStackView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(20)
        }
        
        bottomStackView.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview().inset(15)
        }
        
        updateLayoutForContentSize()
        
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) {
            (self: Self, _: UITraitCollection) in
            self.updateLayoutForContentSize()
        }
    }
    
    private func updateLayoutForContentSize() {
        let isAccessibilityCategory = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        
        bottomStackView.axis = isAccessibilityCategory ? .vertical: .horizontal
        contentStackView.axis = isAccessibilityCategory ? .vertical: .horizontal
        
        if isAccessibilityCategory {
            statusImageView.snp.makeConstraints {
                $0.width.height.equalTo(80).priority(999)
            }
            contentStackView.alignment = .fill
        } else {
            statusImageView.snp.makeConstraints {
                $0.width.height.equalTo(50).priority(999)
            }
        }
    }
    
    // MARK: - Configuration
    
    func configure() {
        titleLabel.text = "의료・건강・피트니스"
        dDayLabel.text = "D-3"
        dateLabel.text = "2025.8.27 ~ 8.30"
        
        let text = NSMutableAttributedString(
            string: "1,200,793원",
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor.secondary
            ]
        )
        text.append(NSAttributedString(
            string: " / 1,300,000원",
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .subheadline),
                .foregroundColor: UIColor.gray1
            ]
        ))
        amountLabel.attributedText = text
        
        statusImageView.image = UIImage(systemName: "wonsign.circle")
        
        let progress = Float(4) / Float(7)
        progressView.setProgress(progress, animated: true)
        
        messageLabel.text = "앗 목표 소비 금액을 초과했네요😥\n확인을 누르고 다음 기회에 도전해보세요!"
        confirmButton.setTitle("확인", for: .normal)
    }
}
