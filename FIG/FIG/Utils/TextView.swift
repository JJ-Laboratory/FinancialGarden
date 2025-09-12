//
//  TextView.swift
//  FIG
//
//  Created by Milou on 9/12/25.
//

import UIKit
import UITextViewPlaceholder

final class TextView: UITextView {
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width,
            height: max(size.height, self.placeholderTextView.intrinsicContentSize.height)
        )
    }
}
