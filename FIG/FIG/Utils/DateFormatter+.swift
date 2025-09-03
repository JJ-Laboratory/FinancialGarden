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
    
    static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.M.d"
        return formatter
    }()
    
    static let monthDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M.d"
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
    
    func toFormattedRange(to endDate: Date) -> String {
        let startDate = self
        
        let startYear = Calendar.current.component(.year, from: startDate)
        let endYear = Calendar.current.component(.year, from: endDate)
        
        let startDateString = DateFormatter.fullDateFormatter.string(from: startDate)
        
        let endDateString: String
        if startYear == endYear {
            endDateString = DateFormatter.monthDayFormatter.string(from: endDate)
        } else {
            endDateString = DateFormatter.fullDateFormatter.string(from: endDate)
        }
        
        return "\(startDateString) ~ \(endDateString)"
    }
    
    var dDayString: String {
        let today = Calendar.current.startOfDay(for: Date())
        let targetDay = Calendar.current.startOfDay(for: self)
        
        guard let days = Calendar.current.dateComponents([.day], from: today, to: targetDay).day else {
            return ""
        }
        
        if days == 0 {
            return "D-day"
        } else if days > 0 {
            return "D-\(days)"
        } else {
            return "D+\(abs(days))"
        }
    }
    
    func progress(to endDate: Date, now: Date = Date()) -> Float {
        let startDate = self
        let totalDuration = endDate.timeIntervalSince(startDate)
        guard totalDuration > 0 else {
            return 1.0
        }
        
        let elapsedTime = now.timeIntervalSince(startDate)
        guard elapsedTime > 0 else {
            return 0.0
        }
        
        let rawProgress = elapsedTime / totalDuration
        let progress = min(1.0, max(0.0, rawProgress))
        
        return Float(progress)
    }
}

