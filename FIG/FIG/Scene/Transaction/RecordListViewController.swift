//
//  RecordListViewController.swift
//  FIG
//
//  Created by Milou on 8/29/25.
//

import UIKit
import SnapKit
import Then

final class RecordListViewController: UIViewController {
    
    weak var coordinator: TransactionCoordinator?
    
    // MARK: - UI Components
    
    private let monthButton = UIButton(type: .system).then {
        $0.titleLabel?.font = .preferredFont(forTextStyle: .title2).withWeight(.semibold)
        $0.setTitleColor(.label, for: .normal)
        $0.semanticContentAttribute = .forceRightToLeft
        $0.setImage(UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)), for: .normal)
        $0.tintColor = .charcoal
        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
    }
    
    private let monthlySummaryView = MonthlySummaryView()
    
    private var selectedMonth = Date()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateMonthButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupMockData()
    }
    
    private func setupUI() {
        view.backgroundColor = .background
        
        view.addSubview(monthlySummaryView)
        
        monthlySummaryView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    private func setupNavigationBar() {
        
        monthButton.addTarget(self, action: #selector(monthButtonTapped), for: .touchUpInside)

        let monthBarButtonItem = UIBarButtonItem(customView: monthButton)
        navigationItem.leftBarButtonItem = monthBarButtonItem
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationItem.rightBarButtonItem = addButton
        
        updateMonthButton()
    }
    
    private func updateMonthButton() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월"
        monthButton.setTitle(formatter.string(from: selectedMonth), for: .normal)
    }
    
    private func setupMockData() {
        monthlySummaryView.configure(expense: 345678, income: 1234567)
    }
    
    // TODO: 현재 날짜 포함된 달까지만 뜨도록
    @objc private func monthButtonTapped() {
        let picker = DatePickerController(title: "월 선택", mode: .yearAndMonth)
        picker.dateSelected = { [weak self] date in
            self?.selectedMonth = date
            self?.updateMonthButton()
        }
        
        present(picker, animated: true)
    }
    
    @objc private func addButtonTapped() {
        coordinator?.pushTransactionInput()
    }
}

@available(iOS 17.0, *)
#Preview {
    RecordListViewController()
}
