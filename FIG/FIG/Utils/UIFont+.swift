//
//  UIFont+.swift
//  FIG
//
//  Created by Milou on 8/26/25.
//

import UIKit

extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        guard let textStyle = fontDescriptor.fontAttributes[UIFontDescriptor.AttributeName.textStyle] as? UIFont.TextStyle else {
            return self
        }
        let traitCollection = UITraitCollection(preferredContentSizeCategory: .large)
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle, compatibleWith: traitCollection)
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(
            for: .systemFont(ofSize: descriptor.pointSize, weight: weight),
            compatibleWith: nil
        )
    }
}
