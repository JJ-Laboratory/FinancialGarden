//
//  CategoryRepositoryInterface.swift
//  FIG
//
//  Created by Milou on 8/22/25.
//

import Foundation
import RxSwift

protocol CategoryRepositoryInterface {
    
    /// 모든 카테고리를 불러옵니다
    func fetchAllCategories() -> Observable<[Category]>
    
    /// 기본 카테고리를 초기화합니다
    func initializeDefaultCategories() -> Observable<Void>
}
