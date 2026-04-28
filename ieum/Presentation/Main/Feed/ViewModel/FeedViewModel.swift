import Foundation
import Combine
import Alamofire

final class FeedViewModel: ObservableObject {
    // Inputs
    let viewDidLoad = PassthroughSubject<Void, Never>()
    let didSelectFilter = PassthroughSubject<String, Never>()
    let didTapWritePost = PassthroughSubject<Void, Never>()
    let didTapLike = PassthroughSubject<Int, Never>()
    let didTapComment = PassthroughSubject<Int, Never>()
    let didTapMenu = PassthroughSubject<Post, Never>()
    let didTapEdit = PassthroughSubject<Post, Never>()
    let didTapDelete = PassthroughSubject<Post, Never>()
    let didTapReport = PassthroughSubject<Post, Never>()
    let didSelectReportReason = PassthroughSubject<(Post, ReportReason), Never>()
    let didTapBlock = PassthroughSubject<Post, Never>()
    let loadMore = PassthroughSubject<Void, Never>()
    
    // Outputs
    @Published private(set) var isLoading = false
    @Published private(set) var selectedFilter: String = "전체"
    @Published private(set) var posts: [Post] = []
    @Published private(set) var error: Error?
    @Published private(set) var currentUserId: Int?
    
    // Navigation Events
    let showWritePost = PassthroughSubject<Void, Never>()
    let navigateToComments = PassthroughSubject<(Int, PostType), Never>()
    let navigateToEdit = PassthroughSubject<Post, Never>()
    let showReportReasonPicker = PassthroughSubject<Post, Never>()
    
    private let feedRepository: FeedRepository
    private let authRepository: AuthRepository
    private var cancellables = Set<AnyCancellable>()
    
    private var currentPage = 1
    private let pageSize = 10
    private var isLastPage = false
    
    init(feedRepository: FeedRepository = FeedRepositoryImpl(),
         authRepository: AuthRepository = AuthRepositoryImpl()) {
        self.feedRepository = feedRepository
        self.authRepository = authRepository
        bindInputs()
        setupNotificationObserver()
        fetchCurrentUserId()
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
        
        didTapEdit
            .sink { [weak self] post in
                self?.navigateToEdit.send(post)
            }
            .store(in: &cancellables)
        
        didTapDelete
            .sink { [weak self] post in
                self?.deletePost(post)
            }
            .store(in: &cancellables)
        
        didTapReport
            .sink { [weak self] post in
                self?.showReportReasonPicker.send(post)
            }
            .store(in: &cancellables)
        
        didSelectReportReason
            .sink { [weak self] post, reason in
                self?.reportPost(post: post, reason: reason)
            }
            .store(in: &cancellables)

        didTapBlock
            .sink { [weak self] post in
                self?.blockUser(post: post)
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
        
        // TODO: 첫 배포 이후 diagnosis 필터 복원
        // let diagnosis = convertFilterToDiagnosis(selectedFilter)
        feedRepository.fetchPosts(type: type, page: currentPage, pageSize: pageSize, diagnosis: nil, mood: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                    print("❌ Feed Fetch Error: \(error)")
                    if let decodingError = error as? DecodingError {
                        print("Decoding Error Details: \(decodingError)")
                    }
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                let blockedIds = BlockedUserManager.shared.blockedUserIds
                let filtered = response.posts.filter { !blockedIds.contains($0.userId) }

                if self.currentPage == 1 {
                    self.posts = filtered
                } else {
                    self.posts.append(contentsOf: filtered)
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
    
    private func setupNotificationObserver() {
        NotificationCenter.default.publisher(for: NSNotification.Name("PostCreated"))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refresh()
            }
            .store(in: &cancellables)
    }
    
    private func convertFilterToPostType(_ filter: String) -> PostType {
        switch filter {
        case "전체": return .all
        case "일상 기록": return .daily
        case "치료 기록": return .wellness
        default: return .all
        }
    }
    
    // TODO: 첫 배포 이후 diagnosis 필터 복원
    // private func convertFilterToDiagnosis(_ filter: String) -> String? {
    //     switch filter {
    //     case "전체": return nil
    //     case "직장암": return "rectal_cancer"
    //     case "대장암": return "colon_cancer"
    //     case "간이식": return "liver_transplant"
    //     case "기타": return "others"
    //     default: return nil
    //     }
    // }
    
    // MARK: - Current User
    
    private func fetchCurrentUserId() {
        authRepository.getProfile()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("Failed to fetch current user ID: \(error)")
                }
            } receiveValue: { [weak self] profile in
                self?.currentUserId = profile.id
            }
            .store(in: &cancellables)
    }
    
    func isMyPost(_ post: Post) -> Bool {
        guard let currentUserId = currentUserId else { return false }
        return post.userId == currentUserId
    }
    
    // MARK: - Report
    
    private func reportPost(post: Post, reason: ReportReason) {
        guard post.type != .all else { return }
        
        Task { @MainActor in
            do {
                _ = try await feedRepository.reportPost(
                    type: post.type,
                    id: post.id,
                    reason: reason.rawValue
                )
                posts.removeAll { $0.id == post.id && $0.type == post.type }
                Toast.show(message: "신고가 접수되었습니다")
            } catch {
                let message = Self.reportErrorMessage(from: error)
                Toast.show(message: message)
            }
        }
    }
    
    // MARK: - Block

    private func blockUser(post: Post) {
        BlockedUserManager.shared.block(userId: post.userId)
        posts.removeAll { $0.userId == post.userId }
        Toast.show(message: "\(post.userNickname)님을 차단했습니다")
    }

    private static func reportErrorMessage(from error: Error) -> String {
        guard let afError = error as? AFError,
              case .responseValidationFailed(let reason) = afError,
              case .unacceptableStatusCode(let code) = reason else {
            return "신고 처리 중 오류가 발생했습니다"
        }
        
        switch code {
        case 409: return "이미 신고한 게시물입니다"
        case 403: return "자신의 게시물은 신고할 수 없습니다"
        default: return "신고 처리 중 오류가 발생했습니다"
        }
    }
    
    // MARK: - Delete
    
    private func deletePost(_ post: Post) {
        let publisher: AnyPublisher<Void, Error>
        
        switch post.type {
        case .wellness:
            publisher = feedRepository.deleteWellnessPost(id: post.id)
        case .daily:
            publisher = feedRepository.deleteDailyPost(id: post.id)
        case .all:
            return
        }
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                    print("Delete Error: \(error)")
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                // 피드에서 해당 게시글 제거
                self.posts.removeAll { $0.id == post.id }
                Toast.show(message: "게시글이 삭제되었습니다")
            }
            .store(in: &cancellables)
    }
}
