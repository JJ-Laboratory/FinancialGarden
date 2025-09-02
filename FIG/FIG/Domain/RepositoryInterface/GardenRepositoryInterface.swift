//
//  GardenRepositoryInterface.swift
//  FIG
//
//  Created by estelle on 9/1/25.
//

import Foundation
import RxSwift

protocol GardenRepositoryInterface {
    
    // MARK: - READ
    
    /// 모든 정원 정보를 불러옵니다
    func fetchGardenRecord() -> Observable<GardenRecord>
    
    // MARK: - UPDATE
    
    /// 기존 정원 정보를 수정합니다
    func add(seeds: Int, fruits: Int) -> Observable<GardenRecord>
}
