import Foundation
import Combine

final class FeedViewModel: ObservableObject {
    // Inputs
    let viewDidLoad = PassthroughSubject<Void, Never>()
    let didSelectFilter = PassthroughSubject<String, Never>()
    let didTapWritePost = PassthroughSubject<Void, Never>()
    let didTapLike = PassthroughSubject<Int, Never>()
    let didTapComment = PassthroughSubject<Int, Never>()
    let loadMore = PassthroughSubject<Void, Never>()
    
    // Outputs
    @Published private(set) var isLoading = false
    @Published private(set) var selectedFilter: String = "전체"
    @Published private(set) var posts: [Post] = []
    @Published private(set) var error: Error?
    
    // Navigation Events
    let showWritePost = PassthroughSubject<Void, Never>()
    let navigateToComments = PassthroughSubject<Int, Never>()
    
    private let feedRepository: FeedRepository
    private var cancellables = Set<AnyCancellable>()
    
    private var currentPage = 1
    private let pageSize = 10
    private var isLastPage = false
    
    init(feedRepository: FeedRepository = FeedRepositoryImpl()) {
        self.feedRepository = feedRepository
        bindInputs()
    }
    
    private func bindInputs() {
        viewDidLoad
            .sink { [weak self] in
                self?.refresh()
            }
            .store(in: &cancellables)
        
        didSelectFilter
            .sink { [weak self] filter in
                self?.selectedFilter = filter
                self?.refresh()
            }
            .store(in: &cancellables)
        
        didTapWritePost
            .sink { [weak self] in
                self?.showWritePost.send()
            }
            .store(in: &cancellables)
        
        didTapLike
            .sink { [weak self] postId in
                self?.toggleLike(postId: postId)
            }
            .store(in: &cancellables)
            
        didTapComment
            .sink { [weak self] postId in
                self?.navigateToComments.send(postId)
            }
            .store(in: &cancellables)
            
        loadMore
            .sink { [weak self] in
                self?.loadNextPage()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - API Calls
    
    private func refresh() {
        currentPage = 1
        isLastPage = false
        posts = []
        fetchPosts()
    }
    
    private func loadNextPage() {
        guard !isLoading, !isLastPage else { return }
        currentPage += 1
        fetchPosts()
    }
    
    private func fetchPosts() {
        isLoading = true
        
        let type = convertFilterToPostType(selectedFilter)
        
        feedRepository.fetchPosts(type: type, page: currentPage, pageSize: pageSize, diagnosis: nil, mood: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                
                if self.currentPage == 1 {
                    self.posts = response.posts
                } else {
                    self.posts.append(contentsOf: response.posts)
                }
                
                self.isLastPage = self.currentPage >= response.pagination.totalPages
            }
            .store(in: &cancellables)
    }
    
    private func toggleLike(postId: Int) {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        let post = posts[index]
        
        // 이미 좋아요가 되어 있으면 API 호출하지 않음 (취소 API가 없는 것으로 보임)
        guard !post.isLiked else { return }
        
        feedRepository.likePost(type: post.type, id: post.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    // 실패 시 에러 처리
                }
            } receiveValue: { [weak self] response in
                // 좋아요 성공 시 포스트 업데이트
                if let self = self, self.posts.indices.contains(index) {
                    var updatedPost = self.posts[index]
                    // Post는 struct이므로 직접 수정 불가, 전체 리스트에서 찾아서 교체
                    if let updateIndex = self.posts.firstIndex(where: { $0.id == postId }) {
                        // Post 구조체는 immutable이므로 새로 생성해야 함
                        // 하지만 Post의 모든 필드를 업데이트하기 어려우므로, 전체 리스트를 다시 fetch하는 것이 안전
                        // 또는 좋아요 상태만 업데이트하는 별도 로직 필요
                        // 일단 간단하게 리스트를 다시 fetch
                        self.fetchPosts()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Helpers
    
    private func convertFilterToPostType(_ filter: String) -> PostType {
        switch filter {
        case "전체": return .all
        case "일상 기록": return .daily
        case "치료 기록": return .wellness
        default: return .all
        }
    }
}
