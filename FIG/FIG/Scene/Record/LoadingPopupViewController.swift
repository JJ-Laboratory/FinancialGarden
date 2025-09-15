//
//  LoadingPopupViewController.swift
//  FIG
//
//  Created by Milou on 9/15/25.
//

import UIKit
import SnapKit
import Then

final class LoadingPopupViewController: UIViewController {
    
    private let popupTransitioningDelegate = PopupTransitioningDelegate()
    
    private let contentView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    private let activityIndicator = UIActivityIndicatorView(style: .large).then {
        $0.color = .primary
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
    
    init(title: String, message: String) {
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .custom
        transitioningDelegate = popupTransitioningDelegate
        
        titleLabel.text = title
        messageLabel.text = message
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        activityIndicator.startAnimating()
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        view.addSubview(contentView)
        [activityIndicator, titleLabel, messageLabel].forEach {
            contentView.addSubview($0)
        }
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(40)
            $0.centerY.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints {
            $0.top.equalToSuperview().inset(30)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(activityIndicator.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(30)
        }
    }
    
    func dismissWithAnimation() {
        activityIndicator.stopAnimating()
        dismiss(animated: true)
    }
}
