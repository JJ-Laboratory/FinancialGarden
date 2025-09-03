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
    private var isHomeMode: Bool = false
    
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
    
    private let stageImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let progressView = ProgressView().then {
        $0.tintColor = .primary
        $0.trackTintColor = .background
        $0.thickness = 20
    }
    
    private let messageLabel = UILabel().then {
        $0.textColor = .gray1
        $0.numberOfLines = 0
        $0.font = .preferredFont(forTextStyle: .footnote)
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
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
        stageImageView
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
            stageImageView.snp.remakeConstraints {
                $0.width.height.equalTo(80).priority(999)
            }
            contentStackView.alignment = .fill
        } else {
            stageImageView.snp.remakeConstraints {
                $0.width.height.equalTo(50).priority(999)
            }
            contentStackView.alignment = .center
            bottomStackView.distribution = .equalSpacing
        }
    }
    
    // MARK: - Configuration
    
    func configure(with challenge: Challenge, isHomeMode: Bool = false) {
        currentStatus = challenge.status
        self.isHomeMode = isHomeMode
        
        titleLabel.text = challenge.category.title
        dDayLabel.text = challenge.endDate.dDayString
        dDayView.isHidden = challenge.isCompleted ? true : false
        dateLabel.text = challenge.startDate.toFormattedRange(to: challenge.endDate)
        
        configureAmount(with: challenge)
        configureProgress(with: challenge)
        configureStatusUI(with: challenge)
    }
    
    /// 금액 정보 설정
    private func configureAmount(with challenge: Challenge) {
        let currentSpendingText = NSMutableAttributedString(
            string: "\(challenge.currentSpending.formattedWithComma)원",
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .body).withWeight(.semibold),
                .foregroundColor: UIColor.secondary
            ]
        )
        
        let limitText = NSAttributedString(
            string: " / \(challenge.spendingLimit.formattedWithComma)원",
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .subheadline),
                .foregroundColor: UIColor.gray1
            ]
        )
        
        currentSpendingText.append(limitText)
        amountLabel.attributedText = currentSpendingText
    }
    
    /// 진행률과 단계 이미지 설정
    private func configureProgress(with challenge: Challenge) {
        let progressValue = challenge.startDate.progress(to: challenge.endDate)
        
        DispatchQueue.main.async {
            self.progressView.setProgress(progressValue, animated: true)
        }
        
        progressView.tintColor = (challenge.status == .failure) ? .gray1 : .primary
        
        let stage = ProgressStage(progress: progressValue)
        stageImageView.image = stage.image
    }
    
    /// 상태별 UI 설정 (제목, 이미지, 버튼)
    private func configureStatusUI(with challenge: Challenge) {
        bottomStackView.isHidden = true
        
        switch challenge.status {
        case .progress:
            break
            
        case .success:
            configureSuccessStatus(with: challenge)
            
        case .failure:
            configureFailureStatus(with: challenge)
        }
    }
    
    /// 성공 상태 UI 설정
    private func configureSuccessStatus(with challenge: Challenge) {
        stageImageView.image = UIImage(systemName: "apple.meditate")
        
        guard !challenge.isCompleted else { return }
        
        titleLabel.text = challenge.status.title
        
        guard !isHomeMode else { return }
        
        bottomStackView.isHidden = false
        let savedAmount = (challenge.spendingLimit - challenge.currentSpending).formattedWithComma
        messageLabel.text = "목표 소비 금액보다 \(savedAmount)원 절약했네요🎉\n열매를 수확해보세요!"
        confirmButton.setTitle("수확", for: .normal)
    }
    
    /// 실패 상태 UI 설정
    private func configureFailureStatus(with challenge: Challenge) {
        stageImageView.image = UIImage(systemName: "x.circle")
        
        guard !challenge.isCompleted else { return }
        
        titleLabel.text = challenge.status.title
        
        guard !isHomeMode else { return }
        
        bottomStackView.isHidden = false
        messageLabel.text = "앗 목표 소비 금액을 초과했네요😥\n확인을 누르고 다음 기회에 도전해보세요!"
        confirmButton.setTitle("확인", for: .normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        progressView.progress = 0
        isHomeMode = false
    }
    
    @objc private func confirmButtonTapped() {
        guard let status = currentStatus else { return }
        onConfirmButtonTapped?(status)
    }
}
