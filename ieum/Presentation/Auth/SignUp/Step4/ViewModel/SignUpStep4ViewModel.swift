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
                self?.saveSelection()
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
    
    private func saveSelection() {
        // [진단명: 병기] -> [DiagnosisRequest] 변환
        let diagnoses = selectedDiagnosis.map { (key, value) -> DiagnosisRequest in
            // "기타", "간이식"의 경우 병기 null
            let stage: Int? = (value.isEmpty) ? nil : Int(value.replacingOccurrences(of: "기", with: ""))
            
            // API 명세에 맞게 key 변환 필요 (직장암 -> rectal_cancer 등)
            // 현재는 UI 상의 텍스트를 그대로 사용하므로 매핑 로직 필요
            // 여기서는 임시로 UI 텍스트를 그대로 사용하거나 매퍼를 추가해야 함
            // TODO: 진단명 매핑 로직 추가
            
            var diagnosisKey = "others"
            if key == "직장암" { diagnosisKey = "rectal_cancer" }
            else if key == "대장암" { diagnosisKey = "colon_cancer" }
            else if key == "간이식" { diagnosisKey = "liver_transplant" }
            
            return DiagnosisRequest(diagnosis: diagnosisKey, cancerStage: stage)
        }
        SignUpDataManager.shared.diagnoses = diagnoses
    }
    
    func isDiagnosisSelected(_ title: String) -> Bool {
        return selectedDiagnosis.keys.contains(title)
    }
    
    func getStage(for title: String) -> String? {
        return selectedDiagnosis[title]
    }
}
