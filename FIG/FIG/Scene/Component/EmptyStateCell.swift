//
//  EmptyStateCell.swift
//  FIG
//
//  Created by Milou on 9/2/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

enum EmptyStateType {
    case transaction
    case challenge
    
    var title: String {
        switch self {
        case .transaction:
            return "아직 거래 내역이 없어요\n거래내역을 등록해 효율적인 재무 관리를 시작해보세요"
        case .challenge:
            return "아직 진행중인 챌린지가 없어요\n챌린지를 등록해 효율적인 금융 생활을 시작해보세요"
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .transaction:
            return "새 거래 내역 기록하기"
        case .challenge:
            return "새 챌린지 등록하기"
        }
    }
}

final class EmptyStateCell: UICollectionViewCell {
    
    var disposeBag = DisposeBag()
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .subheadline)
        $0.textColor = .gray1
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private lazy var pushButton = CustomButton(style: .filled).then {
        $0.isUserInteractionEnabled = true
    }
    
    private lazy var vStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 16
    }
    
    var pushButtonTapped: Observable<Void> {
        return pushButton.rx.tap.asObservable()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
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
        contentView.addSubview(containerView)
        containerView.addSubview(vStackView)
        vStackView.addArrangedSubview(titleLabel)
        vStackView.addArrangedSubview(pushButton)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        vStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(24)
        }
    }
    
    func configure(type: EmptyStateType) {
        titleLabel.text = type.title
        pushButton.setTitle(type.buttonTitle, for: .normal)
    }
}
