//
//  SheetViewController.swift
//  FIG
//
//  Created by Milou on 8/27/25.
//

import SnapKit
import Then
import UIKit

/// 모든 바텀 시트의 기반이 되는 기본 ViewController
/// 제목, 닫기 버튼, 그리고 커스텀 콘텐츠 뷰를 포함하는 기본 UI 뼈대 제공
class SheetViewContent: UIViewController {
    private let titleLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .title3).withWeight(.semibold)
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private let closeButton = UIButton(configuration: .plain()).then {
        $0.configuration?.image = UIImage(systemName: "xmark")
        $0.configuration?.preferredSymbolConfigurationForImage =
            UIImage.SymbolConfiguration(
                font: .preferredFont(forTextStyle: .body).withWeight(.semibold)
            )
            .applying(UIImage.SymbolConfiguration(hierarchicalColor: .label))
        $0.configuration?.contentInsets = .zero
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private let containerView = UIView().then {
        $0.backgroundColor = .systemBackground
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    /// 실제 내용이 표시될 뷰 (예: DatePicker, ItemPicker 등)
    private let contentView: UIView

    private let sheetTransitioningDelegate = SheetTransitioningDelegate()

    init(
        title: String,
        contentHight: CGFloat? = nil,
        contentView: UIView,
        scrollView: UIScrollView? = nil
    ) {
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)
        self.titleLabel.text = title
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = sheetTransitioningDelegate
        
        self.sheetTransitioningDelegate.scrollView = scrollView
        if let contentHight {
            self.sheetTransitioningDelegate.contentHeight = .custom { _ in
                contentHight
            }
        } else {
            self.sheetTransitioningDelegate.contentHeight = .fit
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(20)
        }

        containerView.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(20)
            $0.trailing.equalToSuperview().inset(20)
        }

        containerView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }

        closeButton.addAction(
            UIAction { [weak self] _ in
                self?.dismiss(animated: true)
            },
            for: .primaryActionTriggered
        )
    }
}

// MARK: - SheetViewController Preview

#Preview {
    let contentView = UILabel().then {
        $0.text = "Sheet Content"
        $0.font = .preferredFont(forTextStyle: .largeTitle).withWeight(.black)
        $0.textAlignment = .center
    }
    SheetViewContent(title: "Sheet", contentView: contentView).then {
        $0.view.backgroundColor = .black
    }
}
