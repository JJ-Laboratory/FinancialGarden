//
//  ChallengeFormViewController.swift
//  FIG
//
//  Created by estelle on 8/31/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class ChallengeFormViewController: UIViewController, View {
    
    weak var coordinator: ChallengeCoordinator?
    var disposeBag = DisposeBag()
    
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
        $0.image = UIImage(systemName: "info.circle",withConfiguration: config)
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
                    UIStackView(axis: .horizontal, distribution: .fillProportionally, spacing: 12) {
                        amount1
                        amount2
                    }
                    UIStackView(axis: .horizontal, distribution: .fillProportionally, spacing: 12) {
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
    
    init(reactor: ChallengeFormViewReactor) {
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
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    // MARK: - Bind
    
    func bind(reactor: ChallengeFormViewReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    private func bindAction(_ reactor: ChallengeFormViewReactor) {
        weekButton.rx.tap
            .map { .selectPeriod(.week) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        monthButton.rx.tap
            .map { .selectPeriod(.month) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        amount1.rx.tap
            .map { .selectAmount(.zero) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        amount2.rx.tap
            .map { .selectAmount(.one) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        amount3.rx.tap
            .map { .selectAmount(.five) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        amount4.rx.tap
            .map { .selectAmount(.ten) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        minusButton.rx.tap
            .map { .selectFruitCount(-1) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        plusButton.rx.tap
            .map { .selectFruitCount(1) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        createButton.rx.tap
            .map { .createButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        deleteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                let alert = UIAlertController(title: "삭제 확인", message: "정말로 삭제하시겠습니까?", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "삭제", style: .destructive) { _ in
                    reactor.action.onNext(.deleteButtonTapped)
                }
                let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                
                alert.addAction(confirm)
                alert.addAction(cancel)
                present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: ChallengeFormViewReactor) {
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
            .subscribe { [weak self] isClose in
                if isClose == true {
                    self?.coordinator?.popChallengeInput()
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
    
    private func updateUI(for mode: ChallengeFormViewReactor.Mode) {
        switch mode {
        case .create:
            createButton.isHidden = false
            deleteButton.isHidden = true
            
        case .detail( _):
            createButton.isHidden = true
            deleteButton.isHidden = false
            formView.isUserInteractionEnabled = false
        }
    }
    
    @objc private func backButtonTapped() {
        coordinator?.popChallengeInput()
    }
    
    private func presentCategoryPicker() {
        guard let reactor = reactor else { return }
        let picker = ItemPickerController<Category>.allCategoriesPicker()
        picker.itemSelected = { category in
            reactor.action.onNext(.selectCategory(category))
        }
        
        present(picker, animated: true)
    }
    
    private func showAlert(message: String) {
            let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default)
            alert.addAction(okAction)
            present(alert, animated: true)
        }
}

