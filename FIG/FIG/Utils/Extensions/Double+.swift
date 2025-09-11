//
//  Double+.swift
//  FIG
//
//  Created by estelle on 9/4/25.
//

import Foundation

extension Double {
    func rounded(to decimals: Int) -> Double {
        let scale = pow(10.0, Double(decimals))
        return (self * scale).rounded() / scale
    }
}
