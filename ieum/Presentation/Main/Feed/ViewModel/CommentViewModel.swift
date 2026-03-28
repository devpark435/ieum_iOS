import Foundation
import Combine
import Alamofire

final class CommentViewModel: ObservableObject {
    
    // MARK: - Properties
    
    let postId: Int
    let postType: PostType
    
    // Inputs
    let viewDidLoad = PassthroughSubject<Void, Never>()
    let didTapSend = PassthroughSubject<String, Never>()
    let didTapReply = PassthroughSubject<Comment, Never>()
    let didTapReport = PassthroughSubject<Int, Never>() // Comment ID
    let didSelectReportReason = PassthroughSubject<(Int, ReportReason), Never>()
    let didTapLike = PassthroughSubject<Int, Never>() // Comment ID
    let didTapEdit = PassthroughSubject<Int, Never>() // Comment ID
    let didTapDelete = PassthroughSubject<Int, Never>() // Comment ID
    
    // Outputs
    @Published private(set) var comments: [Comment] = []
    @Published private(set) var replyingTo: Comment? = nil
    @Published private(set) var likes: [Int: (isLiked: Bool, count: Int)] = [:]
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?
    let commentPostedSuccessfully = PassthroughSubject<Void, Never>()
    let navigateToEdit = PassthroughSubject<(id: Int, content: String), Never>()
    let showReportReasonPicker = PassthroughSubject<Int, Never>()
    
    private var currentUserId: Int?
    private let feedRepository: FeedRepository
    private let authRepository: AuthRepository
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    init(postId: Int, postType: PostType, feedRepository: FeedRepository = FeedRepositoryImpl(), authRepository: AuthRepository = AuthRepositoryImpl()) {
        self.postId = postId
        self.postType = postType
        self.feedRepository = feedRepository
        self.authRepository = authRepository
        bindInputs()
        fetchCurrentUserId()
    }
    
    // MARK: - Binding
    
    private func bindInputs() {
        viewDidLoad
            .sink { [weak self] in
                self?.fetchComments()
            }
            .store(in: &cancellables)
        
        didTapSend
            .sink { [weak self] text in
                self?.postComment(content: text)
            }
            .store(in: &cancellables)
        
        didTapReply
            .sink { [weak self] comment in
                self?.replyingTo = comment
            }
            .store(in: &cancellables)
        
        didTapReport
            .sink { [weak self] commentId in
                self?.showReportReasonPicker.send(commentId)
            }
            .store(in: &cancellables)
        
        didSelectReportReason
            .sink { [weak self] commentId, reason in
                self?.reportComment(id: commentId, reason: reason)
            }
            .store(in: &cancellables)
            
        didTapLike
            .sink { [weak self] commentId in
                self?.toggleLike(for: commentId)
            }
            .store(in: &cancellables)
        
        didTapEdit
            .sink { [weak self] commentId in
                self?.handleEdit(commentId: commentId)
            }
            .store(in: &cancellables)
        
        didTapDelete
            .sink { [weak self] commentId in
                self?.deleteComment(id: commentId)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Current User
    
    private func fetchCurrentUserId() {
        authRepository.getProfile()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("Failed to fetch current user: \(error)")
                }
            } receiveValue: { [weak self] profile in
                self?.currentUserId = profile.id
            }
            .store(in: &cancellables)
    }
    
    func isMyComment(_ comment: Comment) -> Bool {
        guard let currentUserId = currentUserId else { return false }
        return comment.userId == currentUserId
    }
    
    func isMyComment(_ reply: Reply) -> Bool {
        guard let currentUserId = currentUserId else { return false }
        return reply.userId == currentUserId
    }
    
    // MARK: - Logic
    
    private func fetchComments() {
        isLoading = true
        
        feedRepository.fetchComments(postType: postType, postId: postId, page: 1, pageSize: 20)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                
                self.comments = response.comments
                
                // API 응답에는 likes 정보가 없으므로 초기값 설정
                var initialLikes: [Int: (isLiked: Bool, count: Int)] = [:]
                for comment in response.comments {
                    initialLikes[comment.id] = (isLiked: false, count: 0)
                    for reply in comment.replies {
                        initialLikes[reply.id] = (isLiked: false, count: 0)
                    }
                }
                self.likes = initialLikes
            }
            .store(in: &cancellables)
    }
    
    private func postComment(content: String) {
        let parentId = replyingTo?.id
        
        feedRepository.createComment(postType: postType, postId: postId, content: content, parentId: parentId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                
                // 댓글 작성 성공 후 목록 새로고침
                self.replyingTo = nil
                self.commentPostedSuccessfully.send()
                self.fetchComments()
            }
            .store(in: &cancellables)
    }
    
    private func reportComment(id: Int, reason: ReportReason) {
        Task { @MainActor in
            do {
                _ = try await feedRepository.reportComment(
                    postType: postType,
                    postId: postId,
                    commentId: id,
                    reason: reason.rawValue
                )
                Toast.show(message: "신고가 접수되었습니다")
            } catch {
                let message = Self.reportErrorMessage(from: error)
                Toast.show(message: message)
            }
        }
    }
    
    private static func reportErrorMessage(from error: Error) -> String {
        guard let afError = error as? AFError,
              case .responseValidationFailed(let reason) = afError,
              case .unacceptableStatusCode(let code) = reason else {
            return "신고 처리 중 오류가 발생했습니다"
        }
        
        switch code {
        case 409: return "이미 신고한 댓글입니다"
        case 403: return "자신의 댓글은 신고할 수 없습니다"
        default: return "신고 처리 중 오류가 발생했습니다"
        }
    }
    
    private func toggleLike(for id: Int) {
        // 현재 좋아요 상태 확인
        let currentLikeInfo = likes[id] ?? (isLiked: false, count: 0)
        let isCurrentlyLiked = currentLikeInfo.isLiked
        
        // 좋아요 상태에 따라 적절한 API 호출
        let publisher: AnyPublisher<CommentLikeResponse, Error>
        if isCurrentlyLiked {
            publisher = feedRepository.unlikeComment(postType: postType, postId: postId, commentId: id)
        } else {
            publisher = feedRepository.likeComment(postType: postType, postId: postId, commentId: id)
        }
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                
                // 좋아요 상태 업데이트
                self.likes[id] = (isLiked: response.isLiked, count: response.likesCount)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Edit/Delete
    
    private func handleEdit(commentId: Int) {
        // 댓글 또는 대댓글 찾기
        for comment in comments {
            if comment.id == commentId {
                navigateToEdit.send((id: comment.id, content: comment.content))
                return
            }
            for reply in comment.replies {
                if reply.id == commentId {
                    navigateToEdit.send((id: reply.id, content: reply.content))
                    return
                }
            }
        }
    }
    
    func updateComment(id: Int, content: String) {
        feedRepository.updateComment(postType: postType, postId: postId, commentId: id, content: content)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                // 댓글 수정 성공 후 목록 새로고침
                self.fetchComments()
            }
            .store(in: &cancellables)
    }
    
    private func deleteComment(id: Int) {
        feedRepository.deleteComment(postType: postType, postId: postId, commentId: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                // 댓글 삭제 성공 후 목록 새로고침
                self.fetchComments()
            }
            .store(in: &cancellables)
    }
}
