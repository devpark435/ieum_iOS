import Foundation
import Combine

final class SignUpStep7ViewModel: ObservableObject {
    // Inputs
    let interestText = CurrentValueSubject<String, Never>("")
    let didTapSkip = PassthroughSubject<Void, Never>()
    let didTapNext = PassthroughSubject<Void, Never>()
    
    // Outputs
    @Published private(set) var isNextButtonEnabled = false
    
    // Navigation Events
    let navigateToComplete = PassthroughSubject<Void, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bindInputs()
    }
    
    private func bindInputs() {
        interestText
            .map { !$0.isEmpty }
            .assign(to: &$isNextButtonEnabled)
        
        didTapSkip
            .sink { [weak self] in
                // TODO: 관심 주제 건너뛰기 처리
                self?.navigateToComplete.send()
            }
            .store(in: &cancellables)
        
        didTapNext
            .sink { [weak self] in
                // TODO: 관심 주제 저장 및 회원가입 완료 API 호출
                self?.navigateToComplete.send()
            }
            .store(in: &cancellables)
    }
}

