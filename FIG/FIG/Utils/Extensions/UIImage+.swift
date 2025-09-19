//
//  UIImage+.swift
//  FIG
//
//  Created by estelle on 9/12/25.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyGif

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

extension Reactive where Base: UIImageView {
    var gifImage: Binder<String> {
        return Binder(self.base) { imageView, gifName in
            do {
                let gif = try UIImage(gifName: "\(gifName).gif")
                imageView.setGifImage(gif, loopCount: -1)
            } catch {
                print("GIF 로드 실패: \(error)")
                if let defaultImage = try? UIImage(gifName: "default.gif") {
                    imageView.setGifImage(defaultImage, loopCount: -1)
                }
            }
        }
    }
}
