//
//  TransactionInputViewController.swift
//  FIG
//
//  Created by Milou on 8/28/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class TransactionInputViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: TransactionCoordinator?
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.text = "내역 추가 화면"
        $0.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        $0.textAlignment = .center
    }
    
    private let saveButton = UIButton(type: .system).then {
        $0.setTitle("저장", for: .normal)
        $0.backgroundColor = .systemPink
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 8
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemGreen
        title = "내역 추가"
        
        view.addSubview(titleLabel)
        view.addSubview(saveButton)
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-50)
        }
        
        saveButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.width.equalTo(100)
            $0.height.equalTo(50)
        }
    }
    
    private func bind() {
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                // TODO: 실제 저장 로직 구현
                print("저장 버튼 탭됨")
                self?.coordinator?.popTransactionInput()
            })
            .disposed(by: disposeBag)
    }
}
