//
//  FormItem.swift
//  FIG
//
//  Created by Milou on 8/28/25.
//

import UIKit
import SnapKit
import RxRelay

/// 폼의 한 줄(Row)을 구성하는 모든 정보를 담는 구조체
@dynamicMemberLookup
struct FormItem {
    
    /// 설정값을 변경하는 클로저. 메서드 체이닝을 통해 이 클로저가 계속 누적/조합
    private let modifier: (inout Configuration) -> Void
    
    init() {
        self.init { _ in }
    }
    
    init(_ title: String) {
        self.init {
            $0.title = title
        }
    }
    
    private init(modifier: @escaping (inout Configuration) -> Void) {
        self.modifier = modifier
    }
    
    /// `.title("제목")`과 같은 구문을 가능하게 해주는 `@dynamicMemberLookup`
    subscript<T>(dynamicMember keyPath: WritableKeyPath<Configuration, T>) -> (T) -> FormItem {
        return { value in
            // 기존 modifier에 새로운 설정 로직을 추가하여 새로운 FormItem을 반환
            FormItem {
                // 1. 기존 설정을 먼저 적용
                modifier(&$0)
                // 2. 새로운 설정을 덧붙임
                $0[keyPath: keyPath] = value
            }
        }
    }
    
    func trailing(attachment: () -> UIView) -> FormItem {
        return self[dynamicMember: \.trailing](Attachment(view: attachment()))
    }
    
    func trailing(attachment: () -> Attachment) -> FormItem {
        return self[dynamicMember: \.trailing](attachment())
    }
    
    func bottom(alignment: HorizontalAlignment? = nil, attachment: () -> UIView) -> FormItem {
        let attachment: Attachment = alignment
            .map { .container(attachment(), alignment: $0) } ?? Attachment(view: attachment())
        return self[dynamicMember: \.bottom](attachment)
    }
    
    func bottom(alignment: HorizontalAlignment? = nil, attachment: () -> Attachment) -> FormItem {
        let attachment = alignment
            .map { .container(attachment().view, alignment: $0) } ?? attachment()
        return self[dynamicMember: \.bottom](attachment)
    }
    
    func action(_ closure: @escaping () -> Void) -> FormItem {
        let action = UIAction { _ in closure() }
        return self[dynamicMember: \.action](action)
    }
    
    func action(_ relay: PublishRelay<Void>) -> FormItem {
        let action = UIAction { _ in relay.accept(()) }
        return self[dynamicMember: \.action](action)
    }
    
    func resolve() -> Configuration {
        var configuration = Configuration()
        modifier(&configuration)
        return configuration
    }
}

// MARK: - FormItem.Configuration

extension FormItem {
    struct Configuration {
        var title: String?
        var image: UIImage?
        var imageContentMode: UIView.ContentMode = .scaleAspectFit
        var showsDisclosureIndicator: Bool = false
        var trailing: Attachment?
        var bottom: Attachment?
        var action: UIAction?
    }
}

// MARK: - FormItem.HorizontalAlignment

extension FormItem {
    enum HorizontalAlignment {
        case leading
        case trailing
        case center
    }
}

// MARK: - FormItem.Attachment

extension FormItem {
    struct Attachment {
        let view: UIView
        
        @inlinable
        static func vstack(
            distribution: UIStackView.Distribution = .fill,
            alignment: UIStackView.Alignment = .fill,
            spacing: CGFloat = 10,
            @ArrayBuilder<UIView> contents: () -> [UIView]
        ) -> Attachment {
            Attachment(
                view: UIStackView(
                    axis: .vertical,
                    distribution: distribution,
                    alignment: alignment,
                    spacing: spacing,
                    build: contents
                )
            )
        }
        
        @inlinable
        static func hstack(
            distribution: UIStackView.Distribution = .fill,
            alignment: UIStackView.Alignment = .fill,
            spacing: CGFloat = 10,
            @ArrayBuilder<UIView> contents: () -> [UIView]
        ) -> Attachment {
            Attachment(
                view: UIStackView(
                    axis: .horizontal,
                    distribution: distribution,
                    alignment: alignment,
                    spacing: spacing,
                    build: contents
                )
            )
        }
        
        @inlinable
        static func adaptiveStack(
            _ traits: [UITrait],
            spacing: CGFloat = 10,
            @ArrayBuilder<UIView> contents: () -> [UIView],
            traitChanges: @escaping (UITraitCollection, UIStackView) -> Void
        ) -> Attachment {
            Attachment(
                view: AdaptiveStackView(
                    traits: traits,
                    axis: .horizontal,
                    spacing: spacing,
                    contents: contents,
                    traitChanges: traitChanges
                )
            )
        }
        
        @inlinable
        static func adaptiveStack(
            spacing: CGFloat = 10,
            @ArrayBuilder<UIView> contents: () -> [UIView],
            contentSizeChanges: @escaping (UIContentSizeCategory, UIStackView) -> Void
        ) -> Attachment {
            Attachment(
                view: AdaptiveStackView(
                    traits: [UITraitPreferredContentSizeCategory.self],
                    axis: .horizontal,
                    spacing: spacing,
                    distribution: .fillEqually,
                    contents: contents
                ) {
                    contentSizeChanges($0.preferredContentSizeCategory, $1)
                }
            )
        }
        
        fileprivate static func container(_ view: UIView, alignment: HorizontalAlignment) -> Attachment {
            let containerView = UIView()
            containerView.addSubview(view)
            view.snp.makeConstraints {
                $0.top.bottom.equalToSuperview()
                switch alignment {
                case .leading:
                    $0.leading.equalToSuperview()
                    $0.trailing.lessThanOrEqualToSuperview()
                case .trailing:
                    $0.leading.greaterThanOrEqualToSuperview()
                    $0.trailing.equalToSuperview()
                case .center:
                    $0.leading.greaterThanOrEqualToSuperview()
                    $0.trailing.lessThanOrEqualToSuperview()
                    $0.centerX.equalToSuperview()
                }
            }
            return Attachment(view: containerView)
        }
    }
}

// MARK: - FormItem.AdaptiveStackView

extension FormItem {
    private class AdaptiveStackView: UIStackView {
        convenience init(
            traits: [UITrait],
            axis: NSLayoutConstraint.Axis,
            spacing: CGFloat,
            distribution: UIStackView.Distribution = .fill,
            @ArrayBuilder<UIView> contents: () -> [UIView],
            traitChanges: @escaping (UITraitCollection, UIStackView) -> Void
        ) {
            self.init(
                axis: axis,
                distribution: distribution,
                spacing: spacing,
                build: contents
            )
            registerForTraitChanges(traits) { (self: Self, _) in
                traitChanges(self.traitCollection, self)
            }
        }
    }
}
