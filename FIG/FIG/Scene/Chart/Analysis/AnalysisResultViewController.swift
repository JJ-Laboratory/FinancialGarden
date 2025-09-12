//
//  AnalysisResultViewController.swift
//  FIG
//
//  Created by estelle on 9/11/25.
//

import UIKit
import Then
import SnapKit

final class AnalysisResultViewController: UIViewController {
    
    weak var coordinator: ChartCoordinator?
    
    private let subtitleLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textColor = .gray1
        $0.text = "당신의 소비 MBTI는"
        $0.font = .preferredFont(forTextStyle: .title2).withWeight(.semibold)
    }
    
    private let mbtiLabel = UILabel().then {
        $0.textColor = .charcoal
        $0.text = "ISFJ"
        $0.font = .preferredFont(forTextStyle: .largeTitle).withWeight(.semibold)
    }
    
    private let mbtiBackgroundView = UIView().then {
        $0.backgroundColor = .primary.withAlphaComponent(0.25)
    }
    
    private let subMbtiLabel = UILabel().then {
        $0.textColor = .gray1
        $0.text = "성인군자형"
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
    
    private lazy var featureTitleLabel = createTitleLabel(text: "소비 특징")
    private lazy var featureContentLabel = createContentLabel()
    private lazy var habitTitleLabel = createTitleLabel(text: "추천 습관")
    private lazy var habitContentLabel = createContentLabel()
    
    private lazy var contentsStackView = UIStackView(axis: .vertical, alignment: .leading, spacing: 40) {
        UIStackView(axis: .vertical, alignment: .leading, spacing: 8) {
            featureTitleLabel
            featureContentLabel
        }
        UIStackView(axis: .vertical, alignment: .leading, spacing: 8) {
            habitTitleLabel
            habitContentLabel
        }
    }
    
    private let cardView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
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
        [labelStackView, imageView, cardView, mbtiBackgroundView].forEach { view.addSubview($0) }
        cardView.addSubview(contentsStackView)
        
        labelStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(60)
            $0.leading.trailing.equalToSuperview().inset(42)
        }
        
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(labelStackView.snp.bottom).offset(40)
            $0.width.equalToSuperview().multipliedBy(0.35)
            $0.height.equalToSuperview().multipliedBy(0.18)
        }
        
        cardView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(40)
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
    }
    
    @objc private func backButtonTapped() {
        coordinator?.popAnalysis()
    }
    
    private func createTitleLabel(text: String) -> UILabel {
        UILabel().then {
            $0.text = text
            $0.textColor = .charcoal
            $0.font = .preferredFont(forTextStyle: .body).withWeight(.semibold)
        }
    }
    
    private func createContentLabel() -> UILabel {
        UILabel().then {
            $0.text = "sample~~~"
            $0.textColor = .gray1
            $0.font = .preferredFont(forTextStyle: .body)
        }
    }
}
