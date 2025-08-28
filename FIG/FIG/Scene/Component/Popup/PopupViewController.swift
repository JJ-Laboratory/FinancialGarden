//
//  PopupViewController.swift
//  FIG
//
//  Created by estelle on 8/28/25.
//

import UIKit
import SnapKit

class popupViewController: UIViewController {
    
    private let popupView: PopupView
    private let popupTransitioningDelegate = PopupTransitioningDelegate()
    
    init(type: ChallengeType, count: Int) {
        self.popupView = PopupView(type: type, count: count)
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .custom
        transitioningDelegate = popupTransitioningDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        view.addSubview(popupView)
        popupView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        popupView.onChallengeTapped = { [weak self] in
            self?.dismiss(animated: true)
        }
        
        popupView.onCloseTapped = { [weak self] in
            self?.dismiss(animated: true)
        }
    }
}
