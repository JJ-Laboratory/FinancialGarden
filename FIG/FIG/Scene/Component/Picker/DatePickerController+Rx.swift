//
//  DatePickerController+Rx.swift
//  FIG
//
//  Created by Milou on 8/27/25.
//

import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: DatePickerController {
    var dateSelected: ControlEvent<Date> {
        let source = Observable<Date>.create { [weak base] observer in
            base?.dateSelected = {
                observer.on(.next($0))
                observer.on(.completed)
            }
            return Disposables.create { [weak base] in
                guard let base, !base.isBeingDismissed else {
                    return
                }
                base.dismiss(animated: true)
            }
        }
        return ControlEvent(events: source)
    }
}
