import Foundation
import Combine

final class MyPostsViewModel: ObservableObject {
    
    // MARK: - Inputs
    let viewDidLoad = PassthroughSubject<Void, Never>()
    let didSelectFilter = PassthroughSubject<String, Never>()
    
    // MARK: - Outputs
    @Published private(set) var posts: [Post] = []
    @Published private(set) var isLoading = false
    @Published private(set) var currentFilter: String = "전체"
    
    private var allPosts: [Post] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    init() {
        bindInputs()
    }
    
    private func bindInputs() {
        viewDidLoad
            .sink { [weak self] in
                self?.fetchMyPosts()
            }
            .store(in: &cancellables)
        
        didSelectFilter
            .sink { [weak self] filter in
                self?.currentFilter = filter
                self?.filterPosts()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Logic
    
    private func fetchMyPosts() {
        isLoading = true
        
        // Mock Data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Reusing FeedViewModel's mock data structure
            let longText = """
            오늘 2차 항암맞는날 토할것같지만참고이이겨내자 오늘 2차 항암맞는날 토할것같지만참고이이겨내자오늘 2차 항암맞는날 오늘 2차 항암맞는날 토할것같지만참고이이겨내자 오늘 2차 항암맞는날 토할것같지만참고이이겨내자 오늘 2차 항암맞는날 토할것같지만참고이이겨내자
            """
            
            self.allPosts = [
                Post(
                    id: 101,
                    userId: 1,
                    userNickname: "user_me",
                    type: .wellness,
                    title: "2차 항암 치료",
                    content: "",
                    diagnosis: [.rectalCancer],
                    mood: 2,
                    unusualSymptoms: longText,
                    medicationTaken: true,
                    diet: Diet(amountEaten: .wellEaten, mealContent: "죽, 동치미, 계란찜"),
                    memo: "다음 진료일은 2주 뒤입니다.",
                    images: [
                        ImageInfo(url: "dummy_url", filename: "dummy.jpg", uploadedAt: Int64(Date().timeIntervalSince1970))
                    ],
                    likesCount: 15,
                    commentsCount: 3,
                    createdAt: Int64(Date().timeIntervalSince1970),
                    updatedAt: Int64(Date().timeIntervalSince1970),
                    isLiked: true
                ),
                Post(
                    id: 102,
                    userId: 1,
                    userNickname: "user_me",
                    type: .daily,
                    title: "산책",
                    content: "오늘 날씨가 너무 좋아서 산책을 다녀왔다.",
                    diagnosis: [],
                    mood: 0,
                    unusualSymptoms: nil,
                    medicationTaken: false,
                    diet: nil,
                    memo: nil,
                    images: [],
                    likesCount: 5,
                    commentsCount: 0,
                    createdAt: Int64(Date().timeIntervalSince1970) - 86400,
                    updatedAt: Int64(Date().timeIntervalSince1970) - 86400,
                    isLiked: false
                )
            ]
            
            self.filterPosts()
            self.isLoading = false
        }
    }
    
    private func filterPosts() {
        if currentFilter == "전체" {
            posts = allPosts
        } else if currentFilter == "일상 기록" {
            posts = allPosts.filter { $0.type == .daily }
        } else if currentFilter == "치료 기록" {
            posts = allPosts.filter { $0.type == .treatment || $0.type == .wellness }
        }
    }
}
