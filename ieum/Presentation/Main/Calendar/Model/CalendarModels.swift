import Foundation
import UIKit

// MARK: - 캘린더에 표시할 기록 타입

enum CalendarRecordType: String, CaseIterable {
    case treatment   // 치료기록
    case mood        // 기분
    case symptom     // 특이증상
    case diet        // 식이상태
    
    var title: String {
        switch self {
        case .treatment: return "치료기록"
        case .mood: return "기분"
        case .symptom: return "특이증상"
        case .diet: return "식이상태"
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .treatment: return Colors.Lime.l100
        case .mood: return UIColor(hex: "#FFF3E0") // 연한 주황
        case .symptom: return UIColor(hex: "#FFE0B2") // 주황
        case .diet: return UIColor(hex: "#E8F5E9") // 연한 초록
        }
    }
    
    var selectedBackgroundColor: UIColor {
        switch self {
        case .treatment: return Colors.Lime.l200
        case .mood: return UIColor(hex: "#FFB74D") // 진한 주황
        case .symptom: return UIColor(hex: "#FF9800") // 진한 주황
        case .diet: return UIColor(hex: "#81C784") // 진한 초록
        }
    }
    
    var iconName: String {
        switch self {
        case .treatment: return "treatmentrecord-icon"
        case .mood: return "feeling-normal"
        case .symptom: return "symptom-icon"
        case .diet: return "meal-icon"
        }
    }
}

// MARK: - 기분 상태

enum MoodType: String, CaseIterable {
    case veryGood = "very_good"
    case good = "good"
    case normal = "normal"
    case bad = "bad"
    case veryBad = "very_bad"
    
    var iconName: String {
        switch self {
        case .veryGood: return "feeling-very-good"
        case .good: return "feeling-good"
        case .normal: return "feeling-normal"
        case .bad: return "feeling-bad"
        case .veryBad: return "feeling-very-bad"
        }
    }
    
    var emoji: String {
        switch self {
        case .veryGood: return "😄"
        case .good: return "😊"
        case .normal: return "😐"
        case .bad: return "😢"
        case .veryBad: return "😭"
        }
    }
}

// MARK: - 날짜별 기록 데이터

struct CalendarDayRecord {
    let date: Date
    var hasTreatment: Bool
    var mood: MoodType?
    var hasSymptom: Bool
    var hasDiet: Bool
    
    var hasAnyRecord: Bool {
        return hasTreatment || mood != nil || hasSymptom || hasDiet
    }
    
    init(date: Date, hasTreatment: Bool = false, mood: MoodType? = nil, hasSymptom: Bool = false, hasDiet: Bool = false) {
        self.date = date
        self.hasTreatment = hasTreatment
        self.mood = mood
        self.hasSymptom = hasSymptom
        self.hasDiet = hasDiet
    }
}

// MARK: - 캘린더 날짜 아이템

struct CalendarDayItem {
    let date: Date?
    let isCurrentMonth: Bool
    let isToday: Bool
    var record: CalendarDayRecord?
    
    var day: Int? {
        guard let date = date else { return nil }
        return Calendar.current.component(.day, from: date)
    }
    
    var weekday: Int? {
        guard let date = date else { return nil }
        return Calendar.current.component(.weekday, from: date) // 1: 일요일, 7: 토요일
    }
}
