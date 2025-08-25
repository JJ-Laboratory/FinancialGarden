//
//  Category.swift
//  FIG
//
//  Created by Milou on 8/21/25.
//

import Foundation

enum TransactionType: String, CaseIterable {
    case income = "income"
    case expense = "expense"
    
    var title: String {
        switch self {
        case .income:
            return "수입"
        case .expense:
            return "지출"
        }
    }
}

struct Category {
    let id: UUID
    let title: String
    let iconName: String
    let transactionType: TransactionType
    let isDefault: Bool
    
    init(
        title: String,
        iconName: String,
        transactionType: TransactionType,
        isDefault: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.iconName = iconName
        self.transactionType = transactionType
        self.isDefault = isDefault
    }
    
    // 카테고리여기로
    static let defaultCategories: [Category] = [
        // 지출 카테고리
        Category(
            title: "식비",
            iconName: "fork.knife",
            transactionType: .expense,
            isDefault: true
        ),
        Category(
            title: "카페・간식",
            iconName: "cup.and.heat.waves.fill",
            transactionType: .expense,
            isDefault: true
        ),
        Category(
            title: "편의점・마트・잡화",
            iconName: "cart.fill",
            transactionType: .expense,
            isDefault: true
        ),
        Category(
            title: "술・유흥",
            iconName: "wineglass.fill",
            transactionType: .expense,
            isDefault: true
        ),
        Category(
            title: "쇼핑",
            iconName: "bag.fill",
            transactionType: .expense,
            isDefault: true
        ),
        Category(
            title: "취미・여가",
            iconName: "gamecontroller.fill",
            transactionType: .expense,
            isDefault: true
        ),
        Category(
            title: "의료・건강・피트니스",
            iconName: "plus.square.fill",
            transactionType: .expense,
            isDefault: true
        ),
        Category(
            title: "주거・통신",
            iconName: "house.fill",
            transactionType: .expense,
            isDefault: true
        ),
        Category(
            title: "보험・세금・기타금융",
            iconName: "doc.text.fill",
            transactionType: .expense,
            isDefault: true
        ),
        Category(
            title: "미용",
            iconName: "sparkles",
            transactionType: .expense,
            isDefault: true
        ),
        Category(
            title: "교통・자동차",
            iconName: "car.fill",
            transactionType: .expense,
            isDefault: true
        ),
        Category(
            title: "여행・숙박",
            iconName: "airplane",
            transactionType: .expense,
            isDefault: true
        ),
        Category(
            title: "교육",
            iconName: "book.fill",
            transactionType: .expense,
            isDefault: true
        ),
        Category(
            title: "생활",
            iconName: "washer.fill",
            transactionType: .expense,
            isDefault: true
        ),
        Category(
            title: "기부・후원",
            iconName: "gift",
            transactionType: .expense,
            isDefault: true
        ),
        Category(
            title: "기타 지출",
            iconName: "ellipsis.circle",
            transactionType: .expense,
            isDefault: true
        ),
        Category(
            title: "ATM출금",
            iconName: "banknote",
            transactionType: .expense,
            isDefault: true
        ),
        Category(
            title: "이체",
            iconName: "arrow.left.arrow.right",
            transactionType: .expense,
            isDefault: true
        ),
        Category(
            title: "카드대금",
            iconName: "creditcard",
            transactionType: .expense,
            isDefault: true
        ),
        Category(
            title: "저축・투자",
            iconName: "chart.line.uptrend.xyaxis",
            transactionType: .expense,
            isDefault: true
        ),
        Category(
            title: "후불결제대금",
            iconName: "clock.arrow.circlepath",
            transactionType: .expense,
            isDefault: true
        ),
        
        // 수입 카테고리
        Category(
            title: "급여(수입)",
            iconName: "wonsign.arrow.trianglehead.counterclockwise.rotate.90",
            transactionType: .income,
            isDefault: true
        ),
        Category(
            title: "기타 수입",
            iconName: "plus.circle",
            transactionType: .income,
            isDefault: true
        )
    ]
}
