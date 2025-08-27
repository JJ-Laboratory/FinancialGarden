//
//  CategoryPickerDemo.swift
//  FIG
//
//  Created by Milou on 8/27/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class CategoryPickerDemo: UIViewController {
    
    let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let selectButton = CustomButton(style: .filled).then {
        $0.setTitle("카테고리 선택하기", for: .normal)
    }
    
    private let resultLabel = UILabel().then {
        $0.text = "선택된 카테고리: 없음"
        $0.font = .preferredFont(forTextStyle: .title3)
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.textColor = .secondaryLabel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "카테고리 피커 테스트"
        
        let stackView = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 30
            $0.alignment = .fill
        }
        
        stackView.addArrangedSubview(resultLabel)
        stackView.addArrangedSubview(selectButton)
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    private func bindActions() {
        selectButton.rx.tap
            .map { ItemPickerController<Category>.allCategoriesPicker() }
            .withUnretained(self)
            .do(onNext: { owner, picker in
                owner.present(picker, animated: true)
            })
            .flatMap { _, picker in
                picker.rx.itemSelected
            }
            .withUnretained(self)
            .bind { owner, category in
                let typeText = category.transactionType == .income ? "수입" : "지출"
                let colorName = category.transactionType == .income ? "Primary" : "Secondary"
                owner.resultLabel.text = "선택된 카테고리:\n\(category.title) (\(typeText))\n아이콘 색상: \(colorName)"
                owner.resultLabel.textColor = .label
            }
            .disposed(by: disposeBag)
    }
}

@available(iOS 17.0, *)
#Preview {
    CategoryPickerDemo()
}
