import Foundation
import Combine

final class SignUpStep3ViewModel: ObservableObject {
    // Inputs
    let nicknameText = CurrentValueSubject<String, Never>("")
    let didTapNext = PassthroughSubject<Void, Never>()
    
    // Outputs
    @Published private(set) var isNextButtonEnabled = false
    
    // Navigation Events
    let navigateToNext = PassthroughSubject<Void, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bindInputs()
    }
    
    private func bindInputs() {
        nicknameText
            .map { !$0.isEmpty }
            .assign(to: &$isNextButtonEnabled)
        
        didTapNext
            .sink { [weak self] in
                // TODO: 닉네임 중복 확인 API 호출 필요
                print("닉네임 입력 완료: \(self?.nicknameText.value ?? "")")
                self?.navigateToNext.send()
            }
            .store(in: &cancellables)
    }
}

