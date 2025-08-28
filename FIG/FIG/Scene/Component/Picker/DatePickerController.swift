//
//  DatePickerController.swift
//  FIG
//
//  Created by Milou on 8/27/25.
//

import UIKit
import SnapKit
import Then

final class DatePickerController: PickerController {
    private let picker: DatePickerType
    
    var date: Date {
        get { picker.date }
        set { picker.date = newValue }
    }
    
    var minimumDate: Date? {
        get { picker.minimumDate }
        set { picker.minimumDate = newValue }
    }
    
    var maximumDate: Date? {
        get { picker.maximumDate }
        set { picker.maximumDate = newValue }
    }
    
    var dateSelected: ((Date) -> Void)?
    
    init(title: String, date: Date = .now, mode: Mode) {
        switch mode {
        case .date:
            picker = UIDatePicker().then {
                $0.date = date
                $0.datePickerMode = .date
                $0.preferredDatePickerStyle = .wheels
            }
        case .yearAndMonth:
            if #available(iOS 17.4, *) {
                picker = UIDatePicker().then {
                    $0.date = date
                    $0.datePickerMode = .yearAndMonth
                    $0.preferredDatePickerStyle = .wheels
                }
            } else {
                picker = YearAndMonthDatePicker().then {
                    $0.date = date
                }
            }
        }
        super.init(title: title, contentView: picker)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let applyAction = UIAction { [unowned self] _ in
            let date = picker.date
            if let dateSelected {
                dateSelected(date)
            }
            dismiss(animated: true)
        }
        applyButton.addAction(applyAction, for: .primaryActionTriggered)
    }
}

// MARK: - DatePickerController.Mode

extension DatePickerController {
    enum Mode {
        case date
        case yearAndMonth
    }
}

// MARK: - DatePickerController.DatePicker

private protocol DatePickerType: UIView {
    var date: Date { get set }
    var minimumDate: Date? { get set }
    var maximumDate: Date? { get set }
    func setDate(_ date: Date, animated: Bool)
}

// MARK: - YearAndMonthDatePicker

private class YearAndMonthDatePicker: UIPickerView, DatePickerType, UIPickerViewDataSource, UIPickerViewDelegate {
    enum DateComponent: CaseIterable {
        case year
        case month
    }
    
    private var needsUpdate = false
    private var backingDate: Date = .now
    
    var calendar = Calendar.current
    
    var date: Date {
        get { backingDate }
        set {
            backingDate = newValue
            setNeedsUpdateComponents()
        }
    }
    
    var minimumDate: Date? {
        didSet {
            guard minimumDate != oldValue else {
                return
            }
            setNeedsUpdateComponents()
        }
    }
    
    var maximumDate: Date? {
        didSet {
            guard maximumDate != oldValue else {
                return
            }
            setNeedsUpdateComponents()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        dataSource = self
        setNeedsUpdateComponents()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDate(_ date: Date, animated: Bool) {
        let minimumDate = minimumDate ?? .distantPast
        
        let minimimYear = calendar.component(.year, from: minimumDate)
        let year = calendar.component(.year, from: date)
        selectRow(year - minimimYear, inComponent: component(for: .year), animated: animated)
        
        let count = pickerView(self, numberOfRowsInComponent: 1)
        let minimumMonth = calendar.component(.month, from: minimumDate)
        let month = calendar.component(.month, from: date)
        selectRow(count / 2 / 12 * 12 + (month - minimumMonth), inComponent: component(for: .month), animated: animated)
    }
    
    private func dateComponent(for component: Int) -> DateComponent {
        // 필요하면 언어에 따른 순서 변경
        switch component {
        case 0:
            return .year
        default:
            return .month
        }
    }
    
    private func component(for dateComponent: DateComponent) -> Int {
        // 필요하면 언어에 따른 순서 변경
        switch dateComponent {
        case .year:
            return 0
        case .month:
            return 1
        }
    }
    
    private func setNeedsUpdateComponents() {
        guard !needsUpdate else {
            return
        }
        needsUpdate = true
        DispatchQueue.main.async {
            self.updateComponentsIfNeeded()
        }
    }
    
    private func updateComponentsIfNeeded() {
        guard needsUpdate else {
            return
        }
        reloadAllComponents()
        setDate(backingDate, animated: false)
        needsUpdate = false
    }
    
    // MARK: UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return DateComponent.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch dateComponent(for: component) {
        case .year:
            let minimumDate = minimumDate ?? .distantPast
            let maximumDate = maximumDate ?? .distantFuture
            let components = calendar.dateComponents([.year], from: minimumDate, to: maximumDate)
            return components.year ?? 0
        case .month:
            return Int(UInt16.max / 12 * 12)
        }
    }
    
    // MARK: UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent: Int) {
        let minimumDate = minimumDate ?? .distantPast
        
        let yearOffset = selectedRow(inComponent: component(for: .year))
        let year = calendar.component(.year, from: minimumDate) + yearOffset
        
        let monthOffset = selectedRow(inComponent: component(for: .month)) % 12
        let month = calendar.component(.month, from: minimumDate) + monthOffset
        
        var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: backingDate)
        dateComponents.year = year
        dateComponents.month = month
        if let newDate = calendar.date(from: dateComponents) {
            backingDate = newDate
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        // 언어에 따른 사이즈 변경
        switch dateComponent(for: component) {
        case .year:
            return 96
        case .month:
            return 66
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 34
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let minimumDate = minimumDate ?? .distantPast
        switch dateComponent(for: component) {
        case .year:
            let from = calendar.date(byAdding: .year, value: row, to: minimumDate) ?? minimumDate
            return from.formatted(Date.FormatStyle().year(.relatedGregorian()))
        case .month:
            let from = calendar.date(byAdding: .month, value: row, to: minimumDate) ?? minimumDate
            return from.formatted(Date.FormatStyle().month(.wide))
        }
    }
}

// MARK: - UIDatePicker (DatePickerType)

extension UIDatePicker: DatePickerType {
}

// MARK: - DatePickerController Preview

#Preview {
    class PreviewViewController: UIViewController {
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            let picker = DatePickerController(title: "Date Picker", mode: .yearAndMonth)
            picker.minimumDate = date(year: 2010, month: 1, day: 1)
            picker.maximumDate = date(year: 2030, month: 12, day: 31)
            present(picker, animated: true)
        }
        
        func date(year: Int, month: Int, day: Int) -> Date {
            let components = DateComponents(year: year, month: month, day: day)
            return Calendar.current.date(from: components)!
        }
    }
    return PreviewViewController()
}
