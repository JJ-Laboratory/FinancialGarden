//
//  UISpringTimingParameters+.swift
//  FIG
//
//  Created by Milou on 8/27/25.
//

import UIKit

extension UISpringTimingParameters {
    @inlinable static func spring(duration: TimeInterval, bounce: CGFloat, initialVelocity: CGVector) -> UISpringTimingParameters {
        if #available(iOS 17.0, *) {
            return UISpringTimingParameters(duration: duration, bounce: bounce, initialVelocity: initialVelocity)
        }
        let dampingRatio = if bounce >= 0 {
            1 - bounce
        } else {
            1 / (1 + bounce)
        }
        return UISpringTimingParameters(dampingRatio: dampingRatio, initialVelocity: initialVelocity)
    }
}

extension UITimingCurveProvider where Self == UISpringTimingParameters {
    static func smooth(duration: CGFloat, initialVelocity: CGVector = .zero) -> UISpringTimingParameters {
        UISpringTimingParameters.spring(duration: duration, bounce: 0.0, initialVelocity: initialVelocity)
    }
    
    static func snappy(duration: CGFloat, initialVelocity: CGVector = .zero) -> UISpringTimingParameters {
        UISpringTimingParameters.spring(duration: duration, bounce: 0.15, initialVelocity: initialVelocity)
    }
    
    static func bouncy(duration: CGFloat, initialVelocity: CGVector = .zero) -> UISpringTimingParameters {
        UISpringTimingParameters.spring(duration: duration, bounce: 0.3, initialVelocity: initialVelocity)
    }
}
