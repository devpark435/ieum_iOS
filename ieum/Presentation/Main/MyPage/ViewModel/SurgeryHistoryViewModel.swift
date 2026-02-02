import Foundation
import Combine
import OSLog

final class SurgeryHistoryViewModel: ObservableObject {
    
    // MARK: - Inputs
    
    let didTapAddHistory = PassthroughSubject<Void, Never>()
    let didTapDeleteHistory = PassthroughSubject<Int, Never>()
    let didUpdateDate = PassthroughSubject<(index: Int, date: Date), Never>()
    let didUpdateDescription = PassthroughSubject<(index: Int, description: String), Never>()
    let didChangePrivacy = PassthroughSubject<Bool, Never>()
    let didTapComplete = PassthroughSubject<Void, Never>()
    
    // MARK: - Outputs
    
    @Published private(set) var historyItems: [SurgeryHistoryItem] = []
    @Published private(set) var isPrivate: Bool = false
    @Published private(set) var isCompleteButtonEnabled = false
    
    // MARK: - Navigation Events
    
    let navigateToComplete = PassthroughSubject<([SurgeryRequest], Bool), Never>()
    
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
        
        didUpdateDate
            .sink { [weak self] index, date in
                self?.updateDate(at: index, date: date)
            }
            .store(in: &cancellables)
        
        didUpdateDescription
            .sink { [weak self] index, description in
                self?.updateDescription(at: index, description: description)
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
    
    func setupInitialData(_ surgeries: [Surgery]?) {
        guard let surgeries = surgeries, !surgeries.isEmpty else {
            addHistoryItem()
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        historyItems = surgeries.map { surgery in
            let date = formatter.date(from: surgery.date)
            return SurgeryHistoryItem(date: date, description: surgery.description)
        }
        
        updateCompleteButtonState()
    }
    
    private func addHistoryItem() {
        historyItems.append(SurgeryHistoryItem(date: nil, description: ""))
        updateCompleteButtonState()
    }
    
    private func deleteHistoryItem(at index: Int) {
        guard index < historyItems.count else { return }
        historyItems.remove(at: index)
        updateCompleteButtonState()
    }
    
    private func updateDate(at index: Int, date: Date) {
        guard index < historyItems.count else { return }
        historyItems[index].date = date
        updateCompleteButtonState()
    }
    
    private func updateDescription(at index: Int, description: String) {
        guard index < historyItems.count else { return }
        historyItems[index].description = description
        updateCompleteButtonState()
    }
    
    private func updateCompleteButtonState() {
        let hasValidItems = historyItems.contains { item in
            item.date != nil && !item.description.isEmpty
        }
        isCompleteButtonEnabled = hasValidItems
    }
    
    private func complete() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let surgeryRequests = historyItems.compactMap { item -> SurgeryRequest? in
            guard let date = item.date, !item.description.isEmpty else { return nil }
            return SurgeryRequest(date: formatter.string(from: date), description: item.description)
        }
        
        navigateToComplete.send((surgeryRequests, isPrivate))
    }
}
