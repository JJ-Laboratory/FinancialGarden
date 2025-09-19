//
//  seedPopupViewController.swift
//  FIG
//
//  Created by estelle on 9/18/25.
//

import UIKit
import SnapKit
import Then
import RxSwift

final class SeedPopupViewController: UIViewController {
    
    private let popupTransitioningDelegate = PopupTransitioningDelegate()
    var disposeBag = DisposeBag()
    
    private let contentView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    private let seedImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        let font = UIFont.preferredFont(forTextStyle: .title2).withWeight(.semibold)
        $0.image = UIImage(named: "level0")?.resized(height: font.lineHeight)
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .charcoal
        $0.text = "씨앗이 모자라요!"
        $0.numberOfLines = 0
        $0.font = .preferredFont(forTextStyle: .title2).withWeight(.semibold)
    }
    
    private let seedInfoLabel = UILabel().then {
        $0.textColor = .gray1
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = .preferredFont(forTextStyle: .subheadline)
        $0.text = "-일주일 챌린지: 씨앗 5개 필요\n-한 달 챌린지: 씨앗 3개 필요"
    }
    
    private let messageLabel = UILabel().then {
        $0.textColor = .gray1
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.text = "가계부 내역을 등록하면 씨앗을 모을 수 있어요!"
        $0.font = .preferredFont(forTextStyle: .subheadline)
    }
    
    private let button = CustomButton(style: .filled).then {
        $0.setTitle("확인", for: .normal)
    }
    
    private lazy var totalStackView = UIStackView(axis: .vertical, alignment: .center, spacing: 20) {
        UIStackView(axis: .horizontal) {
            seedImageView
            titleLabel
        }
        seedInfoLabel
        messageLabel
        button
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .custom
        transitioningDelegate = popupTransitioningDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        button.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        view.addSubview(contentView)
        contentView.addSubview(totalStackView)
        
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(25)
            $0.centerY.equalToSuperview()
        }
        
        totalStackView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(24)
            $0.horizontalEdges.equalToSuperview().inset(30)
        }
        
        button.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
        }
    }
}
