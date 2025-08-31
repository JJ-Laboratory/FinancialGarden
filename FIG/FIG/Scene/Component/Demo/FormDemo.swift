//
//  FormDemo.swift
//  FIG
//
//  Created by Milou on 8/28/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import RxGesture

class FormDemo: UIViewController {
    let categoryLabel = UILabel().then {
        $0.text = "식비"
        $0.font = .preferredFont(forTextStyle: .body).withWeight(.semibold)
    }
    
    let weekly = UIButton(configuration: .filled()).then {
        $0.configuration?.title = "일주일"
    }
    let monthly = UIButton(configuration: .filled()).then {
        $0.configuration?.title = "한달"
    }
    
    let amountLabel = UILabel().then {
        $0.text = "100,000,000원"
        $0.font = .preferredFont(forTextStyle: .body).withWeight(.semibold)
    }
    let amount1 = UIButton(configuration: .tinted()).then {
        $0.configuration?.title = "무지출"
        $0.configuration?.buttonSize = .small
    }
    let amount2 = UIButton(configuration: .tinted()).then {
        $0.configuration?.title = "+1만원"
        $0.configuration?.buttonSize = .small
    }
    let amount3 = UIButton(configuration: .tinted()).then {
        $0.configuration?.title = "+5만원"
        $0.configuration?.buttonSize = .small
    }
    let amount4 = UIButton(configuration: .tinted()).then {
        $0.configuration?.title = "+10만원"
        $0.configuration?.buttonSize = .small
    }
    
    let memoTextField = UITextField().then {
        $0.placeholder = "메모입력해라"
    }
    
    let label1 = UILabel().then {
        $0.text = "헬로월드"
    }
    let textField1 = UITextField().then {
        $0.placeholder = "거래처"
        $0.font = .preferredFont(forTextStyle: .body)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Form"
        view.backgroundColor = UIColor(white: 0.968, alpha: 1)
        
        let scrollView = UIScrollView().then {
            $0.alwaysBounceVertical = true
        }
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
        }
        
        let formStackView = UIStackView(axis: .vertical, spacing: 40) {
            FormView {
                FormItem("카테고리")
                    .image(UIImage(systemName: "circle"))
                    .showsDisclosureIndicator(true)
                    .action {
                        print("카테고리 선택")
                    }
                
                FormItem("기간")
                    .image(UIImage(systemName: "rectangle"))
                    .trailing {
                        .hstack {
                            weekly
                            monthly
                        }
                    }
                
                FormItem("금액")
                    .image(UIImage(systemName: "triangle"))
                    .trailing {
                        amountLabel
                    }
                    .bottom(alignment: .center) {
                        .adaptiveStack {
                            amount1
                            amount2
                            amount3
                            amount4
                        } contentSizeChanges: { contentSize, stackView in
                            if contentSize >= .extraExtraExtraLarge {
                                stackView.axis = .vertical
                            } else {
                                stackView.axis = .horizontal
                            }
                        }
                    }
                
                FormItem("날짜")
                    .image(UIImage(systemName: "star"))
                
                FormItem("메모")
                    .image(UIImage(systemName: "heart"))
                    .bottom {
                        memoTextField
                    }
            }
            
            FormView(titleSize: .fixed(100)) {
                FormItem("카테고리")
                    .image(UIImage(systemName: "eraser"))
                    .showsDisclosureIndicator(true)
                    .trailing {
                        categoryLabel
                    }
                FormItem("거래처")
                    .image(UIImage(systemName: "apple.logo"))
                    .trailing {
                        textField1
                    }
                FormItem("HELLO")
                    .image(UIImage(systemName: "scribble"))
                    .bottom {
                        label1
                    }
            }
        }
        scrollView.addSubview(formStackView)
        formStackView.snp.makeConstraints {
            $0.top.bottom.width.equalTo(scrollView.contentLayoutGuide)
            $0.leading.trailing.equalTo(scrollView.frameLayoutGuide).inset(20)
        }
    }
}

#Preview {
    UINavigationController(rootViewController: FormDemo())
}
