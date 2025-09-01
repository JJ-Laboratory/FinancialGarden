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
    private let titleLabel = UILabel().then {
        $0.textColor = .charcoal
        $0.textAlignment = .left
        $0.numberOfLines = 0
        $0.text = "어떤 챌린지를 추가하시나요?"
        $0.font = .preferredFont(forTextStyle: .title2).withWeight(.bold)
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
    private lazy var infoStackView = UIStackView(axis: .horizontal, alignment: .center, spacing: 8) {
        infoLabel
        infoImageView
    }
    
    private let createButton = CustomButton(style: .filled).then {
        $0.setTitle("추가", for: .normal)
    }
    
    private lazy var formView = FormView(titleSize: .fixed(100)) {
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
            .bottom(alignment: .center) {
                .adaptiveStack {
                    amount1
                    amount2
                    amount3
                    amount4
                } contentSizeChanges: { contentSize, stackView in
                    if contentSize >= .extraExtraExtraLarge {
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
    
    func bind(reactor: ChallengeFormViewReactor) {
        
        // MARK: - Action (View -> Reactor)
        
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
            .subscribe(onNext: { [weak self] in
                // TODO: 실제 챌린지 생성 로직 구현
                print("생성 버튼 탭됨")
                self?.coordinator?.popChallengeInput()
            })
            .disposed(by: disposeBag)
        
        // MARK: - State (Reactor -> View)
        
        reactor.state
            .map(\.selectedcategory)
            .distinctUntilChanged()
            .map { $0?.title ?? "" }
            .bind(to: categoryLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.selectedPeriod)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .week)
            .drive(onNext: { [weak self] period in
                self?.weekButton.isSelected = (period == .week)
                self?.monthButton.isSelected = (period == .month)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.amount)
            .distinctUntilChanged()
            .map { "\($0.formattedWithComma)원" }
            .bind(to: amountLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.fruitCount)
            .distinctUntilChanged()
            .map { "\($0)개" }
            .bind(to: fruitCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.currentSeedCount)
            .distinctUntilChanged()
            .map { "현재 사용 가능 씨앗 \($0)개" }
            .bind(to: infoLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isEnabled }
            .distinctUntilChanged()
            .bind(to: createButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    @objc private func backButtonTapped() {
        coordinator?.popChallengeInput()
    }
    
    private func presentCategoryPicker() {
        guard let reactor = reactor else { return }
        let picker = ItemPickerController<Category>.allCategoriesPicker()
        picker.itemSelected = { category in
            print("선택된 카테고리: \(category.title)")
            reactor.action.onNext(.selectCategory(category))
        }
        
        present(picker, animated: true)
    }
}

