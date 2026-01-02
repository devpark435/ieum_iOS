import Foundation
import Combine

final class FeedViewModel: ObservableObject {
    // Inputs
    let viewDidLoad = PassthroughSubject<Void, Never>()
    let didSelectFilter = PassthroughSubject<String, Never>()
    let didTapWritePost = PassthroughSubject<Void, Never>()
    
    // Outputs
    @Published private(set) var isLoading = false
    @Published private(set) var selectedFilter: String = "전체"
    @Published private(set) var posts: [Post] = []
    @Published private(set) var pagination: Pagination?
    
    // Navigation Events
    let showWritePost = PassthroughSubject<Void, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bindInputs()
        loadMockData()
    }
    
    private func bindInputs() {
        viewDidLoad
            .sink { [weak self] in
                // TODO: 피드 데이터 로드
            }
            .store(in: &cancellables)
        
        didSelectFilter
            .sink { [weak self] filter in
                self?.selectedFilter = filter
                // TODO: 필터에 따른 피드 데이터 필터링
            }
            .store(in: &cancellables)
        
        didTapWritePost
            .sink { [weak self] in
                print("FeedViewModel: didTapWritePost 수신됨")
                self?.showWritePost.send()
            }
            .store(in: &cancellables)
    }
    
    private func loadMockData() {
        // TODO: API 연동 후 실제 데이터로 교체
        posts = [
            Post(
                id: 1,
                userId: 1,
                userNickname: "user_1",
                type: .wellness,
                title: "오늘 2차 항암",
                content: "오늘 2차 항암맞는날 토할것같지만참고이이겨내자 오늘 2차 항암맞는날 토할것같지만참고이이겨내자오늘 2차 항암맞는날 오늘 2차 항암맞는날 토할것같지만참고이이겨내자 오늘 2...",
                diagnosis: [.rectalCancer],
                mood: 3,
                unusualSymptoms: nil,
                medicationTaken: true,
                diet: Diet(amountEaten: .normal, mealContent: "밥"),
                memo: nil,
                images: [],
                likesCount: 10,
                commentsCount: 5,
                createdAt: Int64(Date().timeIntervalSince1970),
                updatedAt: Int64(Date().timeIntervalSince1970),
                isLiked: false
            )
        ]
        
        pagination = Pagination(
            currentPage: 1,
            perPage: 10,
            totalItems: 1,
            totalPages: 1
        )
    }
}


