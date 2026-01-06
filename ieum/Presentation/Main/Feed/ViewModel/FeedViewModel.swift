import Foundation
import Combine

final class FeedViewModel: ObservableObject {
    // Inputs
    let viewDidLoad = PassthroughSubject<Void, Never>()
    let didSelectFilter = PassthroughSubject<String, Never>()
    let didTapWritePost = PassthroughSubject<Void, Never>()
    let didTapComment = PassthroughSubject<Int, Never>()
    
    // Outputs
    @Published private(set) var isLoading = false
    @Published private(set) var selectedFilter: String = "전체"
    @Published private(set) var posts: [Post] = []
    @Published private(set) var pagination: Pagination?
    
    // Navigation Events
    let showWritePost = PassthroughSubject<Void, Never>()
    let navigateToComments = PassthroughSubject<Int, Never>()
    
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
                self?.showWritePost.send()
            }
            .store(in: &cancellables)
            
        didTapComment
            .sink { [weak self] postId in
                self?.navigateToComments.send(postId)
            }
            .store(in: &cancellables)
    }
    
    private func loadMockData() {
        // Mock Data for Testing
        let longText = """
        오늘 2차 항암맞는날 토할것같지만참고이이겨내자 오늘 2차 항암맞는날 토할것같지만참고이이겨내자오늘 2차 항암맞는날 오늘 2차 항암맞는날 토할것같지만참고이이겨내자 오늘 2차 항암맞는날 토할것같지만참고이이겨내자 오늘 2차 항암맞는날 토할것같지만참고이이겨내자
        """
        
        posts = [
            // 1. 치료 기록 (Wellness) - 모든 정보 포함, 이미지 있음
            Post(
                id: 1,
                userId: 1,
                userNickname: "희망찬환자",
                type: .wellness,
                title: "2차 항암 치료",
                content: "", // Wellness type uses specific fields
                diagnosis: [.rectalCancer],
                mood: 2, // 좋아요
                unusualSymptoms: longText, // 긴 텍스트 테스트
                medicationTaken: true,
                diet: Diet(amountEaten: .wellEaten, mealContent: "죽, 동치미, 계란찜"),
                memo: "다음 진료일은 2주 뒤입니다. 컨디션 관리 잘하자!",
                images: [
                    ImageInfo(url: "dummy_url", filename: "dummy.jpg", uploadedAt: Int64(Date().timeIntervalSince1970))
                ],
                likesCount: 15,
                commentsCount: 3,
                createdAt: Int64(Date().timeIntervalSince1970),
                updatedAt: Int64(Date().timeIntervalSince1970),
                isLiked: true
            ),
            
            // 2. 일상 기록 (Daily) - 텍스트만, 긴 글
            Post(
                id: 2,
                userId: 2,
                userNickname: "일상기록러",
                type: .daily,
                title: "산책 다녀왔어요",
                content: longText, // 긴 텍스트 테스트
                diagnosis: [],
                mood: 0,
                unusualSymptoms: nil,
                medicationTaken: false,
                diet: nil,
                memo: nil,
                images: [
                     ImageInfo(url: "dummy_url_2", filename: "dummy2.jpg", uploadedAt: Int64(Date().timeIntervalSince1970))
                ],
                likesCount: 8,
                commentsCount: 1,
                createdAt: Int64(Date().timeIntervalSince1970) - 3600,
                updatedAt: Int64(Date().timeIntervalSince1970) - 3600,
                isLiked: false
            )
        ]
        
        pagination = Pagination(
            currentPage: 1,
            perPage: 10,
            totalItems: 2,
            totalPages: 1
        )
    }
}


