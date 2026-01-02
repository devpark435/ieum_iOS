import Foundation
import Combine

final class TreatmentRecordViewModel: ObservableObject {
    // Inputs
    let didTapClose = PassthroughSubject<Void, Never>()
    let didTapPost = PassthroughSubject<Void, Never>()
    
    // Outputs
    @Published private(set) var isPostButtonEnabled = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bindInputs()
    }
    
    private func bindInputs() {
        // TODO: 입력 상태에 따라 게시하기 버튼 활성화 로직 추가
    }
}

