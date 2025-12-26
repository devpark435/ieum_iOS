import Foundation
import Combine

final class SignUpStep1ViewModel: ObservableObject {
    // Inputs
    let didSelectPatient = PassthroughSubject<Void, Never>()
    let didSelectCaregiver = PassthroughSubject<Void, Never>()
    
    // Outputs
    @Published private(set) var isPatientSelected = false
    @Published private(set) var isCaregiverSelected = false
    
    // Navigation Events
    let navigateToNext = PassthroughSubject<Void, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bindInputs()
    }
    
    private func bindInputs() {
        didSelectPatient
            .sink { [weak self] in
                self?.updateSelection(isPatient: true)
                // 선택 시각적 피드백을 위해 약간의 딜레이 후 이동
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self?.navigateToNext.send()
                }
            }
            .store(in: &cancellables)
        
        didSelectCaregiver
            .sink { [weak self] in
                self?.updateSelection(isPatient: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self?.navigateToNext.send()
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateSelection(isPatient: Bool) {
        isPatientSelected = isPatient
        isCaregiverSelected = !isPatient
    }
}

