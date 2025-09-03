//
//  UICollectionReusableView+.swift
//  FIG
//
//  Created by Milou on 9/3/25.
//

import UIKit

extension UICollectionReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
