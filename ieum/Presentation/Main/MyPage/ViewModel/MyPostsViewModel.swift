import Foundation
import Combine

final class MyPostsViewModel: ObservableObject {
    
    // MARK: - Inputs
    let viewDidLoad = PassthroughSubject<Void, Never>()
    let didSelectFilter = PassthroughSubject<String, Never>()
    let loadMore = PassthroughSubject<Void, Never>()
    
    // MARK: - Outputs
    @Published private(set) var posts: [Post] = []
    @Published private(set) var isLoading = false
    @Published private(set) var currentFilter: String = "전체"
    @Published private(set) var error: Error?
    
    private let feedRepository: FeedRepository
    private var cancellables = Set<AnyCancellable>()
    
    private var currentPage = 1
    private let pageSize = 10
    private var isLastPage = false
    
    // MARK: - Initializer
    
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
                self?.currentFilter = filter
                self?.refresh()
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
        fetchMyPosts()
    }
    
    private func loadNextPage() {
        guard !isLoading, !isLastPage else { return }
        currentPage += 1
        fetchMyPosts()
    }
    
    private func fetchMyPosts() {
        isLoading = true
        
        let type = convertFilterToPostType(currentFilter)
        
        feedRepository.fetchPosts(type: type, page: currentPage, pageSize: pageSize, diagnosis: nil, mood: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                
                // TODO: 서버에서 현재 사용자의 게시글만 필터링해서 반환하는 API가 있다면 사용
                // 현재는 모든 공유된 포스트를 받아오므로, 클라이언트에서 필터링 필요
                // 또는 별도의 내 게시글 조회 API 추가 필요
                
                if self.currentPage == 1 {
                    self.posts = response.posts
                } else {
                    self.posts.append(contentsOf: response.posts)
                }
                
                self.isLastPage = self.currentPage >= response.pagination.totalPages
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
