//
//  ChallengeListHeaderView.swift
//  FIG
//
//  Created by estelle on 8/29/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

class ChallengeListHeaderView: UICollectionReusableView {
    
    let tabView = TabView()
    
    let filterRelay = PublishRelay<FilterType>()
    
    lazy var filterButton = UIButton(type: .system).then {
        var config = UIButton.Configuration.plain()
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .preferredFont(forTextStyle: .subheadline)
            return outgoing
        }
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(textStyle: .subheadline)
        config.imagePadding = 5
        $0.configuration = config
        
        $0.tintColor = .charcoal
        $0.setTitleColor(.charcoal, for: .normal)
        $0.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        $0.semanticContentAttribute = .forceRightToLeft
        $0.setTitle(FilterType.inProgress.rawValue, for: .normal)
        
        let actions = FilterType.allCases.map { type in
            UIAction(title: type.rawValue) { [weak self] _ in
                self?.filterRelay.accept(type)
            }
        }
        $0.menu = UIMenu(children: actions)
        $0.showsMenuAsPrimaryAction = true
    }
    
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    private func setupUI() {
        backgroundColor = .background
        [tabView, filterButton].forEach(addSubview)
        
        tabView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.trailing.equalToSuperview()
        }
        
        filterButton.snp.makeConstraints {
            $0.top.equalTo(tabView.snp.bottom).offset(4)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(4)
        }
    }
}

extension Reactive where Base: ChallengeListHeaderView {
    
    var filterSelected: ControlEvent<FilterType> {      // 메뉴 선택 시 해당 FilterType 방출
        return ControlEvent(events: base.filterRelay.asObservable())
    }
    
    var tabSelected: ControlEvent<Int> {        // TabView 이벤트 그대로 전달
        return base.tabView.rx.tabSelected
    }
}
