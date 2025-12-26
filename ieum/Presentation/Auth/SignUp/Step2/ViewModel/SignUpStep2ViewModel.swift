import Foundation
import Combine

final class SignUpStep2ViewModel: ObservableObject {
    // Inputs
    let didSelectMale = PassthroughSubject<Void, Never>()
    let didSelectFemale = PassthroughSubject<Void, Never>()
    
    // Outputs
    @Published private(set) var isMaleSelected = false
    @Published private(set) var isFemaleSelected = false
    
    // Navigation Events
    let navigateToNext = PassthroughSubject<Void, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bindInputs()
    }
    
    private func bindInputs() {
        didSelectMale
            .sink { [weak self] in
                self?.updateSelection(isMale: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self?.navigateToNext.send()
                }
            }
            .store(in: &cancellables)
        
        didSelectFemale
            .sink { [weak self] in
                self?.updateSelection(isMale: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self?.navigateToNext.send()
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateSelection(isMale: Bool) {
        isMaleSelected = isMale
        isFemaleSelected = !isMale
    }
}

