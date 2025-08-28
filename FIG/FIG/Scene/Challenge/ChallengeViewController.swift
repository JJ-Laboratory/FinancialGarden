//
//  ChallengeViewController.swift
//  FIG
//
//  Created by Milou on 8/28/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class ChallengeViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: ChallengeCoordinator?
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let addButton = UIButton(type: .system).then {
        $0.setTitle("+ 챌린지 추가", for: .normal)
        $0.backgroundColor = .systemOrange
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 8
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "챌린지 화면"
        $0.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        $0.textAlignment = .center
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemOrange.withAlphaComponent(0.1)
        title = "챌린지"
        
        view.addSubview(titleLabel)
        view.addSubview(addButton)
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-50)
        }
        
        addButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.width.equalTo(150)
            $0.height.equalTo(50)
        }
    }
    
    private func bind() {
        addButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.pushChallengeInput()
            })
            .disposed(by: disposeBag)
    }
}
