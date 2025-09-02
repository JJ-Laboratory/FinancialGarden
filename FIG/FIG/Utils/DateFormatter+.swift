//
//  DateFormatter+.swift
//  FIG
//
//  Created by Milou on 9/1/25.
//

import Foundation

extension DateFormatter {
    /// 선택 날짜 (2025년 9월 1일)
    static let fullFormDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 dd일"
        return formatter
    }()
    
    /// 일별 내역 (1일 월요일)
    static let dailyRecordDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "dd일 EEEE"
        return formatter
    }()
    
    /// 월 용 버튼 (8월) - 올해인 경우
    static let monthButtonDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월"
        return formatter
    }()
    
    /// 년 월 용 버튼 (24년 8월) - 올해가 아닌 경우
    static let yearMonthButtonDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yy년 M월"
        return formatter
    }()
}

extension Date {
    var fullDateString: String {
        return DateFormatter.fullFormDate.string(from: self)
    }
    
    var dailyDateString: String {
        return DateFormatter.dailyRecordDate.string(from: self)
    }
    
    var monthString: String {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let dateYear = calendar.component(.year, from: self)
        
        if currentYear == dateYear {
            return DateFormatter.monthButtonDate.string(from: self)
        } else {
            return DateFormatter.yearMonthButtonDate.string(from: self)
        }
    }
}
