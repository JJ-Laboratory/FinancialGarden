//
//  HomeHeaderCell.swift
//  FIG
//
//  Created by Milou on 9/2/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class HomeHeaderView: UICollectionReusableView {
    
    var disposeBag = DisposeBag()
    
    private let containerView = UIView().then {
        $0.backgroundColor = .clear
        $0.isUserInteractionEnabled = true
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .headline)
        $0.textColor = .charcoal
        $0.textAlignment = .left
    }
    
    private let chevronImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .charcoal
        $0.contentMode = .scaleAspectFit
    }
    
    var headerTapped: Observable<Void> {
        return containerView.rx.tapGesture()
            .when(.recognized)
            .map { _ in }
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
        isUserInteractionEnabled = true
        
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(chevronImageView)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.verticalEdges.equalToSuperview().inset(11)
        }
        
        chevronImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(18)
        }
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
}
