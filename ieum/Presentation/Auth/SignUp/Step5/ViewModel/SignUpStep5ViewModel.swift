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
                self?.navigateToNext.send()
            }
            .store(in: &cancellables)
        
        didTapNext
            .sink { [weak self] in
                self?.navigateToNext.send()
            }
            .store(in: &cancellables)
    }
}

