//
//  PopupView.swift
//  FIG
//
//  Created by estelle on 8/26/25.
//

import UIKit
import Then
import SnapKit

enum ChallengeType {
    case success
    case failure
    
    var title: String {
        switch self {
        case .success: return "챌린지 성공!"
        case .failure: return "챌린지 실패!"
        }
    }
    
    var message: String {
        switch self {
        case .success: return "개의 열매를 수확했어요"
        case .failure: return "개의 씨앗이 소멸되었어요"
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .success: return "새 챌린지 도전하기"
        case .failure: return "챌린지 다시 도전하기"
        }
    }
}

class PopupView: UIView {
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.5)
    }
    
    private let contentView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .charcoal
        $0.textAlignment = .center
        $0.font = .preferredFont(forTextStyle: .title3)
        $0.adjustsFontForContentSizeCategory = true
    }
    
    private let messageLabel = UILabel().then {
        $0.textColor = .gray1
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = .preferredFont(forTextStyle: .footnote)
        $0.adjustsFontForContentSizeCategory = true
    }
    
    private let challengeButton = CustomButton(style: .filled)
    private lazy var closeButton = CustomButton(style: .underline).then {
        $0.setTitle("다음에 할게요", for: .normal)
        $0.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }
    
    init(type: ChallengeType, frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        configure(type: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [backgroundView, contentView].forEach { addSubview($0) }
        
        [titleLabel, messageLabel, challengeButton, closeButton].forEach {
            contentView.addSubview($0)
        }
        
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
    }
    
    private func configure(type: ChallengeType) {
        titleLabel.text = type.title
        messageLabel.text = "2" + type.message
        challengeButton.setTitle( type.buttonTitle, for: .normal)
    }
    
    @objc func closeTapped() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.backgroundView.alpha = 0
            self.contentView.alpha = 0
            self.contentView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
    
    func show() {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene, let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }
        window.addSubview(self)
        
        backgroundView.alpha = 0
        contentView.alpha = 0
        contentView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.backgroundView.alpha = 1
            self.contentView.alpha = 1
            self.contentView.transform = .identity
        })
    }
}
