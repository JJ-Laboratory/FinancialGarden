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
import ReactorKit

final class RecordFormViewController: UIViewController, View {
    
    // MARK: - Properties
    weak var coordinator: TransactionCoordinator?
    var disposeBag = DisposeBag()
    
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
    
    private let categoryLabel = UILabel().then {
        $0.textColor = .charcoal
        $0.textAlignment = .right
        $0.numberOfLines = 0
        $0.font = .preferredFont(forTextStyle: .body).withWeight(.bold)
    }
    
    private let paymentLabel = UILabel().then {
        $0.textColor = .charcoal
        $0.textAlignment = .right
        $0.numberOfLines = 0
        $0.font = .preferredFont(forTextStyle: .body).withWeight(.bold)
    }
    
    private let dateLabel = UILabel().then {
        $0.text = Date().fullDateString
        $0.textColor = .charcoal
        $0.textAlignment = .right
        $0.numberOfLines = 0
        $0.font = .preferredFont(forTextStyle: .body).withWeight(.bold)
    }
    
    // FIXME: 키보드 위로 입력창 올리기
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
            .trailing { categoryLabel }
            .action { [weak self] in
                self?.presentCategoryPicker()
            }
        
        FormItem("거래처")
            .image(UIImage(systemName: "person.circle"))
            .trailing { placeTextField }
        
        FormItem("결제수단")
            .image(UIImage(systemName: "creditcard"))
            .showsDisclosureIndicator(true)
            .trailing { paymentLabel }
            .action { [weak self] in
                self?.presentPaymentPicker()
            }
        
        FormItem("날짜")
            .image(UIImage(systemName: "calendar"))
            .showsDisclosureIndicator(true)
            .trailing { dateLabel }
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
    
    init(reactor: RecordFormReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupTextFieldDelegates()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .background
        
        setupKeyboardDismiss()
        setupKeyboardToolbar()
        
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
    
    private func setupKeyboardToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        
        let doneButton = UIBarButtonItem(
            title: "완료",
            style: .done,
            target: self,
            action: #selector(dismissKeyboard)
        )
        
        toolbar.items = [flexibleSpace, doneButton]
        
        amountTextField.inputAccessoryView = toolbar
        placeTextField.inputAccessoryView = toolbar
        memoTextField.inputAccessoryView = toolbar
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
    
    // MARK: - Bind
    func bind(reactor: RecordFormReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    private func bindAction(_ reactor: RecordFormReactor) {
        placeTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .map(Reactor.Action.setPlace)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        memoTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .map(Reactor.Action.setMemo)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .map { Reactor.Action.save }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: RecordFormReactor) {
        reactor.state.map(\.isSaveEnabled)
            .distinctUntilChanged()
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.state.map(\.selectedCategory)
            .distinctUntilChanged { $0?.id == $1?.id }
            .map { $0?.title ?? "" }
            .bind(to: categoryLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map(\.selectedPayment)
            .distinctUntilChanged()
            .map { $0?.title ?? "" }
            .bind(to: paymentLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map(\.selectedDate)
            .distinctUntilChanged()
            .map(\.fullDateString)
            .bind(to: dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.compactMap(\.saveResult)
            .subscribe { [weak self] result in
                switch result {
                case .success:
                    self?.coordinator?.popTransactionInput()
                case .failure(let error):
                    print("저장실패: \(error.localizedDescription)")
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map(\.editingRecord)
            .compactMap { $0 }
            .take(1)
            .subscribe { [weak self] transaction in
                self?.loadEditingData(transaction)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map(\.isEditMode)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] isEditMode in
                self?.updateUI(isEditMode: isEditMode)
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap(\.deleteResult)
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] result in
                switch result {
                case .success:
                    self?.coordinator?.popTransactionInput()
                case .failure(let error):
                    self?.showDeleteError(error)
                }
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    
    private func updateUI(isEditMode: Bool) {
        if isEditMode {
            saveButton.setTitle("수정", for: .normal)
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "삭제", style: .plain, target: self, action: #selector(deleteButtonTapped))
            navigationItem.rightBarButtonItem?.tintColor = .primary
        } else {
            saveButton.setTitle("저장", for: .normal)
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc private func deleteButtonTapped() {
        let alert = UIAlertController(
            title: "삭제 확인",
            message: "이 내역을 삭제하시겠습니까?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.reactor?.action.onNext(.delete)
        })
        
        present(alert, animated: true)
    }
    
    @objc private func amountTextFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        let numbersOnly = text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if numbersOnly.isEmpty {
            actualAmount = 0
            textField.text = ""
            reactor?.action.onNext(.setAmount(0))
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
            reactor?.action.onNext(.setAmount(0))
            return
        }
        
        textField.text = actualAmount.formattedWithComma
        reactor?.action.onNext(.setAmount(actualAmount))
    }
    
    private func loadEditingData(_ transaction: Transaction) {
        reactor?.action.onNext(.loadForEdit(transaction))
        
        setAmount(transaction.amount)
        placeTextField.text = transaction.title
        memoTextField.text = transaction.memo ?? ""
    }
    
    private func setAmount(_ amount: Int) {
        actualAmount = amount
        if amount == 0 {
            amountTextField.text = ""
        } else {
            amountTextField.text = amount.formattedWithComma
        }
    }
    
    @objc private func backButtonTapped() {
        coordinator?.popTransactionInput()
    }
    
    private func presentCategoryPicker() {
        let picker = ItemPickerController<Category>.allCategoriesPicker()
        picker.itemSelected = { [weak self] category in
            print("선택된 카테고리: \(category.title)")
            self?.reactor?.action.onNext(.selectCategory(category))
        }
        
        present(picker, animated: true)
    }
    
    private func presentPaymentPicker() {
        let picker = ItemPickerController<PaymentMethod>.paymentMethodPicker()
        picker.itemSelected = { [weak self] payment in
            print("선택된 카테고리: \(payment.title)")
            self?.reactor?.action.onNext(.selectPayment(payment))
        }
        
        present(picker, animated: true)
    }
    
    private func presentDatePicker() {
        let picker = DatePickerController(title: "날짜 선택", mode: .date)
        picker.maximumDate = Date()
        picker.dateSelected = { [weak self] date in
            print("선택된 날짜: \(date)")
            self?.reactor?.action.onNext(.selectDate(date))
        }
        
        present(picker, animated: true)
    }
    
    private func showDeleteError(_ error: Error) {
        let alert = UIAlertController(
            title: "삭제 실패",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
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
    RecordFormViewController(reactor: RecordFormReactor())
}
