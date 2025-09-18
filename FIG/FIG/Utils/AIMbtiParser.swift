//
//  AIMbtiParser.swift
//  FIG
//
//  Created by estelle on 9/16/25.
//

import Foundation
import FirebaseAI
import OSLog

struct MBTIResult: Codable, Equatable {
    let mbti: String
    let title: String
    let description: String
    let category: String
    let duration: String
    let spendingLimit: Int
    let reason: String
}

final class AIMbtiParser {
    static let shared = AIMbtiParser()
    private let logger = Logger(subsystem: "FIG", category: "AIMbtiParser")
    
    private let ai: FirebaseAI
    private let model: GenerativeModel
    
    private init() {
        self.ai = FirebaseAI.firebaseAI(backend: .googleAI())
        self.model = ai.generativeModel(modelName: "gemini-2.0-flash-lite-001")
    }
    
    func parseMbti(_ recognizedTexts: [String]) async throws -> MBTIResult? {
        let joinedText = recognizedTexts.joined(separator: ", ")
        
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
                    규칙으로 소비 내역과 어울리는 MBTI를 1개 선정하고, 소비 습관 개선을 위한 챌린지 1개 추천.
                    필드:
                    - mbti(string): (16가지의 MBTI 유형 중 1개)
                    - title(string): (소비 내역의 특징과 어울리는 별명)
                    - description(string): (소비 내역의 특징과 mbti 선정 근거 한 문장)
                    - category(string): (소비 내역에 있는 카테고리 중에서 개선이 가장 필요한 카테고리 1개)
                    - duration(string): (챌린지 기간(일주일, 한달 2가지 중 선택))
                    - spendingLimit(int): (목표 제한 금액)
                    - reason(string): (위의 챌린지를 추천한 근거 한 문장)
                    규칙:
                    - E: 유흥·여행↑, I: 온라인·집↑
                    - S: 생활·필수↑, N: 교육·투자·취미↑
                    - T: 투자·보험↑, F: 간식·미용·기부↑
                    - J: 고정비·정기↑, P: 변동·즉흥↑
                    - 출력은 JSON 배열만, 다른 설명 없이
                    소비 내역:
                    [\(text)]
                    """
    }
    
    private func parseJSONResponse(_ responseText: String) throws -> MBTIResult? {
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
            let parsedArray = try JSONDecoder().decode([MBTIResult].self, from: data)
            return parsedArray.first
        } catch {
            logger.error("ai parsing failed: \(error)")
            throw AIParsingError.jsonParsingFailed
        }
    }
}

extension MBTIResult {
    var categoryData: Category? {
        let categoryService = CategoryService.shared
        
        return categoryService.fetchAllCategories()
            .first { $0.title == category } ?? categoryService.fetchAllCategories()
            .first { $0.title == "기타 지출" }
    }
    
    var durationType: ChallengeDuration {
        duration == "일주일" ? .week : .month
    }
}

