//
//  Int+.swift
//  FIG
//
//  Created by Milou on 8/26/25.
//

import Foundation

extension Int {
    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()
    
    var formattedWithComma: String {
        return Int.numberFormatter.string(from: NSNumber(value: self)) ?? "0"
    }
}
