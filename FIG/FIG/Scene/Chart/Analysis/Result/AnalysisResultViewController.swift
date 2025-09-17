//
//  AnalysisResultViewController.swift
//  FIG
//
//  Created by estelle on 9/11/25.
//

import UIKit
import Then
import SnapKit
import ReactorKit

final class AnalysisResultViewController: UIViewController, View {
    
    weak var coordinator: ChartCoordinator?
    weak var challengeCoordinator: ChallengeCoordinator?
    var disposeBag = DisposeBag()
    
    private let subtitleLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textColor = .gray1
        $0.text = "당신의 소비 MBTI는"
        $0.font = .preferredFont(forTextStyle: .title2).withWeight(.semibold)
    }
    
    private let mbtiLabel = UILabel().then {
        $0.textColor = .charcoal
        $0.font = .preferredFont(forTextStyle: .largeTitle).withWeight(.semibold)
    }
    
    private let mbtiBackgroundView = UIView().then {
        $0.backgroundColor = .primary.withAlphaComponent(0.25)
    }
    
    private let subMbtiLabel = UILabel().then {
        $0.textColor = .gray1
        $0.font = .preferredFont(forTextStyle: .title2)
    }
    
    private lazy var labelStackView = UIStackView(axis: .vertical, alignment: .center, spacing: 8) {
        subtitleLabel
        mbtiLabel
        subMbtiLabel
    }
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "success")
    }
    
    private lazy var descriptionTitleLabel = createTitleLabel(text: "소비 특징")
    private lazy var descriptionContentLabel = createContentLabel()
    private lazy var recommendTitleLabel = createTitleLabel(text: "추천 챌린지")
    private lazy var recommendChallengeLabel = createContentLabel()
    private lazy var recommendContentLabel = createContentLabel()
    
    private lazy var contentsStackView = UIStackView(axis: .vertical, alignment: .leading, spacing: 40) {
        UIStackView(axis: .vertical, alignment: .leading, spacing: 8) {
            descriptionTitleLabel
            descriptionContentLabel
        }
        UIStackView(axis: .vertical, alignment: .leading, spacing: 8) {
            recommendTitleLabel
            recommendChallengeLabel
            recommendContentLabel
        }
    }
    
    private let cardView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }
    
    private let challengeButton = CustomButton(style: .filled).then {
        $0.setTitle("추천 챌린지 추가하기", for: .normal)
    }
    
    init(reactor: AnalysisResultReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor?.action.onNext(.viewDidLoad)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
    }
    
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
        [labelStackView, imageView, cardView, mbtiBackgroundView, challengeButton].forEach { view.addSubview($0) }
        cardView.addSubview(contentsStackView)
        
        labelStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.leading.trailing.equalToSuperview().inset(42)
        }
        
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(labelStackView.snp.bottom).offset(40)
            $0.width.equalToSuperview().multipliedBy(0.35)
            $0.height.equalToSuperview().multipliedBy(0.18)
        }
        
        cardView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        contentsStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }
        
        mbtiBackgroundView.snp.makeConstraints {
            $0.centerX.equalTo(mbtiLabel)
            $0.bottom.equalTo(mbtiLabel).offset(-4)
            $0.width.equalTo(mbtiLabel).multipliedBy(1.2)
            $0.height.equalTo(mbtiLabel).multipliedBy(0.5)
        }
        
        challengeButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
    
    func bind(reactor: AnalysisResultReactor) {
        challengeButton.rx.tap
            .map { .challengeButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isNavigatingToChallengeForm)
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                guard let self, let result = reactor.currentState.analysisResult else { return }
                challengeCoordinator?.pushChallengeEdit(result: result)
            })
            .disposed(by: disposeBag)
        
        let resultDriver = reactor.state
            .compactMap(\.analysisResult)
            .asDriver(onErrorDriveWith: .empty())
        
        resultDriver
            .map(\.mbti)
            .drive(mbtiLabel.rx.text)
            .disposed(by: disposeBag)
        
        resultDriver
            .map(\.title)
            .drive(subMbtiLabel.rx.text)
            .disposed(by: disposeBag)
        
        resultDriver
            .map(\.description)
            .drive(descriptionContentLabel.rx.text)
            .disposed(by: disposeBag)
        
        resultDriver
            .map(\.reason)
            .drive(recommendContentLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.recommendedChallenge)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
            .drive(recommendChallengeLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    @objc private func backButtonTapped() {
        coordinator?.popAnalysis()
    }
    
    private func createTitleLabel(text: String) -> UILabel {
        UILabel().then {
            $0.text = text
            $0.numberOfLines = 0
            $0.textColor = .charcoal
            $0.font = .preferredFont(forTextStyle: .body).withWeight(.semibold)
        }
    }
    
    private func createContentLabel() -> UILabel {
        UILabel().then {
            $0.numberOfLines = 0
            $0.textColor = .gray1
            $0.font = .preferredFont(forTextStyle: .body)
        }
    }
}
