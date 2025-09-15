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
import Vision
import VisionKit
import UITextViewPlaceholder

final class RecordFormViewController: UIViewController, View {
    
    // MARK: - Properties
    weak var coordinator: RecordCoordinator?
    var disposeBag = DisposeBag()
    
    private var loadingPopup: LoadingPopupViewController?
    private var actualAmount: Int = 0
    
    var textRecognitionRequest = VNRecognizeTextRequest()
    
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
        $0.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
        $0.setContentCompressionResistancePriority(UILayoutPriority(1), for: .horizontal)
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
    
    private let memoTextView = TextView().then {
        $0.placeholder = "입력해주세요"
        $0.textContainerInset = .zero
        $0.textContainer.lineFragmentPadding = 0
        $0.font = .preferredFont(forTextStyle: .body)
        $0.textColor = .charcoal
        $0.isScrollEnabled = false
        $0.adjustsFontForContentSizeCategory = true
    }
    
    private let saveButton = CustomButton(style: .filled).then {
        $0.setTitle("저장", for: .normal)
    }
    
    private let scanButton = CustomButton(style: .outline).then {
        $0.setTitle("영수증 촬영", for: .normal)
    }
    
    private lazy var amountStackView = UIStackView(
        axis: .horizontal, alignment: .center, spacing: 10
    ) {
        wonIconImageView
        amountTextField
    }
    
    private lazy var buttonStackView = UIStackView(
        axis: .horizontal, distribution: .fillEqually, spacing: 20
    ) {
        scanButton
        saveButton
    }
    
    private let scrollView = UIScrollView()
    
    private lazy var formView = FormView {
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
            .bottom { memoTextView }
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
        setupTextFieldDelegates()
        setupTextRecognition()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .background
        view.keyboardLayoutGuide.usesBottomSafeArea = false
        
        setupKeyboardDismiss()
        setupKeyboardToolbar()
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        scrollView.addSubview(buttonStackView)
        
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        
        scrollView.contentLayoutGuide.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(scrollView.safeAreaLayoutGuide)
        }
        
        memoTextView.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(32)
        }
        
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(scrollView.contentLayoutGuide).inset(16)
            $0.width.equalTo(scrollView.contentLayoutGuide)
            $0.leading.trailing.equalTo(scrollView.frameLayoutGuide).inset(20)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(contentStackView.snp.bottom).offset(20)
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
        memoTextView.inputAccessoryView = toolbar
    }
    
    private func setupTextFieldDelegates() {
        amountTextField.delegate = self
        placeTextField.delegate = self
        memoTextView.delegate = self
        
        amountTextField.addTarget(
            self,
            action: #selector(amountTextFieldDidChange(_:)),
            for: .editingChanged
        )
    }
    
    private func setupTextRecognition() {
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { [weak self] (request, error) in
            guard let self = self else { return }
            
            if let results = request.results, !results.isEmpty {
                if let requestResults = request.results as? [VNRecognizedTextObservation] {
                    let recognizedTexts = self.extractTextFromObservations(requestResults)
                    DispatchQueue.main.async {
                        self.reactor?.action.onNext(.scanCompleted(recognizedTexts))
                    }
                }
            }
        })
        
        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.recognitionLanguages = ["ko-KR"]
        textRecognitionRequest.usesLanguageCorrection = true
    }
    
    // MARK: - Bind
    
    func bind(reactor: RecordFormReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    private func bindAction(_ reactor: RecordFormReactor) {
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .compactMap(\.userInfo)
            .bind { [weak self] userInfo in
                guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return
                }
                guard let self, let responder = view.findFirstResponder() as? UIView else {
                    return
                }
                let frame = responder.convert(responder.bounds, to: view)
                let offset = CGPoint(
                    x: scrollView.contentOffset.x,
                    y: max(scrollView.contentOffset.y, max(0, frame.maxY - keyboardFrame.minY + 20))
                )
                scrollView.setContentOffset(offset, animated: true)
            }
            .disposed(by: disposeBag)
        
        placeTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .map(Reactor.Action.setPlace)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        memoTextView.rx.text.orEmpty
            .distinctUntilChanged()
            .map(Reactor.Action.setMemo)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .map { Reactor.Action.save }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        scanButton.rx.tap
            .map { Reactor.Action.startScan }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: RecordFormReactor) {
        reactor.state.map(\.isSaveEnabled)
            .distinctUntilChanged()
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.state.map(\.amount)
            .distinctUntilChanged()
            .subscribe { [weak self] amount in
                self?.setAmount(amount)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map(\.selectedCategory)
            .distinctUntilChanged { $0?.id == $1?.id }
            .map { $0?.title ?? "" }
            .bind(to: categoryLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map(\.place)
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .subscribe { [weak self] place in
                self?.placeTextField.text = place
            }
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
        
        reactor.pulse(\.$saveResult)
            .compactMap { $0 }
            .subscribe { [weak self] result in
                switch result {
                case .success:
                    self?.coordinator?.popRecordForm()
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
        
        reactor.pulse(\.$deleteResult)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] result in
                switch result {
                case .success:
                    self?.coordinator?.popRecordForm()
                case .failure(let error):
                    self?.showDeleteError(error)
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map(\.shouldStartScan)
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe { [weak self] _ in
                self?.presentDocumentScanner()
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$recognizedTexts)
            .filter { !$0.isEmpty }
            .subscribe { texts in
                print("인식된 텍스트: \(texts)")
            }
            .disposed(by: disposeBag)
        
        reactor.state.map(\.isParsingLoading)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] isLoading in
                if isLoading && self?.loadingPopup == nil {
                    self?.showLoadingPopup()
                } else {
                    self?.hideLoadingPopup()
                }
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$parsingError)
            .compactMap { $0 }
            .subscribe { [weak self] error in
                self?.showParsingError(error)
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
        memoTextView.text = transaction.memo ?? ""
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
        coordinator?.popRecordForm()
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
        let currentDate = reactor?.currentState.selectedDate ?? Date()
        let picker = DatePickerController(title: "날짜 선택", date: currentDate, mode: .date)
        picker.minimumDate = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1))
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
    
    private func presentDocumentScanner() {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
    }
    
    private func processImage(image: UIImage) {
        guard let cgImage = image.cgImage else {
            print("Failed to get cgimage from input image")
            return
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([textRecognitionRequest])
        } catch {
            print("텍스트 인식 실패: \(error)")
        }
    }
    
    private func extractTextFromObservations(_ observations: [VNRecognizedTextObservation]) -> [String] {
        var recognizedTexts: [String] = []
        let maximumCandidates = 1
        
        for observation in observations {
            guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
            recognizedTexts.append(candidate.string)
        }
        
        return recognizedTexts
    }
    
    private func showLoadingPopup() {
        guard loadingPopup == nil else { return }
        
        let popup = LoadingPopupViewController(
            title: "영수증 읽는 중",
            message: "화면을 벗어나지 말고 잠시만 기다려주세요"
        )
        
        loadingPopup = popup
        present(popup, animated: true)
    }
    
    private func hideLoadingPopup() {
        loadingPopup?.dismissWithAnimation()
        loadingPopup = nil
    }
    
    private func showParsingError(_ error: Error) {
        let alert = UIAlertController(
            title: "파싱 실패",
            message: "영수증 분석에 실패했습니다. 직접 입력해주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

extension RecordFormViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == amountTextField {
            placeTextField.becomeFirstResponder()
        } else if textField == placeTextField {
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

extension RecordFormViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        
        controller.dismiss(animated: true) {
            self.showLoadingPopup()
            
            // 백그라운드에서 텍스트 인식
            DispatchQueue.global(qos: .userInitiated).async {
                
                guard scan.pageCount > 0 else {
                    DispatchQueue.main.async {
                        self.hideLoadingPopup()
                        print("스캔된 페이지가 없습니다.")
                    }
                    return
                }
                
                // 여러장 찍었을 경우 마지막 사진만 처리
                let lastPageIndex = scan.pageCount - 1
                let lastImage = scan.imageOfPage(at: lastPageIndex)
                self.processImage(image: lastImage)
            }
        }
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print("문서 스캔 실패: \(error.localizedDescription)")
        controller.dismiss(animated: true)
    }
}
