//
//  RecordFormViewController.swift
//  FIG
//
//  Created by Milou on 8/28/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class RecordFormViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: TransactionCoordinator?
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.text = "어떤 소비를 하셨나요?"
        $0.textColor = .charcoal
        $0.textAlignment = .left
        $0.font = .preferredFont(forTextStyle: .title1).withWeight(.bold)
    }
    
    private let wonIconImageView = UIImageView().then {
        $0.image = UIImage(systemName: "wonsign")
        $0.preferredSymbolConfiguration = UIImage.SymbolConfiguration(weight: .bold)
        $0.tintColor = .charcoal
        $0.contentMode = .scaleAspectFit
    }
    
    private let amountTextField = UITextField().then {
        $0.keyboardType = .decimalPad
        $0.placeholder = "금액을 입력해주세요"
        $0.font = .preferredFont(forTextStyle: .title2).withWeight(.bold)
        $0.textColor = .primary
    }
    
    private let placeTextField = UITextField().then {
        $0.placeholder = "입력해주세요"
        $0.font = .preferredFont(forTextStyle: .body)
        $0.textColor = .charcoal
    }
    
    private let memoTextField = UITextField().then {
        $0.placeholder = "입력해주세요"
        $0.font = .preferredFont(forTextStyle: .body)
        $0.textColor = .charcoal
    }
    
    private let saveButton = CustomButton(style: .filled).then {
        $0.setTitle("저장", for: .normal)
    }
    
    private lazy var recordStackView = UIStackView(axis: .vertical, spacing: 20) {
        
        titleLabel
        
        makeAmountInputSection()
        
        FormView {
            FormItem("카테고리")
                .image(UIImage(systemName: "folder"))
                .showsDisclosureIndicator(true)
                .action {
                  print("카테고리 선택")
                }
            
            FormItem("거래처")
                .image(UIImage(systemName: "person.circle"))
                .trailing { placeTextField }
            
            FormItem("결제수단")
                .image(UIImage(systemName: "creditcard"))
                .showsDisclosureIndicator(true)
                .action {
                    print("결제수단 선택")
                }
            
            FormItem("날짜")
                .image(UIImage(systemName: "calendar"))
                .showsDisclosureIndicator(true)
                .action {
                    print("날짜 선택")
                }
            
            FormItem("메모")
                .image(UIImage(systemName: "doc.text"))
                .bottom { memoTextField }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        setupNavigationBar()
    }
    
    private func setupUI() {
        view.backgroundColor = .background
        
        view.addSubview(recordStackView)
        view.addSubview(saveButton)
        
        recordStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        saveButton.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview().inset(20)
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
    
    private func makeAmountInputSection() -> UIView {
        let containerView = UIView()
        
        let stackView = UIStackView(axis: .horizontal, spacing: 10) {
            wonIconImageView
            amountTextField
        }
        stackView.alignment = .center
        
        containerView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        return containerView
    }
    
    private func setupNavigationBar() {
        title = ""
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationController?.navigationBar.tintColor = .charcoal
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
    }
    
    @objc private func backButtonTapped() {
        coordinator?.popTransactionInput()
    }
}

@available(iOS 17.0, *)
#Preview {
    RecordFormViewController()
}
