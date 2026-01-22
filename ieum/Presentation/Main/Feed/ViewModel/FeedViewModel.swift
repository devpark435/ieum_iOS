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
    let navigateToComments = PassthroughSubject<(Int, PostType), Never>()
    
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
                guard let self = self,
                      let post = self.posts.first(where: { $0.id == postId }) else { return }
                self.navigateToComments.send((postId, post.type))
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
        
        // 현재 좋아요 상태에 따라 적절한 API 호출
        let publisher: AnyPublisher<LikeResponse, Error>
        if post.isLiked {
            publisher = feedRepository.unlikePost(type: post.type, id: post.id)
        } else {
            publisher = feedRepository.likePost(type: post.type, id: post.id)
        }
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] response in
                guard let self = self,
                      let updateIndex = self.posts.firstIndex(where: { $0.id == postId }) else { return }
                
                // Post.updatingLike를 사용하여 좋아요 상태만 업데이트
                let updatedPost = self.posts[updateIndex].updatingLike(
                    isLiked: response.isLiked,
                    likesCount: response.likesCount
                )
                self.posts[updateIndex] = updatedPost
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
