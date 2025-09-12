//
//  RecordFormReactor.swift
//  FIG
//
//  Created by Milou on 8/31/25.
//

import Foundation
import ReactorKit
import RxSwift
import OSLog

final class RecordFormReactor: Reactor {
    
    enum Action {
        case setAmount(Int)
        case selectCategory(Category)
        case setPlace(String)
        case selectPayment(PaymentMethod)
        case selectDate(Date)
        case setMemo(String)
        case save
        case loadForEdit(Transaction)
        case delete
    }
    
    enum Mutation {
        case setAmount(Int)
        case setCategory(Category?)
        case setPlace(String)
        case setPayment(PaymentMethod?)
        case setDate(Date)
        case setMemo(String)
        case setEditingRecord(Transaction?)
        case setSaveResult(Result<Transaction, Error>)
        case setDeleteResult(Result<Void, Error>)
    }
    
    struct State {
        var amount: Int = 0
        var selectedCategory: Category?
        var place: String = ""
        var selectedPayment: PaymentMethod?
        var selectedDate: Date = Date()
        var memo: String = ""
        var editingRecord: Transaction?
        var saveResult: Result<Transaction, Error>?
        var isSaveEnabled: Bool = false
        var deleteResult: Result<Void, Error>?
        var isEditMode: Bool {
            return editingRecord != nil
        }
    }
    
    let initialState: State
    private let transactionRepository: TransactionRepositoryInterface
    private let gardenRepository: GardenRepositoryInterface
    private let logger = Logger.transaction
    
    init(
        transactionRepository: TransactionRepositoryInterface,
        gardenRepository: GardenRepositoryInterface,
        editingRecord: Transaction? = nil
    ) {
        self.transactionRepository = transactionRepository
        self.gardenRepository = gardenRepository
        self.initialState = .init(
            selectedDate: Date(),
            editingRecord: editingRecord
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setAmount(let amount):
            return Observable.just(.setAmount(amount))
        case .selectCategory(let category):
            return Observable.just(.setCategory(category))
        case .setPlace(let place):
            return Observable.just(.setPlace(place))
        case .selectPayment(let payment):
            return Observable.just(.setPayment(payment))
        case .selectDate(let date):
            return Observable.just(.setDate(date))
        case .setMemo(let memo):
            return Observable.just(.setMemo(memo))
        case .save:
            return saveTransaction()
        case .loadForEdit(let transaction):
            return Observable.just(.setEditingRecord(transaction))
                .concat(loadTransactionData(transaction))
        case .delete:
            return deleteTransaction()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setAmount(let amount):
            newState.amount = amount
        case .setCategory(let category):
            newState.selectedCategory = category
        case .setPlace(let place):
            newState.place = place
        case .setPayment(let payment):
            newState.selectedPayment = payment
        case .setDate(let date):
            newState.selectedDate = date
        case .setMemo(let memo):
            newState.memo = memo
        case .setEditingRecord(let transaction):
            newState.editingRecord = transaction
        case .setSaveResult(let result):
            newState.saveResult = result
        case .setDeleteResult(let result):
            newState.deleteResult = result
        }
        
        newState.isSaveEnabled = calculateSaveEnabled(newState)
        
        return newState
    }
}

extension RecordFormReactor {
    func saveTransaction() -> Observable<Mutation> {
        let state = currentState
        
        guard state.isSaveEnabled else {
            logger.warning("저장조건 미충족")
            return Observable.empty()
        }
        
        guard let category = state.selectedCategory,
              let payment = state.selectedPayment else {
            logger.warning("필수정보누락")
            return Observable.empty()
        }
        
        let title = state.place.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? category.title
        : state.place.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let transaction = Transaction(
            id: state.editingRecord?.id ?? UUID(),
            amount: state.amount,
            category: category,
            title: title,
            payment: payment,
            date: state.selectedDate,
            memo: state.memo.isEmpty ? nil: state.memo
        )
        
        let saveObservable: Observable<Transaction>
        
        if state.isEditMode {
            saveObservable = transactionRepository.editTransaction(transaction)
        } else {
            saveObservable = transactionRepository.saveTransaction(transaction)
                .flatMap { [weak self] savedTransaction -> Observable<Transaction> in
                    guard let self else { return .empty() }
                    return self.gardenRepository.add(seeds: 1, fruits: 0)
                        .map { _ in savedTransaction }
                }
        }
        
        return Observable.concat([
            saveObservable
                .map { transaction in
                        .setSaveResult(.success(transaction))
                }
                .catch { error in
                    Observable.just(.setSaveResult(.failure(error)))
                }
        ])
    }
    
    func loadTransactionData(_ transaction: Transaction) -> Observable<Mutation> {
        return Observable.concat([
            Observable.just(.setAmount(transaction.amount)),
            Observable.just(.setCategory(transaction.category)),
            Observable.just(.setPlace(transaction.title)),
            Observable.just(.setPayment(transaction.payment)),
            Observable.just(.setDate(transaction.date)),
            Observable.just(.setMemo(transaction.memo ?? "")),
        ])
    }
    
    private func calculateSaveEnabled(_ state: State) -> Bool {

        let hasRequiredFields = state.amount > 0 &&
                               state.selectedCategory != nil &&
                               state.selectedPayment != nil
        
        guard hasRequiredFields else { return false }
        
        // 새 등록 모드인 경우 - 기본 조건만 확인
        guard state.isEditMode else { return true }
        
        // 수정 모드인 경우 - 원본과 변경사항 확인
        guard let editingRecord = state.editingRecord else { return false }
        
        return hasChanges(state, editingRecord)
    }
    
    private func hasChanges(_ currentState: State, _ originalRecord: Transaction) -> Bool {
        // 금액 변경
        if currentState.amount != originalRecord.amount {
            return true
        }
        
        // 카테고리 변경
        if currentState.selectedCategory?.id != originalRecord.category.id {
            return true
        }
        
        // 거래처 변경
        let currentTitle = currentState.place.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? (currentState.selectedCategory?.title ?? "")
            : currentState.place.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if currentTitle != originalRecord.title {
            return true
        }
        
        // 결제수단 변경
        if currentState.selectedPayment != originalRecord.payment {
            return true
        }
        
        // 날짜 변경 (같은 날인지 확인)
        let calendar = Calendar.current
        if !calendar.isDate(currentState.selectedDate, inSameDayAs: originalRecord.date) {
            return true
        }
        
        // 메모 변경
        let currentMemo = currentState.memo.isEmpty ? nil : currentState.memo
        if currentMemo != originalRecord.memo {
            return true
        }
        
        return false
    }
    
    func deleteTransaction() -> Observable<Mutation> {
        guard let editingRecord = currentState.editingRecord else {
            return Observable.just(.setDeleteResult(.failure(CoreDataError.entityNotFound)))
        }
        
        return transactionRepository.deleteTransaction(id: editingRecord.id)
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                return self.gardenRepository.add(seeds: -1, fruits: 0)
                    .map { _ in () }
            }
            .map { _ in .setDeleteResult(.success(())) }
            .catch { error in
                Observable.just(.setDeleteResult(.failure(error)))
            }
    }
}
