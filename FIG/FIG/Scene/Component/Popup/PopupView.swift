//
//  PopupView.swift
//  FIG
//
//  Created by estelle on 8/26/25.
//

import UIKit
import Then
import SnapKit

class PopupView: UIView {
    
    var onChallengeTapped: (() -> Void)?
    var onCloseTapped: (() -> Void)?
    
    private let contentView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .charcoal
        $0.textAlignment = .center
        $0.font = .preferredFont(forTextStyle: .title3).withWeight(.semibold)
    }
    
    private let messageLabel = UILabel().then {
        $0.textColor = .gray1
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = .preferredFont(forTextStyle: .footnote)
    }
    
    private let challengeButton = CustomButton(style: .filled)
    private let closeButton = CustomButton(style: .underline)
    
    init(type: ChallengeStatus, count: Int) {
        super.init(frame: .zero)
        setupUI()
        configure(type: type, count: count)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(contentView)
        
        [titleLabel, messageLabel, challengeButton, closeButton].forEach {
            contentView.addSubview($0)
        }
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(40)
            $0.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(200)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        challengeButton.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(challengeButton.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        challengeButton.addTarget(self, action: #selector(challengeTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }
    
    private func configure(type: ChallengeStatus, count: Int) {
        titleLabel.text = type.title
        messageLabel.text = "\(count)" + type.message
        challengeButton.setTitle( type.buttonTitle, for: .normal)
        closeButton.setTitle("다음에 할게요", for: .normal)
    }
    
    @objc func challengeTapped() {
        onChallengeTapped?()
    }
    
    @objc func closeTapped() {
        onCloseTapped?()
    }
}
