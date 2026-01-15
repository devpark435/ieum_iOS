import Foundation
import Combine

final class SignUpStep7ViewModel: ObservableObject {
    // Inputs
    let interestText = CurrentValueSubject<String, Never>("")
    let didTapSkip = PassthroughSubject<Void, Never>()
    let didTapNext = PassthroughSubject<Void, Never>()
    
    // Outputs
    @Published private(set) var isNextButtonEnabled = false
    @Published var isLoading = false
    @Published var error: Error?
    
    // Navigation Events
    let navigateToComplete = PassthroughSubject<Void, Never>()
    
    private let signUpRepository: SignUpRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(signUpRepository: SignUpRepository = SignUpRepositoryImpl()) {
        self.signUpRepository = signUpRepository
        bindInputs()
    }
    
    private func bindInputs() {
        interestText
            .map { !$0.isEmpty }
            .assign(to: &$isNextButtonEnabled)
        
        didTapSkip
            .sink { [weak self] in
                // 관심 주제 없음 처리 (필요 시)
                self?.register()
            }
            .store(in: &cancellables)
        
        didTapNext
            .sink { [weak self] in
                // 관심 주제 저장 (필요 시 API에 추가)
                self?.register()
            }
            .store(in: &cancellables)
    }
    
    private func register() {
        guard let request = SignUpDataManager.shared.toRequest() else {
            print("회원가입 데이터가 불충분합니다.")
            return
        }
        
        isLoading = true
        
        signUpRepository.register(request: request)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                    print("SignUp Error: \(error)")
                }
            } receiveValue: { [weak self] response in
                // 회원가입 성공 -> 완료 화면으로 이동
                self?.navigateToComplete.send()
            }
            .store(in: &cancellables)
    }
}
