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
    
    private var actualAmount: Int = 0
    
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
    
    // FIXME: 입력패드 안내려감
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
    
    // FIXME: 입력패드 안내려감
    private let memoTextField = UITextField().then {
        $0.placeholder = "입력해주세요"
        $0.font = .preferredFont(forTextStyle: .body)
        $0.textColor = .charcoal
    }
    
    private let saveButton = CustomButton(style: .filled).then {
        $0.setTitle("저장", for: .normal)
    }
        
    private lazy var amountStackView = UIStackView(
        axis: .horizontal, spacing: 10
    ) {
        wonIconImageView
        amountTextField
    }
    
    private let amountInputView = UIView()
    
    private lazy var formView = FormView(titleSize: .fixed(100)) {
        FormItem("카테고리")
            .image(UIImage(systemName: "folder"))
            .showsDisclosureIndicator(true)
            .action { [weak self] in
                self?.presentCategoryPicker()
            }
        
        FormItem("거래처")
            .image(UIImage(systemName: "person.circle"))
            .trailing { placeTextField }
        
        FormItem("결제수단")
            .image(UIImage(systemName: "creditcard"))
            .showsDisclosureIndicator(true)
            .action { [weak self] in
                self?.presentPaymentPicker()
            }
        
        FormItem("날짜")
            .image(UIImage(systemName: "calendar"))
            .showsDisclosureIndicator(true)
            .action { [weak self] in
                self?.presentDatePicker()
            }
        
        FormItem("메모")
            .image(UIImage(systemName: "doc.text"))
            .bottom { memoTextField }
    }
    
    private lazy var contentStackView = UIStackView(axis: .vertical, spacing: 20) {
        titleLabel
        amountInputView
        formView
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupTextFieldDelegates()
        bind()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .background
        
        setupKeyboardDismiss()
        
        amountInputView.addSubview(amountStackView)
        view.addSubview(contentStackView)
        view.addSubview(saveButton)
        
        amountStackView.alignment = .center
        amountStackView.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        saveButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    // MARK: - Setup Navigation
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
    
    private func setupTextFieldDelegates() {
        amountTextField.delegate = self
        placeTextField.delegate = self
        memoTextField.delegate = self
        
        amountTextField.addTarget(
            self,
            action: #selector(amountTextFieldDidChange(_:)),
            for: .editingChanged
        )
    }
    
    @objc private func amountTextFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        let numbersOnly = text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if numbersOnly.isEmpty {
            actualAmount = 0
            textField.text = ""
            return
        }
        
        if numbersOnly.count >= 10 {
            let limitedNumbers = String(numbersOnly.prefix(10))
            actualAmount = Int(limitedNumbers) ?? 0
        } else {
            actualAmount = Int(numbersOnly) ?? 0
        }
        
        if actualAmount == 0 {
            textField.text = ""
            return
        }
        
        textField.text = actualAmount.formattedWithComma
    }
    
    private func getCurrentAmout() -> Int {
        return actualAmount
    }
    
    private func setAmount(_ amount: Int) {
        actualAmount = amount
        if amount == 0 {
            amountTextField.text = ""
        } else {
            amountTextField.text = amount.formattedWithComma
        }
    }
    
    // MARK: - Bind
    private func bind() {
        saveButton.rx.tap
            .subscribe { [weak self] _ in
                print("저장 버튼 탭")
                self?.coordinator?.popTransactionInput()
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        coordinator?.popTransactionInput()
    }
    
    private func presentCategoryPicker() {
        let picker = ItemPickerController<Category>.allCategoriesPicker()
        picker.itemSelected = { category in
            print("선택된 카테고리: \(category.title)")
        }
        
        present(picker, animated: true)
    }
    
    private func presentPaymentPicker() {
        let picker = ItemPickerController<PaymentMethod>.paymentMethodPicker()
        picker.itemSelected = { payment in
            print("선택된 카테고리: \(payment.title)")
        }
        
        present(picker, animated: true)
    }
    
    private func presentDatePicker() {
        let picker = DatePickerController(title: "날짜 선택", mode: .date)
        picker.dateSelected = { date in
            print("선택된 날짜: \(date)")
        }
        
        present(picker, animated: true)
    }
}

extension RecordFormViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == amountTextField {
            placeTextField.becomeFirstResponder()
        } else if textField == placeTextField {
            memoTextField.becomeFirstResponder()
        } else if textField == memoTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == amountTextField {
            // 숫자와 백스페이스만 허용
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            
            // 백스페이스 허용
            if string.isEmpty {
                return true
            }
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == amountTextField {
            if actualAmount == 0 {
                textField.text = ""
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    RecordFormViewController()
}
