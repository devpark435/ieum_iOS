import Foundation
import Combine
import OSLog

final class RadiationHistoryViewModel: ObservableObject {
    
    // MARK: - Inputs
    
    let didTapAddHistory = PassthroughSubject<Void, Never>()
    let didTapDeleteHistory = PassthroughSubject<Int, Never>()
    let didUpdateStartDate = PassthroughSubject<(index: Int, date: Date), Never>()
    let didUpdateEndDate = PassthroughSubject<(index: Int, date: Date), Never>()
    let didToggleInProgress = PassthroughSubject<(index: Int, isInProgress: Bool), Never>()
    let didChangePrivacy = PassthroughSubject<Bool, Never>()
    let didTapComplete = PassthroughSubject<Void, Never>()
    
    // MARK: - Outputs
    
    @Published private(set) var historyItems: [RadiationHistoryItem] = []
    @Published private(set) var isPrivate: Bool = false
    @Published private(set) var isCompleteButtonEnabled = false
    
    // MARK: - Navigation Events
    
    let navigateToComplete = PassthroughSubject<([RadiationTherapyRequest], Bool), Never>()
    
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
    
    func setupInitialData(_ radiations: [RadiationTherapy]?) {
        guard let radiations = radiations, !radiations.isEmpty else {
            addHistoryItem()
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        historyItems = radiations.map { radiation in
            let startDate = formatter.date(from: radiation.startDate)
            let endDate = radiation.endDate.flatMap { formatter.date(from: $0) }
            let isInProgress = endDate == nil
            
            return RadiationHistoryItem(
                startDate: startDate,
                endDate: endDate,
                isInProgress: isInProgress
            )
        }
        
        updateCompleteButtonState()
    }
    
    private func addHistoryItem() {
        historyItems.append(RadiationHistoryItem(startDate: nil, endDate: nil, isInProgress: false))
        updateCompleteButtonState()
    }
    
    private func deleteHistoryItem(at index: Int) {
        guard index < historyItems.count else { return }
        historyItems.remove(at: index)
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
        
        let radiationRequests = historyItems.compactMap { item -> RadiationTherapyRequest? in
            guard let startDate = item.startDate else { return nil }
            
            let endDateString: String?
            if item.isInProgress {
                endDateString = nil
            } else if let endDate = item.endDate {
                endDateString = formatter.string(from: endDate)
            } else {
                return nil
            }
            
            return RadiationTherapyRequest(
                startDate: formatter.string(from: startDate),
                endDate: endDateString
            )
        }
        
        navigateToComplete.send((radiationRequests, isPrivate))
    }
}
