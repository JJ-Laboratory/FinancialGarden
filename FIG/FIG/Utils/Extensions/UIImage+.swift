//
//  UIImage+.swift
//  FIG
//
//  Created by estelle on 9/12/25.
//

import UIKit

extension UIImage {
    func resized(height: CGFloat) -> UIImage? {
        let scale = height / self.size.height
        let newWidth = self.size.width * scale
        let newSize = CGSize(width: newWidth, height: height)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        return renderer.image { context in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
