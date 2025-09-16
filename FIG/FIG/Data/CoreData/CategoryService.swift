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
    
    private var categories: [Category] = []
    private var categoryDict: [UUID: Category] = [:]
    
    private init() {
        loadCategories()
    }
    
    /// 모든 카테고리 가져오기
    func fetchAllCategories() -> [Category] {
        return categories
    }
    
    /// ID로 카테고리 가져오기
    func fetchCategoryByID(_ id: UUID) -> Category? {
        return categoryDict[id]
    }
    
    /// 타입 별 카테고리 가져오기
    func fetchCategoriesByType(_ type: TransactionType) -> [Category] {
        return categories.filter { $0.transactionType == type }
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
            let decodedCategories = response.categories
            
            let incomeCategories = decodedCategories.filter { $0.transactionType == .income }
            let expenseCategories = decodedCategories.filter { $0.transactionType == .expense }
            
            self.categories = incomeCategories + expenseCategories
            self.categoryDict = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0) })
        } catch {
            logger.error("❌ defaultCategories json parsing 실패: \(error)")
            self.categories = []
            self.categoryDict = [:]
        }
    }
}
