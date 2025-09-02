//
//  ItemPickerController+Rx.swift
//  FIG
//
//  Created by Milou on 8/27/25.
//

import RxCocoa
import RxSwift
import UIKit

protocol RxItemPickerController: UIViewController {
    associatedtype Item
    var itemSelected: ((Item) -> Void)? { get set }
}

extension ItemPickerController: RxItemPickerController {
}

extension Reactive where Base: RxItemPickerController {
    var itemSelected: ControlEvent<Base.Item> {
        let source = Observable<Base.Item>.create { [weak base] observer in
            base?.itemSelected = {
                observer.on(.next($0))
                observer.on(.completed)
            }
            return Disposables.create { [weak base] in
                guard let base, !base.isBeingDismissed else {
                    return
                }
                base.dismiss(animated: true)
            }
        }
        return ControlEvent(events: source.take(until: base.rx.deallocated))
    }
}

// MARK: - ItemPickerController Category

extension ItemPickerController where Item == Category {
    
    /// Category 전용 편의 생성자
    /// - Parameters:
    ///   - title: 피커 제목
    ///   - categories: 표시할 카테고리 배열
    ///   - selectedCategory: 미리 선택된 카테고리 (옵션)
    ///   - contentHeight: 피커 높이 (기본값: 500)
    convenience init(
        title: String,
        categories: [Category],
        selectedCategory: Category? = nil,
        contentHeight: CGFloat = 500
    ) {
        self.init(
            title: title,
            items: categories,
            selectedItem: selectedCategory,
            contentHeight: contentHeight,
            itemImage: { category in
                UIImage(systemName: category.iconName)
            },
            itemTitle: { category in
                category.title
            },
            itemBackgroundColor: { category in
                category.backgroundColor
            },
            itemIconColor: { category in
                category.iconColor
            }
        )
    }
    
    /// 전체 카테고리 피커 생성하는 팩토리 메서드
    /// - Parameters:
    ///   - selectedCategory: 미리 선택된 카테고리 (옵션)
    ///   - contentHeight: 피커 높이 (기본값: 500)
    /// - Returns: 전체 카테고리를 표시하는 선택기
    static func allCategoriesPicker(
        selectedCategory: Category? = nil,
        contentHeight: CGFloat = 500
    ) -> ItemPickerController<Category> {
        let allCategories = CategoryService.shared.fetchAllCategories()
        
        return ItemPickerController(
            title: "카테고리 선택",
            categories: allCategories,
            selectedCategory: selectedCategory,
            contentHeight: contentHeight
        )
    }
}

// MARK: - ItemPickerController PaymentMethod

extension ItemPickerController where Item == PaymentMethod {
    
    /// PaymentMethod 전용 편의 생성자
    convenience init(
        title: String,
        paymentMethods: [PaymentMethod],
        selectedPaymentMethod: PaymentMethod? = nil,
        contentHeight: CGFloat = 400
    ) {
        self.init(
            title: title,
            items: paymentMethods,
            selectedItem: selectedPaymentMethod,
            contentHeight: contentHeight,
            itemImage: { $0.icon },
            itemTitle: { $0.title },
            itemBackgroundColor: { _ in .lightPink },
            itemIconColor: { _ in .primary }
        )
    }
    
    /// 전체 결제수단 피커 생성하는 팩토리 메서드
    static func paymentMethodPicker(
        selectedPaymentMethod: PaymentMethod? = nil,
        contentHeight: CGFloat = 450
    ) -> ItemPickerController<PaymentMethod> {
        return ItemPickerController(
            title: "결제수단 선택",
            paymentMethods: PaymentMethod.allCases,
            selectedPaymentMethod: selectedPaymentMethod,
            contentHeight: contentHeight
        )
    }
}
