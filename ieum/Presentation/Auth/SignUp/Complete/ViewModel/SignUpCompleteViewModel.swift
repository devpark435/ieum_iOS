import Foundation
import Combine

final class SignUpCompleteViewModel: ObservableObject {
    // Inputs
    let didTapStart = PassthroughSubject<Void, Never>()
    let didTapDetailInfo = PassthroughSubject<Void, Never>()
    
    // Navigation Events
    let navigateToMain = PassthroughSubject<Void, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bindInputs()
    }
    
    private func bindInputs() {
        didTapStart
            .sink { [weak self] in
                // TODO: 메인 화면 진입 전 필요한 초기화 작업 수행
                self?.navigateToMain.send()
            }
            .store(in: &cancellables)
        
        didTapDetailInfo
            .sink { [weak self] in
                // TODO: 상세 정보 입력 화면으로 이동 (추후 구현)
                print("상세 정보 입력하기 탭")
                self?.navigateToMain.send() // 임시로 메인 이동
            }
            .store(in: &cancellables)
    }
}

