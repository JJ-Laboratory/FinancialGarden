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
        
        var isEditMode: Bool {
            return editingRecord != nil
        }
    }
    
    let initialState: State
    private let transactionRepository: TransactionRepositoryInterface
    private let logger = Logger.transaction
    
    init(
        transactionRepository: TransactionRepositoryInterface = TransactionRepository(),
        editingRecord: Transaction? = nil
    ) {
        self.transactionRepository = transactionRepository
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
        }
        
        newState.isSaveEnabled = newState.amount > 0 && newState.selectedCategory != nil && newState.selectedPayment != nil
        
        return newState
    }
}

extension RecordFormReactor {
    func validateInput() -> Bool {
        let state = currentState
        return state.amount > 0 &&
        state.selectedCategory != nil &&
        state.selectedPayment != nil
    }
    
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
}
