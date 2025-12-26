import Foundation
import Combine

final class SignUpStep4ViewModel: ObservableObject {
    // Inputs
    let didTapDiagnosis = PassthroughSubject<String, Never>()
    let didTapNext = PassthroughSubject<Void, Never>()
    
    // Outputs
    @Published private(set) var selectedCount = 0
    @Published private(set) var countText = "0 개 선택완료"
    @Published private(set) var isNextButtonEnabled = false
    @Published private(set) var selectedDiagnosis: [String: String] = [:] // [진단명: 병기(없으면 "")]
    
    // Navigation Events
    let navigateToNext = PassthroughSubject<Void, Never>()
    let showStageSelection = PassthroughSubject<String, Never>()
    
    // Data
    let diagnosisList = ["직장암", "대장암", "간이식", "기타"]
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bindInputs()
    }
    
    private func bindInputs() {
        didTapDiagnosis
            .sink { [weak self] title in
                self?.handleDiagnosisSelection(title)
            }
            .store(in: &cancellables)
        
        didTapNext
            .sink { [weak self] in
                self?.navigateToNext.send()
            }
            .store(in: &cancellables)
    }
    
    private func handleDiagnosisSelection(_ title: String) {
        if selectedDiagnosis.keys.contains(title) {
            // 이미 선택된 상태 -> 해제
            selectedDiagnosis.removeValue(forKey: title)
        } else {
            // 선택되지 않은 상태 -> 선택
            if title == "기타" || title == "간이식" {
                // 병기 선택 불필요한 경우 바로 선택 처리
                selectedDiagnosis[title] = ""
            } else {
                // 병기 선택 바텀시트 노출
                showStageSelection.send(title)
                return
            }
        }
        updateState()
    }
    
    func selectDiagnosis(_ title: String, stage: String) {
        selectedDiagnosis[title] = stage
        updateState()
    }
    
    private func updateState() {
        let count = selectedDiagnosis.count
        selectedCount = count
        
        let countTextValue = "\(count) 개 선택완료"
        countText = countTextValue
        
        isNextButtonEnabled = count > 0
    }
    
    func isDiagnosisSelected(_ title: String) -> Bool {
        return selectedDiagnosis.keys.contains(title)
    }
    
    func getStage(for title: String) -> String? {
        return selectedDiagnosis[title]
    }
}

