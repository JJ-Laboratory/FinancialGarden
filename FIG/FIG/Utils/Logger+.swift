//
//  Logger+.swift
//  FIG
//
//  Created by Milou on 8/21/25.
//

import Foundation
import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.sophia.FIG"
    
    static let coreData = Logger(subsystem: subsystem, category: "CoreData")
    static let category = Logger(subsystem: subsystem, category: "CategoryService")
    static let transaction = Logger(subsystem: subsystem, category: "TransactionRepository")
}
