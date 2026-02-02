import Foundation
import Combine
import OSLog

final class ChemotherapyHistoryViewModel: ObservableObject {
    
    // MARK: - Inputs
    
    let didTapAddHistory = PassthroughSubject<Void, Never>()
    let didTapDeleteHistory = PassthroughSubject<Int, Never>()
    let didUpdateCycle = PassthroughSubject<(index: Int, cycle: Int), Never>()
    let didUpdateStartDate = PassthroughSubject<(index: Int, date: Date), Never>()
    let didUpdateEndDate = PassthroughSubject<(index: Int, date: Date), Never>()
    let didToggleInProgress = PassthroughSubject<(index: Int, isInProgress: Bool), Never>()
    let didChangePrivacy = PassthroughSubject<Bool, Never>()
    let didTapComplete = PassthroughSubject<Void, Never>()
    
    // MARK: - Outputs
    
    @Published private(set) var historyItems: [ChemotherapyHistoryItem] = []
    @Published private(set) var isPrivate: Bool = false
    @Published private(set) var isCompleteButtonEnabled = false
    
    // MARK: - Navigation Events
    
    let navigateToComplete = PassthroughSubject<([ChemotherapyRequest], Bool), Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bindInputs()
    }
    
    private func bindInputs() {
        didTapAddHistory
            .sink { [weak self] in
                self?.addHistoryItem()
            }
            .store(in: &cancellables)
        
        didTapDeleteHistory
            .sink { [weak self] index in
                self?.deleteHistoryItem(at: index)
            }
            .store(in: &cancellables)
        
        didUpdateCycle
            .sink { [weak self] index, cycle in
                self?.updateCycle(at: index, cycle: cycle)
            }
            .store(in: &cancellables)
        
        didUpdateStartDate
            .sink { [weak self] index, date in
                self?.updateStartDate(at: index, date: date)
            }
            .store(in: &cancellables)
        
        didUpdateEndDate
            .sink { [weak self] index, date in
                self?.updateEndDate(at: index, date: date)
            }
            .store(in: &cancellables)
        
        didToggleInProgress
            .sink { [weak self] index, isInProgress in
                self?.toggleInProgress(at: index, isInProgress: isInProgress)
            }
            .store(in: &cancellables)
        
        didChangePrivacy
            .sink { [weak self] isPrivate in
                self?.isPrivate = isPrivate
            }
            .store(in: &cancellables)
        
        didTapComplete
            .sink { [weak self] in
                self?.complete()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Methods
    
    func setupInitialData(_ chemotherapies: [Chemotherapy]?) {
        guard let chemotherapies = chemotherapies, !chemotherapies.isEmpty else {
            addHistoryItem()
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        historyItems = chemotherapies.enumerated().map { index, chemo in
            let startDate = formatter.date(from: chemo.startDate)
            let endDate = chemo.endDate.flatMap { formatter.date(from: $0) }
            let isInProgress = endDate == nil
            
            return ChemotherapyHistoryItem(
                cycle: chemo.cycle,
                startDate: startDate,
                endDate: endDate,
                isInProgress: isInProgress
            )
        }
        
        updateCompleteButtonState()
    }
    
    private func addHistoryItem() {
        let nextCycle = historyItems.count + 1
        historyItems.append(ChemotherapyHistoryItem(cycle: nextCycle, startDate: nil, endDate: nil, isInProgress: false))
        updateCompleteButtonState()
    }
    
    private func deleteHistoryItem(at index: Int) {
        guard index < historyItems.count else { return }
        historyItems.remove(at: index)
        updateCycleNumbers()
        updateCompleteButtonState()
    }
    
    private func updateCycleNumbers() {
        for index in historyItems.indices {
            historyItems[index].cycle = index + 1
        }
    }
    
    private func updateCycle(at index: Int, cycle: Int) {
        guard index < historyItems.count else { return }
        historyItems[index].cycle = cycle
        updateCompleteButtonState()
    }
    
    private func updateStartDate(at index: Int, date: Date) {
        guard index < historyItems.count else { return }
        historyItems[index].startDate = date
        updateCompleteButtonState()
    }
    
    private func updateEndDate(at index: Int, date: Date) {
        guard index < historyItems.count else { return }
        historyItems[index].endDate = date
        updateCompleteButtonState()
    }
    
    private func toggleInProgress(at index: Int, isInProgress: Bool) {
        guard index < historyItems.count else { return }
        historyItems[index].isInProgress = isInProgress
        if isInProgress {
            historyItems[index].endDate = nil
        }
        updateCompleteButtonState()
    }
    
    private func updateCompleteButtonState() {
        let hasValidItems = historyItems.contains { item in
            item.startDate != nil && (item.isInProgress || item.endDate != nil)
        }
        isCompleteButtonEnabled = hasValidItems
    }
    
    private func complete() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let chemoRequests = historyItems.compactMap { item -> ChemotherapyRequest? in
            guard let startDate = item.startDate else { return nil }
            
            let endDateString: String?
            if item.isInProgress {
                endDateString = nil
            } else if let endDate = item.endDate {
                endDateString = formatter.string(from: endDate)
            } else {
                return nil
            }
            
            return ChemotherapyRequest(
                startDate: formatter.string(from: startDate),
                endDate: endDateString,
                cycle: item.cycle
            )
        }
        
        navigateToComplete.send((chemoRequests, isPrivate))
    }
}
