import Foundation
import Combine
import OSLog

final class MyPostsViewModel: ObservableObject {
    
    // MARK: - Inputs
    let viewDidLoad = PassthroughSubject<Void, Never>()
    let didSelectFilter = PassthroughSubject<String, Never>()
    let loadMore = PassthroughSubject<Void, Never>()
    
    // MARK: - Outputs
    @Published private(set) var posts: [Post] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var currentFilter: String = "전체"
    @Published private(set) var error: Error?
    
    private let feedRepository: FeedRepository
    private var cancellables = Set<AnyCancellable>()
    
    private var currentPage = 1
    private let pageSize = 20
    private var hasMorePages = true
    
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
                self?.loadMorePosts()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - API Calls
    
    private func refresh() {
        currentPage = 1
        hasMorePages = true
        posts = []
        fetchMyPosts(isInitialLoad: true)
    }
    
    func loadMorePosts() {
        guard hasMorePages && !isLoadingMore && !isLoading else { return }
        currentPage += 1
        fetchMyPosts(isInitialLoad: false)
    }
    
    private func fetchMyPosts(isInitialLoad: Bool = false) {
        if isInitialLoad {
            isLoading = true
        } else {
            isLoadingMore = true
        }
        
        let type = convertFilterToType(currentFilter)
        
        feedRepository.fetchMyPosts(
            type: type,
            page: currentPage,
            pageSize: pageSize,
            sort: "createdAt",
            order: "desc",
            diagnosis: nil,
            fromDate: nil,
            toDate: nil
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.isLoading = false
            self?.isLoadingMore = false
            if case .failure(let error) = completion {
                self?.error = error
                Logger.network.error("내가 쓴 글 조회 실패: \(error.localizedDescription)")
            }
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            
            if isInitialLoad {
                self.posts = response.posts
            } else {
                self.posts.append(contentsOf: response.posts)
            }
            
            self.hasMorePages = response.pagination.currentPage < response.pagination.totalPages
            self.currentPage = response.pagination.currentPage
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Helpers
    
    private func convertFilterToType(_ filter: String) -> String? {
        switch filter {
        case "전체": return "all"
        case "일상 기록": return "daily"
        case "치료 기록": return "wellness"
        default: return "all"
        }
    }
}
