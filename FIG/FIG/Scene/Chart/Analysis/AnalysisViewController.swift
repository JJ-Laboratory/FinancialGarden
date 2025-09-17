//
//  AnalysisViewController.swift
//  FIG
//
//  Created by estelle on 9/11/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class AnalysisViewController: UIViewController, View {
    
    weak var coordinator: ChartCoordinator?
    var disposeBag = DisposeBag()
    private var loadingPopup: LoadingPopupViewController?
    
    private let subtitleLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textColor = .gray1
        $0.text = "소비 성향 MBTI"
        $0.font = .preferredFont(forTextStyle: .title2).withWeight(.semibold)
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .charcoal
        $0.numberOfLines = 0
        $0.textAlignment = .center
        let text = "나의 소비 스타일에 딱 맞는 개선 습관은?"
        let attributedString = NSMutableAttributedString(string: text)
        let range = NSRange(location: text.count - 7, length: 5)
        attributedString.addAttribute(.foregroundColor, value: UIColor.primary, range: range)
        $0.attributedText = attributedString
        $0.font = .preferredFont(forTextStyle: .title1).withWeight(.semibold)
    }
    
    private lazy var labelStackView = UIStackView(axis: .vertical, alignment: .center, spacing: 8) {
        subtitleLabel
        titleLabel
    }
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "analysis_img")
    }
    
    private let resultButton = CustomButton(style: .plain).then {
        $0.setTitle("최근 결과보기", for: .normal)
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.primary.cgColor
        $0.layer.masksToBounds = true
    }
    
    private let analysisButton = CustomButton(style: .filled).then {
        $0.setTitle("AI 분석하기", for: .normal)
    }
    
    private lazy var buttonStackView = UIStackView(axis: .horizontal, distribution: .fillEqually, spacing: 20) {
        resultButton
        analysisButton
    }
    
    init(reactor: AnalysisReactor) {
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
        [labelStackView, imageView, buttonStackView].forEach { view.addSubview($0) }
        
        labelStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(60)
            $0.leading.trailing.equalToSuperview().inset(42)
        }
        
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(labelStackView.snp.bottom).offset(44)
            $0.width.equalToSuperview().multipliedBy(0.9)
            $0.height.equalToSuperview().multipliedBy(0.4)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
    
    func bind(reactor: AnalysisReactor) {
        resultButton.rx.tap
            .map { .resultButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        analysisButton.rx.tap
            .map { .analyzeButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.isResultButtonHidden)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: true)
            .drive(resultButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.isLoading)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isLoading in
                if isLoading && self?.loadingPopup == nil {
                    self?.showLoadingPopup()
                } else {
                    self?.hideLoadingPopup()
                }
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$alertMessage)
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] message in
                self?.showAlert(message: message)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isShowStartAlert)
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                self?.showAlert(
                    title: "분석 시작",
                    message: "AI 분석을 위해 열매 1개가 소모돼요! 계속하시겠습니까?",
                    actions: [
                        UIAlertAction(title: "취소", style: .cancel),
                        UIAlertAction(title: "확인", style: .default) { _ in
                            reactor.action.onNext(.analysisStarted)
                        }
                    ]
                )
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isShowResultScreen)
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.pushAnalysisResult()
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func backButtonTapped() {
        coordinator?.popAnalysis()
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
    
    private func showLoadingPopup() {
            guard loadingPopup == nil else { return }
            
            let popup = LoadingPopupViewController(
                title: "소비 성향 분석 중...",
                message: "화면을 벗어나지 말고 잠시만 기다려주세요"
            )
            
            loadingPopup = popup
            present(popup, animated: true)
        }
        
        private func hideLoadingPopup() {
            loadingPopup?.dismissWithAnimation()
            loadingPopup = nil
        }
}
