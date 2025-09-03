//
//  ProgressView.swift
//  FIG
//
//  Created by estelle on 9/2/25.
//

import UIKit
import SnapKit
import Then

class ProgressView: UIView {
    private let trackView = UIView()
    
    private let progressView = UIView()
    
    var trackTintColor: UIColor? {
        get { trackView.backgroundColor }
        set { trackView.backgroundColor = newValue }
    }
    
    var thickness: CGFloat = 8 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    var progress: Float = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override var intrinsicContentSize: CGSize { CGSize(width: UIView.noIntrinsicMetric, height: thickness ) }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        updateTintColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressView.frame = CGRect(
            x: bounds.minX,
            y: bounds.minY,
            width: bounds.width * CGFloat(progress),
            height: bounds.height
        )
        layer.cornerRadius = min(bounds.width, bounds.height) * 0.5
    }
    
    func setProgress(_ progress: Float, animated: Bool = false, duration: TimeInterval = 0.8) {
        self.progress = min(max(progress, 0), 1)
        
        if animated {
            UIView.animate(withDuration: duration) {
                self.layoutIfNeeded()
            }
        } else {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
}

// MARK: - ProgressView (Private)

extension ProgressView {
    private func configure() {
        addSubview(trackView)
        trackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        addSubview(progressView)
        updateTintColor()
        
        clipsToBounds = true
    }
    
    private func updateTintColor() {
        progressView.backgroundColor = tintColor
    }
}
