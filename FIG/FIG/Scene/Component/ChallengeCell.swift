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
    
    var onConfirmButtonTapped: ((ChallengeStatus) -> Void)?
    private var currentStatus: ChallengeStatus?
    
    private let titleLabel = UILabel().then {
        $0.textColor = .charcoal
        $0.numberOfLines = 0
        $0.font = .preferredFont(forTextStyle: .body).withWeight(.semibold)
    }
    
    private let dDayLabel = UILabel().then {
        $0.textColor = .primary
        $0.textAlignment = .center
        $0.font = .preferredFont(forTextStyle: .caption1).withWeight(.semibold)
    }
    private lazy var dDayView = UIView().then {
        $0.addSubview(dDayLabel)
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
        $0.backgroundColor = .lightPink
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
                .font: UIFont.preferredFont(forTextStyle: .body).withWeight(.semibold),
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
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    private lazy var confirmButton = CustomButton(style: .filledSmall).then {
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }
    
    private lazy var titleStackView = UIStackView(axis: .horizontal, distribution: .equalCentering, alignment: .center, spacing: 8) {
        titleLabel
        dDayView
    }
    
    private lazy var dateStackView = UIStackView(axis: .horizontal, distribution: .equalCentering, alignment: .center, spacing: 8) {
        dateIcon
        dateLabel
    }
    
    private lazy var amountStackView = UIStackView(axis: .horizontal, alignment: .center, spacing: 8) {
        amountIcon
        amountLabel
    }
    
    private lazy var dateAndAmountStackView = UIStackView(axis: .vertical, alignment: .leading, spacing: 8) {
        dateStackView
        amountStackView
    }
    
    private lazy var contentStackView = UIStackView(axis: .horizontal, distribution: .equalCentering, alignment: .center, spacing: 8) {
        dateAndAmountStackView
        statusImageView
    }
    
    private lazy var bottomStackView = UIStackView(axis: .horizontal, distribution: .equalSpacing, alignment: .center, spacing: 8) {
        messageLabel
        confirmButton
    }
    
    private lazy var totalStackView = UIStackView(axis : .vertical, alignment: .fill, spacing: 16) {
        titleStackView
        contentStackView
        progressView
        bottomStackView
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
        contentView.addSubview(totalStackView)
        
        totalStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(15)
        }
        
        dDayLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(4)
            $0.horizontalEdges.equalToSuperview().inset(8)
        }
        
        progressView.snp.makeConstraints {
            $0.height.equalTo(20)
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
            statusImageView.snp.remakeConstraints {
                $0.width.height.equalTo(80).priority(999)
            }
            contentStackView.alignment = .fill
        } else {
            statusImageView.snp.remakeConstraints {
                $0.width.height.equalTo(50).priority(999)
            }
            contentStackView.alignment = .center
            bottomStackView.distribution = .equalSpacing
        }
    }
    
    // MARK: - Configuration
    
    func configure(with challenge: Challenge) {
        currentStatus = challenge.status
        
        titleLabel.text = challenge.category.title
        dDayLabel.text = challenge.endDate.dDayString
        dateLabel.text = challenge.startDate.toFormattedRange(to: challenge.endDate)
        
        let text = NSMutableAttributedString(
            string: "1,200,793원",
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .body).withWeight(.semibold),
                .foregroundColor: UIColor.secondary
            ]
        )
        text.append(NSAttributedString(
            string: " / \(challenge.spendingLimit.formattedWithComma)원",
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .subheadline),
                .foregroundColor: UIColor.gray1
            ]
        ))
        amountLabel.attributedText = text
        
        statusImageView.image = UIImage(systemName: "wonsign.circle")
        
        let progress = Float(4) / Float(challenge.duration.rawValue)
        progressView.setProgress(progress, animated: true)
        progressView.progressTintColor = (challenge.status == .failure) ? .gray1 : .primary
        
        bottomStackView.isHidden = true
        
        if !challenge.isCompleted {
            switch challenge.status {
            case .progress:
                break
            case .success:
                titleLabel.text = challenge.status.title
                bottomStackView.isHidden = false
                messageLabel.text = "목표 소비 금액보다 123원 절약했네요🎉\n열매를 수확해보세요!"
                confirmButton.setTitle("수확", for: .normal)
            case .failure:
                titleLabel.text = challenge.status.title
                bottomStackView.isHidden = false
                messageLabel.text = "앗 목표 소비 금액을 초과했네요😥\n확인을 누르고 다음 기회에 도전해보세요!"
                confirmButton.setTitle("확인", for: .normal)
            }
        }
    }
    
    @objc private func confirmButtonTapped() {
        guard let status = currentStatus else { return }
        onConfirmButtonTapped?(status)
    }
}
