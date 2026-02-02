import Foundation
import Combine

final class CalendarViewModel: ObservableObject {
    
    // MARK: - Inputs
    
    let viewDidLoad = PassthroughSubject<Void, Never>()
    let didSelectMonth = PassthroughSubject<Date, Never>()
    let didSelectFilter = PassthroughSubject<CalendarRecordType?, Never>()
    let didSelectDate = PassthroughSubject<Date, Never>()
    
    // MARK: - Outputs
    
    @Published private(set) var currentMonth: Date = Date()
    @Published private(set) var selectedFilter: CalendarRecordType? = .treatment
    @Published private(set) var calendarDays: [CalendarDayItem] = []
    @Published private(set) var records: [CalendarDayRecord] = []
    @Published private(set) var totalDaysInMonth: Int = 0
    @Published private(set) var recordedDaysCount: Int = 0
    
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    private let calendar = Calendar.current
    
    // MARK: - Computed Properties
    
    var currentMonthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.M"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: currentMonth)
    }
    
    // MARK: - Initializer
    
    init() {
        bindInputs()
    }
    
    // MARK: - Bindings
    
    private func bindInputs() {
        viewDidLoad
            .sink { [weak self] in
                self?.loadCalendarData()
            }
            .store(in: &cancellables)
        
        didSelectMonth
            .sink { [weak self] date in
                self?.currentMonth = date
                self?.loadCalendarData()
            }
            .store(in: &cancellables)
        
        didSelectFilter
            .sink { [weak self] filter in
                self?.selectedFilter = filter
                self?.updateCalendarDays()
            }
            .store(in: &cancellables)
        
        didSelectDate
            .sink { [weak self] date in
                // 추후 날짜 선택 시 동작 구현
                print("Selected date: \(date)")
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    
    private func loadCalendarData() {
        generateCalendarDays()
        loadMockRecords()
        updateCalendarDays()
        updateStatistics()
    }
    
    private func generateCalendarDays() {
        var days: [CalendarDayItem] = []
        
        // 해당 월의 첫째 날
        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)),
              let range = calendar.range(of: .day, in: .month, for: currentMonth) else {
            return
        }
        
        // 첫째 날의 요일 (1: 일요일, 7: 토요일)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        // 이전 달 날짜 채우기 (첫째 날 전의 빈 공간)
        let previousMonthDays = firstWeekday - 1
        if previousMonthDays > 0 {
            if let previousMonth = calendar.date(byAdding: .month, value: -1, to: firstDayOfMonth),
               let previousMonthRange = calendar.range(of: .day, in: .month, for: previousMonth) {
                let startDay = previousMonthRange.count - previousMonthDays + 1
                for day in startDay...previousMonthRange.count {
                    if let date = calendar.date(from: DateComponents(
                        year: calendar.component(.year, from: previousMonth),
                        month: calendar.component(.month, from: previousMonth),
                        day: day
                    )) {
                        days.append(CalendarDayItem(date: date, isCurrentMonth: false, isToday: false))
                    }
                }
            }
        }
        
        // 현재 달 날짜 채우기
        let today = Date()
        for day in range {
            if let date = calendar.date(from: DateComponents(
                year: calendar.component(.year, from: currentMonth),
                month: calendar.component(.month, from: currentMonth),
                day: day
            )) {
                let isToday = calendar.isDate(date, inSameDayAs: today)
                days.append(CalendarDayItem(date: date, isCurrentMonth: true, isToday: isToday))
            }
        }
        
        // 다음 달 날짜 채우기 (마지막 주의 빈 공간)
        let remainingDays = (7 - (days.count % 7)) % 7
        if remainingDays > 0 {
            if let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstDayOfMonth) {
                for day in 1...remainingDays {
                    if let date = calendar.date(from: DateComponents(
                        year: calendar.component(.year, from: nextMonth),
                        month: calendar.component(.month, from: nextMonth),
                        day: day
                    )) {
                        days.append(CalendarDayItem(date: date, isCurrentMonth: false, isToday: false))
                    }
                }
            }
        }
        
        calendarDays = days
        totalDaysInMonth = range.count
    }
    
    private func loadMockRecords() {
        // Mock 데이터 생성
        var mockRecords: [CalendarDayRecord] = []
        
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth) else { return }
        
        for day in range {
            if let date = calendar.date(from: DateComponents(
                year: calendar.component(.year, from: currentMonth),
                month: calendar.component(.month, from: currentMonth),
                day: day
            )) {
                // 랜덤하게 기록 생성 (약 40% 확률로 기록 있음)
                let hasRecord = Int.random(in: 0...10) < 4
                
                if hasRecord {
                    let hasTreatment = Bool.random()
                    let mood: MoodType? = Bool.random() ? MoodType.allCases.randomElement() : nil
                    let hasSymptom = Bool.random()
                    let hasDiet = Bool.random()
                    
                    let record = CalendarDayRecord(
                        date: date,
                        hasTreatment: hasTreatment,
                        mood: mood,
                        hasSymptom: hasSymptom,
                        hasDiet: hasDiet
                    )
                    mockRecords.append(record)
                }
            }
        }
        
        records = mockRecords
    }
    
    private func updateCalendarDays() {
        // records를 calendarDays에 매핑
        calendarDays = calendarDays.map { item in
            var updatedItem = item
            if let date = item.date {
                updatedItem.record = records.first { calendar.isDate($0.date, inSameDayAs: date) }
            }
            return updatedItem
        }
    }
    
    private func updateStatistics() {
        // 선택된 필터에 따라 기록된 날짜 수 계산
        if let filter = selectedFilter {
            switch filter {
            case .treatment:
                recordedDaysCount = records.filter { $0.hasTreatment }.count
            case .mood:
                recordedDaysCount = records.filter { $0.mood != nil }.count
            case .symptom:
                recordedDaysCount = records.filter { $0.hasSymptom }.count
            case .diet:
                recordedDaysCount = records.filter { $0.hasDiet }.count
            }
        } else {
            recordedDaysCount = records.filter { $0.hasAnyRecord }.count
        }
    }
    
    // MARK: - Public Methods
    
    func goToPreviousMonth() {
        if let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            didSelectMonth.send(previousMonth)
        }
    }
    
    func goToNextMonth() {
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            didSelectMonth.send(nextMonth)
        }
    }
    
    func getIconForDay(_ item: CalendarDayItem) -> String? {
        guard let record = item.record else { return nil }
        
        // 필터가 선택되어 있으면 해당 필터의 아이콘만 표시
        if let filter = selectedFilter {
            switch filter {
            case .treatment:
                return record.hasTreatment ? "checkmark.circle.fill" : nil
            case .mood:
                return record.mood?.iconName
            case .symptom:
                return record.hasSymptom ? "symptom-icon" : nil
            case .diet:
                return record.hasDiet ? "meal-icon" : nil
            }
        }
        
        // 필터가 없으면 우선순위: 기분 > 치료기록 > 특이증상 > 식이상태
        if let mood = record.mood {
            return mood.iconName
        } else if record.hasTreatment {
            return "checkmark.circle.fill"
        } else if record.hasSymptom {
            return "symptom-icon"
        } else if record.hasDiet {
            return "meal-icon"
        }
        
        return nil
    }
}
