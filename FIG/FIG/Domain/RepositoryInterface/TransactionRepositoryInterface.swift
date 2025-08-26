//
//  TransactionRepositoryInterface.swift
//  FIG
//
//  Created by Milou on 8/22/25.
//

import Foundation
import RxSwift

protocol TransactionRepositoryInterface {
    
    // MARK: - CREATE
    
    /// 새로운 거래내역을 저장합니다
    func saveTransaction(_ transaction: Transaction) -> Observable<Transaction>
    
    // MARK: - READ
    
    /// 모든 거래내역을 불러옵니다
    func fetchAllTransaction() -> Observable<[Transaction]>
    /// 해당 월에 대한 거래 내역을 불러옵니다
    func fetchTransactionByMonth(_ year: Int, _ month: Int) -> Observable<[Transaction]>
    
    // MARK: - UPDATE
    
    /// 기존 거래내역을 수정합니다
    func editTransaction(_ transaction: Transaction) -> Observable<Transaction>
    
    // MARK: - DELETE
    
    /// 기존 거래내역을 삭제합니다
    func deleteTransaction(id: UUID) -> Observable<Void>
}
