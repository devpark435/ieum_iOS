import Foundation
import Combine

final class FeedViewModel: ObservableObject {
    // Inputs
    let viewDidLoad = PassthroughSubject<Void, Never>()
    
    // Outputs
    @Published private(set) var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bindInputs()
    }
    
    private func bindInputs() {
        viewDidLoad
            .sink { [weak self] in
                // TODO: 피드 데이터 로드
            }
            .store(in: &cancellables)
    }
}

