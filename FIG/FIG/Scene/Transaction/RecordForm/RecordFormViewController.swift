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
    
    // MARK: - Action Relay
    private let categoryActionRelay = PublishRelay<Void>()
    private let paymentActionRelay = PublishRelay<Void>()
    private let dateActionRelay = PublishRelay<Void>()

    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.text = "어떤 거래 내역을 기록할까요?"
        $0.textColor = .charcoal
        $0.textAlignment = .left
        $0.font = .preferredFont(forTextStyle: .title1).withWeight(.bold)
    }
    
    private let wonIconImageView = UIImageView().then {
        $0.image = UIImage(systemName: "wonsign")
        $0.preferredSymbolConfiguration = UIImage.SymbolConfiguration(weight: .bold)
        $0.tintColor = .charcoal
        $0.contentMode = .scaleAspectFit
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
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
        $0.textAlignment = .right
    }
    
    private let categoryLabel = UILabel().then {
        $0.textColor = .charcoal
        $0.textAlignment = .left
        $0.numberOfLines = 0
        $0.font = .preferredFont(forTextStyle: .body).withWeight(.bold)
    }
    
    private let paymentLabel = UILabel().then {
        $0.textColor = .charcoal
        $0.textAlignment = .left
        $0.numberOfLines = 0
        $0.font = .preferredFont(forTextStyle: .body).withWeight(.bold)
    }
    
    private let dateLabel = UILabel().then {
        $0.text = Date().fullDateString
        $0.textColor = .charcoal
        $0.textAlignment = .left
        $0.numberOfLines = 0
        $0.font = .preferredFont(forTextStyle: .body).withWeight(.bold)
    }
    
    // TODO: textview
    private let memoTextField = UITextField().then {
        $0.placeholder = "입력해주세요"
        $0.font = .preferredFont(forTextStyle: .body)
        $0.textColor = .charcoal
    }
    
    private let saveButton = CustomButton(style: .filled).then {
        $0.setTitle("저장", for: .normal)
    }
    
    private lazy var amountStackView = UIStackView(
        axis: .horizontal, alignment: .center, spacing: 10
    ) {
        wonIconImageView
        amountTextField
    }
    
    private let scrollView = UIScrollView()
    
    private lazy var formView = FormView(titleSize: .fixed(120)) {
        FormItem("카테고리")
            .image(UIImage(systemName: "folder"))
            .showsDisclosureIndicator(true)
            .trailing { categoryLabel }
            .action(categoryActionRelay)
        
        FormItem("거래처")
            .image(UIImage(systemName: "person.circle"))
            .trailing { placeTextField }
        
        FormItem("결제수단")
            .image(UIImage(systemName: "creditcard"))
            .showsDisclosureIndicator(true)
            .trailing { paymentLabel }
            .action(paymentActionRelay)
        
        FormItem("날짜")
            .image(UIImage(systemName: "calendar"))
            .showsDisclosureIndicator(true)
            .trailing { dateLabel }
            .action(dateActionRelay)
        
        FormItem("메모")
            .image(UIImage(systemName: "doc.text"))
            .bottom { memoTextField }
    }
    
    private lazy var contentStackView = UIStackView(axis: .vertical, spacing: 20) {
        titleLabel
        amountStackView
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
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .background
        view.keyboardLayoutGuide.usesBottomSafeArea = false
        
        setupKeyboardDismiss()
        setupKeyboardToolbar()
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        scrollView.addSubview(saveButton)

        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        
        scrollView.contentLayoutGuide.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(scrollView.safeAreaLayoutGuide)
        }
        
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(scrollView.contentLayoutGuide).inset(16)
            $0.width.equalTo(scrollView.contentLayoutGuide)
            $0.leading.trailing.equalTo(scrollView.frameLayoutGuide).inset(20)
        }
        
        saveButton.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(contentStackView.snp.bottom).offset(20)
            $0.top.equalTo(contentStackView.snp.bottom).offset(20).priority(1)
            $0.leading.trailing.equalTo(scrollView.frameLayoutGuide).inset(20)
            $0.bottom.equalTo(scrollView.contentLayoutGuide).inset(16)
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
    
    // MARK: - Bind
    func bind(reactor: RecordFormReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    private func bindAction(_ reactor: RecordFormReactor) {
        let keyboardWillShow = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
        let keyboardWillHide = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
        Observable
            .merge(keyboardWillShow, keyboardWillHide)
            .compactMap(\.userInfo)
            .bind { [weak self] userInfo in
                guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return
                }
                guard let self, let responder = view.findFirstResponder() as? UIView else {
                    return
                }
                let frame = responder.convert(responder.frame, to: view)
                let offset = CGPoint(
                    x: scrollView.contentOffset.x,
                    y: max(scrollView.contentOffset.y, max(0, frame.minY - keyboardFrame.minY))
                )
                scrollView.setContentOffset(offset, animated: true)
            }
            .disposed(by: disposeBag)

        amountTextField.rx.text.orEmpty
            .map {
                $0.components(separatedBy: CharacterSet.decimalDigits.inverted).joined().prefix(10)
            }
            .map { Int($0) ?? 0 }
            .map { Reactor.Action.setAmount($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

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
        
        categoryActionRelay
            .map { ItemPickerController<Category>.allCategoriesPicker() }
            .withUnretained(self)
            .do(onNext: { $0.present($1, animated: true) })
            .flatMap { $1.rx.itemSelected }
            .map { Reactor.Action.selectCategory($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        paymentActionRelay
            .map { ItemPickerController<PaymentMethod>.paymentMethodPicker() }
            .withUnretained(self)
            .do(onNext: { $0.present($1, animated: true) })
            .flatMap { $1.rx.itemSelected }
            .map { Reactor.Action.selectPayment($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        dateActionRelay
            .map { DatePickerController(title: "날짜 선택", mode: .date) }
            .withUnretained(self)
            .do(onNext: { $0.present($1, animated: true) })
            .flatMap { $1.rx.dateSelected }
            .map { Reactor.Action.selectDate($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: RecordFormReactor) {
        reactor.state.map(\.isSaveEnabled)
            .distinctUntilChanged()
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.state.map(\.amount)
            .map { $0 == .zero ? "" : $0.formattedWithComma }
            .bind(to: amountTextField.rx.text)
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
        
    private func loadEditingData(_ transaction: Transaction) {
        reactor?.action.onNext(.loadForEdit(transaction))
        placeTextField.text = transaction.title
        memoTextField.text = transaction.memo ?? ""
    }
    
    @objc private func backButtonTapped() {
        coordinator?.popTransactionInput()
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

@available(iOS 17.0, *)
#Preview {
    UINavigationController(
        rootViewController: RecordFormViewController(reactor: RecordFormReactor())
    )
}
