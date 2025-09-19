//
//  ChallengeFormViewController.swift
//  FIG
//
//  Created by estelle on 8/31/25.
//

import UIKit
import Then
import SnapKit
import Toast
import RxSwift
import RxCocoa
import ReactorKit

final class ChallengeFormViewController: UIViewController, View {
    
    weak var coordinator: ChallengeCoordinator?
    var disposeBag = DisposeBag()
    var onChallengeCreated: ((ChallengeDuration) -> Void)?
    
    // MARK: - UI Components
    private let deleteButton = CustomButton(style: .plain).then {
        $0.setTitle("삭제", for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .charcoal
        $0.textAlignment = .left
        $0.numberOfLines = 0
        $0.text = "어떤 챌린지를 추가하시나요?"
        $0.font = .preferredFont(forTextStyle: .title1).withWeight(.bold)
    }
    
    private let categoryLabel = UILabel().then {
        $0.textColor = .charcoal
        $0.textAlignment = .right
        $0.numberOfLines = 0
        $0.font = .preferredFont(forTextStyle: .body).withWeight(.bold)
    }
    
    private let weekButton = CustomButton(style: .outline).then {
        $0.setTitle("일주일", for: .normal)
    }
    private let monthButton = CustomButton(style: .outline).then {
        $0.setTitle("한달", for: .normal)
    }
    
    private let amountLabel = UILabel().then {
        $0.textColor = .charcoal
        $0.textAlignment = .right
        $0.text = "100,000,000원"
        $0.font = .preferredFont(forTextStyle: .body).withWeight(.semibold)
    }
    private let amount1 = CustomButton(style: .outline).then {
        $0.setTitle("무지출", for: .normal)
    }
    private let amount2 = CustomButton(style: .outline).then {
        $0.setTitle("+1만원", for: .normal)
    }
    private let amount3 = CustomButton(style: .outline).then {
        $0.setTitle("+5만원", for: .normal)
    }
    private let amount4 = CustomButton(style: .outline).then {
        $0.setTitle("+10만원", for: .normal)
    }
    
    private let minusButton = UIButton(type: .system).then {
        $0.tintColor = .gray1
        $0.setImage(UIImage(systemName: "minus"), for: .normal)
        var config = UIButton.Configuration.plain()
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(textStyle: .body)
        $0.configuration = config
    }
    private let plusButton = UIButton(type: .system).then {
        $0.tintColor = .gray1
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
        var config = UIButton.Configuration.plain()
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(textStyle: .body)
        $0.configuration = config
    }
    private let fruitCountLabel = UILabel().then {
        $0.textColor = .charcoal
        $0.text = "0개"
        $0.font = .preferredFont(forTextStyle: .body).withWeight(.bold)
    }
    private lazy var fruitCountStackView = UIStackView(axis: .horizontal) {
        minusButton
        fruitCountLabel
        plusButton
    }
    
    private let infoLabel = UILabel().then {
        $0.textColor = .gray2
        $0.numberOfLines = 0
        $0.font = .preferredFont(forTextStyle: .footnote)
    }
    private let infoImageView = UIImageView().then {
        $0.tintColor = .gray2
        let config = UIImage.SymbolConfiguration(textStyle: .footnote)
        $0.image = UIImage(systemName: "info.circle", withConfiguration: config)
        $0.adjustsImageSizeForAccessibilityContentSizeCategory = true
    }
    private lazy var infoStackView = UIStackView(axis: .horizontal, alignment: .top, spacing: 8) {
        infoImageView
        infoLabel
    }
    
    private let createButton = CustomButton(style: .filled).then {
        $0.setTitle("추가", for: .normal)
    }
    
    private lazy var formView = FormView {
        FormItem("카테고리")
            .image(UIImage(systemName: "folder"))
            .showsDisclosureIndicator(true)
            .trailing { categoryLabel }
            .action { [weak self] in self?.presentCategoryPicker() }
        
        FormItem("기간")
            .image(UIImage(systemName: "calendar"))
            .trailing { .hstack { weekButton; monthButton }}
        
        FormItem("금액")
            .image(UIImage(systemName: "wonsign.circle"))
            .trailing { amountLabel }
            .bottom {
                .adaptiveStack {
                    UIStackView(axis: .horizontal, distribution: .fillEqually, spacing: 10) {
                        amount1
                        amount2
                    }
                    UIStackView(axis: .horizontal, distribution: .fillProportionally, spacing: 10) {
                        amount3
                        amount4
                    }
                } contentSizeChanges: { contentSize, stackView in
                    if contentSize >= .extraLarge {
                        stackView.axis = .vertical
                    } else {
                        stackView.axis = .horizontal
                    }
                }
            }
        
        FormItem("수확할 열매")
            .image(UIImage(systemName: "apple.meditate"))
            .trailing { fruitCountStackView }
            .bottom(alignment: .leading) { infoStackView }
    }
    
    init(reactor: ChallengeFormReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        reactor?.action.onNext(.viewDidLoad)
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationController?.navigationBar.tintColor = .charcoal
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: deleteButton)
    }
    
    private func setupUI() {
        view.backgroundColor = .background
        [titleLabel, formView, createButton].forEach { view.addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        formView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        createButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
    
    // MARK: - Bind
    
    func bind(reactor: ChallengeFormReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    private func bindAction(_ reactor: ChallengeFormReactor) {
        
        [weekButton.rx.tap.map { .selectPeriod(.week) },
         monthButton.rx.tap.map { .selectPeriod(.month) }]
            .forEach { $0.bind(to: reactor.action).disposed(by: disposeBag) }
        
        zip([amount1, amount2, amount3, amount4], [.zero, .one, .five, .ten])
            .forEach { button, amount in
                button.rx.tap
                    .map { .selectAmount(amount) }
                    .bind(to: reactor.action)
                    .disposed(by: disposeBag)
            }
        
        minusButton.rx.tap
            .map { .selectFruitCount(-1) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        plusButton.rx.tap
            .withLatestFrom(reactor.state.map(\.isSeedInsufficient))
            .filter { !$0 }
            .map { _ in .selectFruitCount(1) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        plusButton.rx.tap
            .withLatestFrom(reactor.state.map(\.isSeedInsufficient))
            .filter { $0 }
            .withUnretained(self)
            .subscribe(onNext: { vc, _ in
                vc.present(SeedPopupViewController(), animated: true)
            })
            .disposed(by: disposeBag)
        
        createButton.rx.tap
            .map { .createButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        deleteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showAlert(
                    title: "삭제 확인",
                    message: "이 챌린지를 삭제하시겠습니까?",
                    actions: [
                        UIAlertAction(title: "취소", style: .cancel),
                        UIAlertAction(title: "삭제", style: .destructive) { _ in reactor.action.onNext(.deleteButtonTapped)
                        }
                    ]
                )
            })
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: ChallengeFormReactor) {
        reactor.state
            .map(\.mode)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .create)
            .drive(onNext: { [weak self] mode in
                self?.updateUI(for: mode)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.selectedCategory?.title)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
            .drive(categoryLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.selectedPeriod)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .week)
            .drive { [weak self] period in
                self?.weekButton.isSelected = (period == .week)
                self?.monthButton.isSelected = (period == .month)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.amount)
            .distinctUntilChanged()
            .map { "\($0.formattedWithComma)원" }
            .asDriver(onErrorJustReturn: "0원")
            .drive(amountLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.fruitCount)
            .distinctUntilChanged()
            .map { "\($0)개" }
            .asDriver(onErrorJustReturn: "0개")
            .drive(fruitCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.infoLabelText)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
            .drive(infoLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.isSeedInsufficient)
            .map { $0 ? .primary : .gray2 }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .gray2)
            .drive(infoLabel.rx.textColor)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isEnabled }
            .distinctUntilChanged()
            .bind(to: createButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isClose)
            .compactMap { $0 }
            .filter { $0 }
            .subscribe { [weak self] _ in
                guard let self else { return }
                onChallengeCreated?(reactor.currentState.selectedPeriod)
                coordinator?.popChallengeForm()
                if case .detail = reactor.currentState.mode {
                    let toast = Toast.text("챌린지가 삭제되었어요")
                    toast.show()
                } else {
                    let toast = Toast.text("🎉  새로운 챌린지를 응원합니다!")
                    toast.show()
                }
                
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$alertMessage)
            .compactMap { $0 }
            .subscribe { [weak self] message in
                self?.showAlert(message: message)
            }
            .disposed(by: disposeBag)
    }
    
    private func updateUI(for mode: ChallengeFormReactor.Mode) {
        createButton.isHidden = mode.isCreateButtonHidden
        deleteButton.isHidden = mode.isDeleteButtonHidden
        formView.isUserInteractionEnabled = mode.isFormEditable
        titleLabel.text = mode.titleText
    }
    
    @objc private func backButtonTapped() {
        coordinator?.popChallengeForm()
    }
    
    private func presentCategoryPicker() {
        guard let reactor = reactor else { return }
        let picker = ItemPickerController<Category>.categoriesByTypePicker(type: .expense)
        picker.itemSelected = { category in
            reactor.action.onNext(.selectCategory(category))
        }
        
        present(picker, animated: true)
    }
    
    private func showAlert(
        title: String = "알림",
        message: String,
        actions: [UIAlertAction] = [UIAlertAction(title: "확인", style: .default)]
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
}

