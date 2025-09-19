//
//  TabView.swift
//  FIG
//
//  Created by estelle on 8/28/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

class TabView: UIView {
    
    let weekButton = UIButton(type: .system).then {
        $0.tag = 0
        $0.titleLabel?.numberOfLines = 0
        $0.setTitle("일주일 챌린지", for: .normal)
        $0.titleLabel?.font = .preferredFont(forTextStyle: .headline)
    }
    
    let monthButton = UIButton(type: .system).then {
        $0.tag = 1
        $0.titleLabel?.numberOfLines = 0
        $0.setTitle("한달 챌린지", for: .normal)
        $0.titleLabel?.font = .preferredFont(forTextStyle: .headline)
    }
    
    private lazy var stackView = UIStackView(axis: .horizontal, distribution: .fillEqually, alignment: .center) {
        weekButton
        monthButton
    }
    
    private let indicatorView = UIView().then {
        $0.backgroundColor = .primary
        $0.layer.cornerRadius = 1
        $0.clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        updateButtonColors(selectedIndex: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [stackView, indicatorView].forEach { addSubview($0) }
        
        stackView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }
        
        indicatorView.snp.makeConstraints {
            $0.height.equalTo(2)
            $0.top.equalTo(stackView.snp.bottom).offset(6)
            $0.leading.trailing.equalTo(weekButton)
            $0.bottom.equalToSuperview()
        }
        
        weekButton.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
        monthButton.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc func tabButtonTapped(_ sender: UIButton) {
        selectTab(index: sender.tag)
    }
    
    private func updateButtonColors(selectedIndex: Int) {
        weekButton.setTitleColor(selectedIndex == 0 ? .charcoal : .gray1, for: .normal)
        monthButton.setTitleColor(selectedIndex == 1 ? .charcoal : .gray1, for: .normal)
    }
    
    func selectTab(index: Int) {
        let selectedButton = (index == 0) ? weekButton : monthButton
        
        indicatorView.snp.remakeConstraints {
            $0.height.equalTo(2)
            $0.top.equalTo(stackView.snp.bottom).offset(6)
            $0.leading.trailing.equalTo(selectedButton)
            $0.bottom.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
        
        updateButtonColors(selectedIndex: index)
    }
}

extension Reactive where Base: TabView {
    var tabSelected: ControlEvent<Int> {        // 탭 선택 시 해당 인덱스 방출
        let weekTap = base.weekButton.rx.tap.map { 0 }
        let monthTap = base.monthButton.rx.tap.map { 1 }
        
        let source = Observable.merge(weekTap, monthTap)
        return ControlEvent(events: source)
    }
}
