//
//  AIMbtiParser.swift
//  FIG
//
//  Created by estelle on 9/16/25.
//

import Foundation
import FirebaseAI
import OSLog

struct MBTIResult: Codable {
    let mbti: String
    let title: String
    let description: String
    let recommend: String
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
                    소비 내역을 1개의 MBTI 유형으로 선정.
                    필드:
                    - mbti(string):
                    - title(string): (소비 특징과 어율리는 별명)
                    - description(string): (mbti 선정 이유와 소비 특징 한 문장)
                    - recommend(string): (구체적인 소비 개선 습관 한 가지)
                    규칙:
                    - E: 유흥·여행↑, I: 온라인·집↑
                    - S: 생활·필수↑, N: 교육·투자·취미↑
                    - T: 투자·보험↑, F: 간식·미용·기부↑
                    - J: 고정비·정기↑, P: 변동·즉흥↑
                    - 출력은 JSON 배열만, 다른 설명 없이
                    소비 내역:
                    \(text)
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
