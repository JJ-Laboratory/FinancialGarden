//
//  CoreDataError.swift
//  FIG
//
//  Created by Milou on 8/21/25.
//

import Foundation

enum CoreDataError: LocalizedError {
    case fetchFailed(Error)
    case saveFailed(Error)
    case deleteFailed(Error)
    case contextNotAvailable
    case entityNotFound
    case invalidDate
    
    var errorDescription: String? {
        switch self {
        case .fetchFailed(let error):
            return "🧪 Fetch failed: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "🧪 Save failed: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "🧪 Delete failed: \(error.localizedDescription)"
        case .contextNotAvailable:
            return "🧪 Context not available"
            case .entityNotFound:
            return "🧪 Entity not found"
        case .invalidDate:
            return "🧪 Invalid date"
        }
    }
}
