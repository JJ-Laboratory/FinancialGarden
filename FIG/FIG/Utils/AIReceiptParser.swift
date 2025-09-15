//
//  AIReceiptParser.swift
//  FIG
//
//  Created by Milou on 9/13/25.
//

import Foundation
import FirebaseAI
import OSLog

struct ParsedReceipt: Codable, Equatable {
    let category: String
    let amount: Int
    let place: String
    let payment: String?
    let date: String?
}

final class AIReceiptParser {
    static let shared = AIReceiptParser()
    private let logger = Logger(subsystem: "FIG", category: "AIReceiptParser")
    
    private let ai: FirebaseAI
    private let model: GenerativeModel
    
    private init() {
        self.ai = FirebaseAI.firebaseAI(backend: .googleAI())
        self.model = ai.generativeModel(modelName: "gemini-2.0-flash-lite-001")
    }
    
        func parseReceipt(_ recognizedTexts: [String]) async throws -> ParsedReceipt? {
            let joinedText = recognizedTexts.joined(separator: "\n")
    
            let prompt = createPrompt(with: joinedText)
    
            do {
                let response = try await model.generateContent(prompt)
                guard let responseText = response.text else {
                    logger.error("ai parsing error: no response text")
                    return nil
                }
                
                logger.info("ai parsing result: \(responseText)")
                
                return try parseJSONResponse(responseText)
            } catch {
                logger.error("ai parsing error: \(error)")
                throw error
            }
        }
    
    private func createPrompt(with text: String) -> String {
        return """
                    텍스트에서 거래내역 1개에 대한 JSON 배열 생성.
                    필드:
                    - category(string): [식비, 카페・간식, 편의점・마트・잡화, 술・유흥, 쇼핑, 취미・여가, 의료・건강・피트니스, 주거・통신, 보험・세금・기타금융, 미용, 교통・자동차, 여행・숙박, 교육, 생활, 기부・후원, ATM출금, 이체, 카드대금, 저축・투자, 후불결제대금], 없으면 "기타 지출"
                    - amount(int)
                    - place(string): 상호/가맹점명
                    - payment(string): [현금, 카드, 계좌, 페이・기타금융], 없으면 null
                    - date(yyyy-mm-dd): 거래일시 변환, 없으면 null
                    규칙:
                    - 광고·카드번호·승인번호 등 무시
                    - 금액 여러 개면 최종 결제금액만 사용
                    - 출력은 JSON 배열만, 다른 설명 없이
                    텍스트:
                    \(text)
                    """
    }
    
    private func parseJSONResponse(_ responseText: String) throws -> ParsedReceipt? {
        let cleanedText = responseText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        logger.info("cleaned JSON: \(cleanedText)")
        
        guard let data = cleanedText.data(using: .utf8) else {
            throw AIParsingError.invalidResponse
        }
        
        do {
            let parsedArray = try JSONDecoder().decode([ParsedReceipt].self, from: data)
            return parsedArray.first
        } catch {
            logger.error("ai parsing failed: \(error)")
            throw AIParsingError.jsonParsingFailed
        }
    }
}

enum AIParsingError: Error, LocalizedError {
    case invalidResponse
    case jsonParsingFailed
    case noDataFound
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "AI 응답이 유효하지 않습니다"
        case .jsonParsingFailed:
            return "JSON 파싱에 실패했습니다"
        case .noDataFound:
            return "파싱할 데이터를 찾을 수 없습니다"
        }
    }
}

extension ParsedReceipt {
    func toTransaction() -> (category: Category?, payment: PaymentMethod?, date: Date?) {
        let categoryService = CategoryService.shared
        
        let foundCategory = categoryService.fetchAllCategories()
            .first { $0.title == self.category } ?? categoryService.fetchAllCategories()
            .first { $0.title == "기타 지출" }
        
        let paymentMethod: PaymentMethod?
        if let payment = self.payment {
             switch payment {
             case "현금":
                 paymentMethod = .cash
             case "카드":
                 paymentMethod = .card
             case "계좌":
                 paymentMethod = .account
             case "페이・기타금융":
                 paymentMethod = .other
             default:
                 paymentMethod = nil
             }
         } else {
             paymentMethod = nil
         }
        
        let parsedDate: Date?
        if let dateString = self.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            parsedDate = dateFormatter.date(from: dateString)
        } else {
            parsedDate = nil
        }
        
        return (foundCategory, paymentMethod, parsedDate)
    }
}
