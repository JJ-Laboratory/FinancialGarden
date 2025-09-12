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

final class AnalysisViewController: UIViewController {
    
    weak var coordinator: ChartCoordinator?
    var disposeBag = DisposeBag()
    
    private let subtitleLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textColor = .gray1
        $0.text = "소비 성향 MBTI"
        $0.font = .preferredFont(forTextStyle: .title2).withWeight(.semibold)
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .charcoal
        $0.numberOfLines = 0
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
        $0.image = UIImage(named: "success")
    }
    
    private let analysisButton = CustomButton(style: .filled).then {
        $0.setTitle("AI 분석하기", for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        
        analysisButton.rx.tap
            .subscribe { [weak self] _ in
                self?.coordinator?.pushAnalysisResult()
            }
            .disposed(by: disposeBag)
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
        [labelStackView, imageView, analysisButton].forEach { view.addSubview($0) }
        
        labelStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(60)
            $0.leading.trailing.equalToSuperview().inset(42)
        }
        
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(labelStackView.snp.bottom).offset(120)
            $0.width.equalToSuperview().multipliedBy(0.6)
            $0.height.equalToSuperview().multipliedBy(0.3)
        }
        
        analysisButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
    
    @objc private func backButtonTapped() {
        coordinator?.popAnalysis()
    }
}
