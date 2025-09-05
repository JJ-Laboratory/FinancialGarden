//
//  PickerController.swift
//  FIG
//
//  Created by Milou on 8/27/25.
//

import SnapKit
import Then
import UIKit

class PickerController: SheetViewContent {
    private let containerView: ContainerView
    
    @inlinable var applyButton: UIButton { containerView.applyButton }
    
    init(title: String, contentHeight: CGFloat? = nil, contentView: UIView) {
        self.containerView = ContainerView(contentView: contentView)
        super.init(
            title: title,
            contentHight: contentHeight,
            contentView: containerView,
            scrollView: contentView as? UIScrollView
        )
    }
}

// MARK: - PickerController.ContainerView

extension PickerController {
    private class ContainerView: UIView {
        let applyButton = CustomButton(style: .filled).then {
            $0.setTitle("적용", for: .normal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
        }
        
        init(contentView: UIView) {
            super.init(frame: .zero)
            addSubview(contentView)
            contentView.snp.makeConstraints {
                $0.top.leading.trailing.equalToSuperview().inset(20)
            }
            
            addSubview(applyButton)
            applyButton.snp.makeConstraints {
                $0.top.equalTo(contentView.snp.bottom)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.bottom.equalTo(safeAreaLayoutGuide).inset(20)
            }
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
