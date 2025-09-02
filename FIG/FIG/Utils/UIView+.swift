//
//  UIView+.swift
//  FIG
//
//  Created by Milou on 9/2/25.
//

import UIKit

extension UIView {
    func findFirstResponder() -> UIResponder? {
        if isFirstResponder {
            return self
        }
        for subview in subviews {
            if let responder = subview.findFirstResponder() {
                return responder
            }
        }
        return nil
    }
}
