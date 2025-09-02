//
//  UIViewController+.swift
//  FIG
//
//  Created by Milou on 8/31/25.
//

import UIKit

extension UIViewController {
    
    func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // 다른 터치 이벤트 방해하지 않음
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
