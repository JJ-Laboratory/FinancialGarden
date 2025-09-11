//
//  MonthlySummary.swift
//  FIG
//
//  Created by Milou on 9/7/25.
//

import Foundation

struct MonthlySummary {
    let expense: Int
    let income: Int
    let hasRecords: Bool
    
    var netAmount: Int {
        return income - expense
    }
}
