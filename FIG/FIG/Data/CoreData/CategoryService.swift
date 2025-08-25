//
//  CategoryService.swift
//  FIG
//
//  Created by Milou on 8/25/25.
//

import Foundation
import RxCocoa
import RxSwift
import OSLog

struct CategoryResponse: Codable {
    let categories: [Category]
}

final class CategoryService {
    static let shared = CategoryService()
    private let logger = Logger.category
    
    private var categoriesRelay = BehaviorRelay<[Category]>(value: [])
    
    var categories: Observable<[Category]> {
        return categoriesRelay.asObservable()
    }
    
    private init() {
        loadCategories()
    }
    
    private func loadCategories() {
        guard let url = Bundle.main.url(forResource: "defaultCategories", withExtension: "json") else {
            logger.error("❌ defaultCategories json 파일 찾을 수 없음")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(CategoryResponse.self, from: data)
            categoriesRelay.accept(response.categories)
        } catch {
            logger.error("❌ defaultCategories json parsing 실패: \(error)")
            categoriesRelay.accept([])
        }
    }
    
    /// 모든 카테고리 가져오기
    func fetchAllCategories() -> Observable<[Category]> {
        return categories
    }
    
    /// ID로 카테고리 가져오기
    func fetchCategory(by id: UUID) -> Observable<Category?> {
        return categories
            .map { categories in
                categories.first { $0.id == id }
            }
    }
    
    /// 타입 별 카테고리 가져오기
    func fetchCategories(by type: TransactionType) -> Observable<Category?> {
        return categories
            .map { categories in
                categories.first { $0.transactionType == type }
            }
    }
}
