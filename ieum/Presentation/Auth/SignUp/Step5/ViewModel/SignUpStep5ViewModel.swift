import Foundation
import Combine

final class SignUpStep5ViewModel: ObservableObject {
    // Inputs
    let didSelectAgeGroup = PassthroughSubject<String, Never>()
    let didTapSkip = PassthroughSubject<Void, Never>()
    let didTapNext = PassthroughSubject<Void, Never>()
    
    // Outputs
    @Published private(set) var selectedAgeGroup: String?
    
    // Navigation Events
    let navigateToNext = PassthroughSubject<Void, Never>()
    
    // Data
    let ageGroups = ["30대 이하", "40대", "50대", "60대", "70대 이상"]
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bindInputs()
    }
    
    private func bindInputs() {
        didSelectAgeGroup
            .sink { [weak self] ageGroup in
                self?.selectedAgeGroup = ageGroup
            }
            .store(in: &cancellables)
        
        didTapSkip
            .sink { [weak self] in
                SignUpDataManager.shared.ageGroup = nil
                self?.navigateToNext.send()
            }
            .store(in: &cancellables)
        
        didTapNext
            .sink { [weak self] in
                if let ageGroupTitle = self?.selectedAgeGroup {
                    let ageGroup = self?.convertAgeGroup(title: ageGroupTitle)
                    SignUpDataManager.shared.ageGroup = ageGroup
                } else {
                    SignUpDataManager.shared.ageGroup = nil
                }
                self?.navigateToNext.send()
            }
            .store(in: &cancellables)
    }
    
    private func convertAgeGroup(title: String) -> String? {
        // UI 텍스트 -> API 열거형 rawValue 변환
        // "30대 이하" -> "under30s", "40대" -> "40s" 등
        // AgeGroup.allCases에서 매칭되는 title 찾아서 rawValue 반환
        return AgeGroup.allCases.first { $0.title == title }?.rawValue
    }
}
