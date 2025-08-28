//
//  ArrayBuilder.swift
//  FIG
//
//  Created by Milou on 8/28/25.
//

@resultBuilder
public struct ArrayBuilder<Item> {
    
    /// 클로저 내부에 나열된 여러 아이템들을 하나의 배열로 묶어줌
    public static func buildBlock(_ items: Item...) -> [Item] {
        return items
    }
    
    /// 클로저 내부에 이미 배열이 있는 경우 처리
    public static func buildBlock(_ items: [Item]...) -> [Item] {
        return items.flatMap { $0 }
    }
    
    /// 옵셔널 조건 처리
    public static func buildOptional(_ items: [Item]?) -> [Item] {
        return items ?? []
    }
    
    /// if 문 처리
    public static func buildEither(first items: [Item]) -> [Item] {
        return items
    }
    
    /// else 문 처리
    public static func buildEither(second items: [Item]) -> [Item] {
        return items
    }
    
    /// 단일 아이템 하나 -> 원소가 1개인 배열로 변환
    public static func buildExpression(_ expression: Item) -> [Item] {
        return [expression]
    }
    
    /// 아이템의 컬렉션 처리
    public static func buildExpression<C: Collection>(_ expression: C) -> [Item] where C.Element == Item {
        return Array(expression)
    }
    
    public static func buildArray(_ components: [[Item]]) -> [Item] {
        return components.flatMap { $0 }
    }
    
    public static func buildLimitedAvailability(_ component: [Item]) -> [Item] {
        return component
    }
}
