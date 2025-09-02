//
//  ChartProgressView.swift
//  FIG
//
//  Created by estelle on 9/2/25.
//

import UIKit
import Then

final class ChartProgressView: UIView {
    var items: [Item] = [] {
        didSet {
            configureShapeLayer(items: items)
            layoutSublayers(items: items)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 24)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
        backgroundColor = .systemGray6
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(bounds.width, bounds.height) * 0.5
        layoutSublayers(items: items)
    }
}

extension ChartProgressView {
    private func configureShapeLayer(items: [Item]) {
        let sublayers = layer.sublayers ?? []
        for (offset, layer) in sublayers.enumerated() {
            layer.isHidden = offset >= items.count
        }

        let requiredCount = max(0, items.count - sublayers.count)
        let newLayers = repeatElement((), count: requiredCount).map { CALayer() }
        for newLayer in newLayers {
            layer.addSublayer(newLayer)
        }
    }

    private func layoutSublayers(items: [Item]) {
        guard let layers = layer.sublayers else {
            return
        }
        let total = items.reduce(0) { $0 + $1.value }
        let progresses = items.map { CGFloat($0.value) / CGFloat(total) }
        let positions: [CGRect] = progresses.reduce(into: []) {
            let last = $0.last ?? .zero
            $0.append(CGRect(x: last.maxX, y: bounds.minY, width: bounds.width * $1, height: bounds.height))
        }
        for index in items.indices {
            let layer = layers[index]
            layer.frame = positions[index].integral
            layer.backgroundColor = items[index].color.cgColor
        }
    }
}

extension ChartProgressView {
    struct Item {
        let value: Int
        let color: UIColor
        
        @inlinable static func item(value: Int, color: UIColor) -> Item {
            Item(value: value, color: color)
        }
    }
}

#Preview {
    class PreviewViewController: UIViewController {
        let stackView = UIStackView(axis: .vertical, spacing: 40)
        override func viewDidLoad() {
            super.viewDidLoad()
            let progressView = ChartProgressView()
            progressView.items = [
                .item(value: 1, color: .gray3),
                .item(value: 4, color: .secondary),
                .item(value: 2, color: .primary),
                .item(value: 2, color: .pink)
            ]

            let action = UIAction(title: "Random") { _ in
                progressView.items = [
                    .item(value: .random(in: 1...4), color: .gray3),
                    .item(value: .random(in: 1...4), color: .secondary),
                    .item(value: .random(in: 1...4), color: .primary),
                    .item(value: .random(in: 1...4), color: .pink)
                ]
            }
            let button = UIButton(configuration: .filled(), primaryAction: action)
            stackView.addArrangedSubview(progressView)
            stackView.addArrangedSubview(button)
            view.addSubview(stackView)
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            let size = stackView.systemLayoutSizeFitting(
                CGSize(width: view.bounds.width - 40, height: .zero),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            stackView.frame = CGRect(
                x: view.bounds.midX - size.width * 0.5,
                y: view.bounds.midY - size.height * 0.5,
                width: size.width,
                height: size.height
            )
        }
    }
    return PreviewViewController()
}
