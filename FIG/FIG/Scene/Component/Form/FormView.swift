//
//  FormView.swift
//  FIG
//
//  Created by Milou on 8/28/25.
//

import UIKit
import SnapKit
import Then

final class FormView: UIView {
    init(
        titleSize: SizeStrategy = .fill,
        @ArrayBuilder<FormItem> items: () -> [FormItem]
    ) {
        super.init(frame: .zero)
        let contentView = UIStackView(
            axis: .vertical,
            spacing: 16,
            arrangedSubviews: items().map { ItemView(titleSize: titleSize, item: $0) }
        )
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - FormView.SizeStrategy

extension FormView {
    enum SizeStrategy {
        case fixed(CGFloat)
        case fill
    }
}

// MARK: - FormView.ItemView

extension FormView {
    private class ItemView: UIControl {
        let backgroundView = UIView().then {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 10
        }
        
        let iconView = UIImageView().then {
            $0.tintColor = .gray1
            $0.preferredSymbolConfiguration = UIImage.SymbolConfiguration(weight: .bold)
        }
        
        let titleLabel = UILabel().then {
            $0.font = .preferredFont(forTextStyle: .body)
            $0.textColor = .gray1
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
            $0.setContentHuggingPriority(UILayoutPriority(248), for: .horizontal)
            $0.setContentCompressionResistancePriority(UILayoutPriority(248), for: .horizontal)
        }
        
        let disclosureIndicator = UIImageView(image: UIImage(systemName: "chevron.right")).then {
            $0.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .body).withWeight(.semibold))
                .applying(UIImage.SymbolConfiguration(hierarchicalColor: .gray1))
            $0.contentMode = .scaleAspectFit
            $0.setContentHuggingPriority(.required, for: .horizontal)
        }
        
        let action: UIAction?
        
        override var isHighlighted: Bool {
            didSet {
                guard action != nil else {
                    return
                }
                let color: UIColor = isHighlighted ? .primary.withAlphaComponent(0.1) : .white
                UIView.animate(withDuration: 0.25) {
                    self.backgroundView.backgroundColor = color
                }
            }
        }
        
        init(titleSize: SizeStrategy, item: FormItem) {
            let configuration = item.resolve()
            action = configuration.action
            super.init(frame: .zero)
            iconView.image = configuration.image
            iconView.contentMode = configuration.imageContentMode
            titleLabel.text = configuration.title
            disclosureIndicator.isHidden = !configuration.showsDisclosureIndicator
            
            addSubview(backgroundView)
            backgroundView.snp.makeConstraints {
                $0.directionalEdges.equalToSuperview()
            }
            
            let titleContentView = UIView().then {
                $0.addSubview(iconView)
                $0.addSubview(titleLabel)
            }
            if case .fixed(let size) = titleSize {
                titleContentView.snp.makeConstraints {
                    $0.width.equalTo(size)
                }
            }
            iconView.snp.makeConstraints {
                $0.top.bottom.equalTo(titleLabel)
                $0.leading.equalToSuperview()
                $0.width.equalTo(iconView.snp.height)
            }
            titleLabel.snp.makeConstraints {
                $0.top.greaterThanOrEqualToSuperview()
                $0.bottom.lessThanOrEqualToSuperview()
                $0.centerY.equalToSuperview()
                $0.leading.equalTo(iconView.snp.trailing).offset(10)
                $0.trailing.equalToSuperview()
            }
            
            let contentView = UIStackView(axis: .vertical, spacing: 16) {
                UIStackView(axis: .horizontal, spacing: 16) {
                    // Title
                    titleContentView
                    
                    // Trailing
                    UIStackView(axis: .horizontal, spacing: 10) {
                        if let trailingView = configuration.trailing?.view {
                            trailingView
                        } else if case .fixed = titleSize {
                            UIView().then { // Spacer
                                $0.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
                                $0.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
                                $0.setContentCompressionResistancePriority(UILayoutPriority(1), for: .vertical)
                                $0.setContentCompressionResistancePriority(UILayoutPriority(1), for: .horizontal)
                            }
                        }
                        disclosureIndicator
                    }
                }
                // Bottom
                if let bottomView = configuration.bottom?.view {
                    bottomView
                }
            }
            
            addSubview(contentView)
            contentView.snp.makeConstraints {
                $0.directionalEdges.equalToSuperview().inset(16)
            }
            
            // Tap Action
            if let action {
                addAction(action, for: .touchUpInside)
            }
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            guard let view = super.hitTest(point, with: event) else {
                return nil
            }
            return resolveHitTest(view)
        }

        private func resolveHitTest(_ view: UIView) -> UIView {
            if view.canBecomeFirstResponder || view is UIControl {
                return view
            }
            guard let nextView = view.next as? UIView else {
                return view
            }
            return resolveHitTest(nextView)
        }
    }
}
