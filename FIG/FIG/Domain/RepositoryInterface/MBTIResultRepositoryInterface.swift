//
//  MBTIResultRepositoryInterface.swift
//  FIG
//
//  Created by estelle on 9/16/25.
//

import Foundation
import RxSwift

protocol MBTIResultRepositoryInterface {
    
    // MARK: - READ
    
    /// MBTI 분석 결과 정보를 불러옵니다
    func fetchResult() -> Observable<MBTIResult?>
    
    // MARK: - UPDATE
    
    /// MBTI 분석 결과를 저장하거나 업데이트합니다
    func saveOrUpdateResult(_ result: MBTIResult) -> Observable<MBTIResult>
}
