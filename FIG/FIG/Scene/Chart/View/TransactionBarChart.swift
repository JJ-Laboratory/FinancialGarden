//
//  TransactionBarChart.swift
//  FIG
//
//  Created by estelle on 8/29/25.
//

import UIKit
import Then

final class TransactionBarChart: UIView {
    private let segments: [BarSegment]
    
    var items: [Item] { segments.map(\.item) }
    var contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    init(numberOfSegments: Int) {
        self.segments = Array(repeating: .empty, count: numberOfSegments).map { BarSegment(item: $0) }
        super.init(frame: .zero)
        for segment in segments {
            addSubview(segment)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setItems<S: Sequence>(_ items: S, alignment: Alignment = .left, animated: Bool) where S.Element == Item {
        // 모든 Transaction의 가장 큰 수입, 지출 값 계산
        let maxValues = items.reduce((income: 0, expense: 0)) { result, item in
            switch item {
            case .transaction(_, let income, let expense):
                return (max(income, result.income), max(expense, result.expense))
            case .empty:
                return result
            }
        }
        
        let prefix = Array(items.prefix(segments.count)) // 최대 count 개수만큼 자르고
        let newItems = switch alignment { // 모자란 항목은 empty로 할당
        case .left:
            prefix + Array(repeating: .empty, count: segments.count - prefix.count)
        case .right:
            Array(repeating: .empty, count: segments.count - prefix.count) + prefix
        }
        
        // Segment 업데이트
        for (segment, item) in zip(segments, newItems) {
            segment.setItem(item, maxIncome: maxValues.income, maxExpense: maxValues.expense, animated: animated)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard !segments.isEmpty else {
            return
        }
        let rect = bounds.inset(by: contentInsets)
        let width: CGFloat = 24
        let spacing = (rect.width - width * CGFloat(segments.count)) / CGFloat(segments.count - 1)
        for (offset, segment) in segments.enumerated() {
            segment.frame = CGRect(
                x: rect.minX + (width + spacing) * CGFloat(offset),
                y: rect.minY,
                width: width,
                height: rect.height
            )
        }
    }
}

// MARK: - TransactionBarChart.Item

extension TransactionBarChart {
    enum Item {
        case transaction(label: String, income: Int, expense: Int)
        case empty
        
        var labelText: String? {
            if case .transaction(let label, _, _) = self {
                return label
            }
            return nil
        }
    }
}

// MARK: - TransactionBarChart.Alignment

extension TransactionBarChart {
    enum Alignment {
        case left
        case right
    }
}

// MARK: - TransactionBarChart.BarSegment

extension TransactionBarChart {
    private class BarSegment: UIView {
        private let incomeLayer = CALayer().then {
            $0.cornerRadius = 5
            $0.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            $0.backgroundColor = UIColor.primary.cgColor
        }
        
        private let expenseLayer = CALayer().then {
            $0.cornerRadius = 5
            $0.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            $0.backgroundColor = UIColor.secondary.cgColor
        }
        
        private let label = UILabel().then {
            $0.font = .preferredFont(forTextStyle: .subheadline)
            $0.textColor = .gray1
        }
        
        private let spacing: CGFloat = 20
        
        private var maxIncome = 0
        private var maxExpense = 0
        private(set) var item: Item
        
        init(item: Item) {
            self.item = item
            super.init(frame: .zero)
            layer.addSublayer(incomeLayer)
            layer.addSublayer(expenseLayer)
            addSubview(label)
            
            label.text = item.labelText
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setItem(_ item: Item, maxIncome: Int, maxExpense: Int, animated: Bool) {
            self.item = item
            self.maxIncome = maxIncome
            self.maxExpense = maxExpense
            self.label.text = item.labelText
            
            if animated {
                setNeedsLayout()
            } else {
                CATransaction.setDisableActions(true)
                setNeedsLayout()
                CATransaction.commit()
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            guard maxIncome > 0 || maxExpense > 0 else {
                return
            }
            let textSize = label.intrinsicContentSize
            label.frame = CGRect(
                x: bounds.midX - textSize.width * 0.5,
                y: bounds.maxY - textSize.height,
                width: textSize.width,
                height: textSize.height
            )
            
            let barRect = CGRect(
                x: bounds.minX,
                y: bounds.minY,
                width: bounds.width,
                height: bounds.height - spacing - textSize.height
            )
            
            // 수입이 차지할 비율
            let incomeRatio = CGFloat(maxIncome) / CGFloat(maxIncome + maxExpense)
            // 지출이 차지할 비율
            let expenseRatio = 1 - incomeRatio
            
            switch item {
            case .transaction(_, let income, let expense):
                let incomeHeight = income > 0 ? barRect.height * incomeRatio * (CGFloat(income) / CGFloat(maxIncome)) : 0
                let expenseHeight = expense > 0 ? barRect.height * expenseRatio * (CGFloat(expense) / CGFloat(maxExpense)) : 0
                incomeLayer.frame = CGRect(
                    x: barRect.minX,
                    y: barRect.maxY * incomeRatio - incomeHeight,
                    width: barRect.width,
                    height: incomeHeight
                ).integral
                
                expenseLayer.frame = CGRect(
                    x: barRect.minX,
                    y: barRect.maxY * incomeRatio,
                    width: barRect.width,
                    height: expenseHeight
                ).integral
            case .empty:
                incomeLayer.frame = CGRect(x: barRect.minX, y: barRect.maxY * incomeRatio, width: barRect.width, height: 0)
                expenseLayer.frame = CGRect(x: barRect.minX,y: barRect.maxY * incomeRatio, width: barRect.width, height: 0)
            }
        }
    }
}

// MARK: - Preview TransactionBarChart

import  SnapKit

#Preview {
    class PreviewViewController: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemBackground
            
            let chart = TransactionBarChart(numberOfSegments: 6)
            let items: [TransactionBarChart.Item] = [
                .transaction(label: "1", income: 1_000_000, expense: 200_000),
                .transaction(label: "2", income: 2_000_000, expense: 400_000),
                .transaction(label: "3", income: 3_000_000, expense: 600_000),
                .transaction(label: "4", income: 4_000_000, expense: 800_000),
                .transaction(label: "5", income: 5_000_000, expense: 1_000_000),
                .transaction(label: "6", income: 6_000_000, expense: 1_200_000)
            ]
            chart.setItems(items, animated: false)
            
            let action = UIAction(title: "Random Data") { [chart] _ in
                let newItems: [TransactionBarChart.Item] = stride(from: 1, through: 6, by: 1).map {
                    .transaction(
                        label: "\($0)",
                        income: (1...12).randomElement().map { $0 * 1_000_000 } ?? 0,
                        expense: (2...12).randomElement().map { $0 * 400_000 } ?? 0
                    )
                }
                chart.setItems(newItems, animated: true)
            }
            let button = UIButton(configuration: .filled(), primaryAction: action)
            
            let stackView = UIStackView(axis: .vertical, spacing: 40, arrangedSubviews: [chart, button])
            view.addSubview(stackView)
            stackView.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.centerY.equalToSuperview()
            }
            chart.snp.makeConstraints {
                $0.height.equalTo(400)
            }
        }
    }
    return PreviewViewController()
}
