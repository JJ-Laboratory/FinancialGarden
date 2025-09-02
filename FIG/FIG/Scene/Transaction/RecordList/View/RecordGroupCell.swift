//
//  RecordGroupCell.swift
//  FIG
//
//  Created by Milou on 8/29/25.
//

import UIKit
import SnapKit
import Then

final class SectionHeaderCell: UICollectionViewCell {
    
    private let titleLabel = UILabel().then {
        $0.text = "전체 내역"
        $0.font = .preferredFont(forTextStyle: .headline)
        $0.textColor = .charcoal
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

final class RecordGroupCell: UICollectionViewCell {
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
    }
    
    private let spacerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    var onRecordTap: ((Transaction) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 10
        clipsToBounds = true
        
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        spacerView.snp.makeConstraints {
            $0.height.equalTo(16)
        }
    }
    
    func configure(with recordGroup: RecordListViewController.RecordGroup) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let headerView = RecordHeaderView()
        headerView.configure(
            date: recordGroup.date,
            income: recordGroup.transactions
                .filter { $0.category.transactionType == .income }
                .reduce(0) { $0 + $1.amount },
            expense: recordGroup.transactions
                .filter { $0.category.transactionType == .expense }
                .reduce(0) { $0 + $1.amount }
        )
        
        stackView.addArrangedSubview(headerView)
        stackView.addArrangedSubview(spacerView)
        
        for record in recordGroup.transactions {
            let recordView = RecordItemView()
            recordView.configure(with: record)
            
            recordView.onTap = { [weak self] transaction in
                self?.onRecordTap?(transaction)
            }
            
            stackView.addArrangedSubview(recordView)
        }
    }
}

// MARK: - Preview
#if DEBUG
import SwiftUI

// 1. UIKit 뷰를 SwiftUI에서 미리보기 위한 래퍼(Wrapper) 구조체
struct RecordGroupCellPreviewWrapper: UIViewRepresentable {
    
    // 이 래퍼가 미리보기할 데이터를 가지고 있도록 합니다.
    let recordGroup: RecordListViewController.RecordGroup
    
    // SwiftUI가 뷰를 처음 생성할 때 호출합니다.
    func makeUIView(context: Context) -> RecordGroupCell {
        let cell = RecordGroupCell()
        cell.configure(with: recordGroup)
        cell.backgroundColor = .systemGroupedBackground
        return cell
    }
    
    // 뷰의 상태가 변경될 때 호출됩니다. (여기서는 정적 프리뷰라 비워둬도 무방합니다.)
    func updateUIView(_ uiView: RecordGroupCell, context: Context) {
        uiView.configure(with: recordGroup) // 데이터가 바뀔 경우를 대비해 업데이트 로직 추가
    }
}

// 2. 프리뷰 코드 수정
struct RecordGroupCell_Previews: PreviewProvider {
    static var previews: some View {
        // 샘플 데이터 생성 (이 부분은 동일합니다)
        let category = Category(id: UUID(), title: "카페・간식", iconName: "cup.and.heat.waves.fill", transactionType: .expense)
        let incomeCategory = Category(id: UUID(), title: "급여", iconName: "wonsign.arrow.trianglehead.counterclockwise.rotate.90", transactionType: .income)
        
        let recordGroup = RecordListViewController.RecordGroup(
            date: Date(),
            transactions: [
                Transaction(amount: 5560, category: category, title: "스타벅스", payment: .card),
                Transaction(amount: 5560, category: category, title: "스타벅스", payment: .card),
                Transaction(amount: 100000, category: incomeCategory, title: "알바", payment: .account)
            ]
        )
        
        // 위에서 만든 래퍼를 사용하여 프리뷰를 생성합니다.
        RecordGroupCellPreviewWrapper(recordGroup: recordGroup)
        //            .frame(height: 250) // 이제 정상적으로 작동합니다.
            .previewLayout(.sizeThatFits)
            .previewDisplayName("RecordGroupCell")
    }
}
#endif
