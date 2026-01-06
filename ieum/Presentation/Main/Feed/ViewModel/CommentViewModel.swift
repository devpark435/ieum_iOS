import Foundation
import Combine

final class CommentViewModel {
    
    // MARK: - Properties
    
    let postId: Int
    
    // Inputs
    let viewDidLoad = PassthroughSubject<Void, Never>()
    let didTapSend = PassthroughSubject<String, Never>()
    let didTapReply = PassthroughSubject<Comment, Never>()
    let didTapReport = PassthroughSubject<Int, Never>() // Comment ID
    let didTapLike = PassthroughSubject<Int, Never>() // Comment ID
    
    // Outputs
    @Published private(set) var comments: [Comment] = []
    @Published private(set) var replyingTo: Comment? = nil
    @Published private(set) var likes: [Int: (isLiked: Bool, count: Int)] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    init(postId: Int) {
        self.postId = postId
        bindInputs()
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
                self?.reportComment(id: commentId)
            }
            .store(in: &cancellables)
            
        didTapLike
            .sink { [weak self] commentId in
                self?.toggleLike(for: commentId)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Logic
    
    private func fetchComments() {
        // Mock Data
        let mockComments = [
            Comment(
                id: 1,
                userId: 101,
                nickname: "희망찬환자",
                content: "좋은 글 감사합니다! 많은 도움이 되었어요.",
                replies: [
                    Reply(
                        id: 11,
                        userId: 202,
                        nickname: "응원해요",
                        content: "저도 동감합니다!",
                        parentId: 1,
                        createdAt: Int(Date().timeIntervalSince1970) - 3600,
                        updatedAt: Int(Date().timeIntervalSince1970) - 3600
                    )
                ],
                createdAt: Int(Date().timeIntervalSince1970) - 7200,
                updatedAt: Int(Date().timeIntervalSince1970) - 7200
            ),
            Comment(
                id: 2,
                userId: 102,
                nickname: "건강이최고",
                content: "혹시 어떤 식단으로 관리하시나요?",
                replies: [],
                createdAt: Int(Date().timeIntervalSince1970) - 86400,
                updatedAt: Int(Date().timeIntervalSince1970) - 86400
            )
        ]
        
        self.comments = mockComments
        
        // Mock Likes
        self.likes = [
            1: (isLiked: false, count: 5),
            11: (isLiked: true, count: 2),
            2: (isLiked: false, count: 0)
        ]
    }
    
    private func postComment(content: String) {
        let newId = (comments.map { $0.id }.max() ?? 0) + 1
        let now = Int(Date().timeIntervalSince1970)
        
        if let parent = replyingTo {
            // Add Reply
            let newReply = Reply(
                id: Int.random(in: 1000...9999),
                userId: 999, // Current User
                nickname: "나",
                content: content,
                parentId: parent.id,
                createdAt: now,
                updatedAt: now
            )
            
            if let index = comments.firstIndex(where: { $0.id == parent.id }) {
                var updatedComment = comments[index]
                var updatedReplies = updatedComment.replies
                updatedReplies.append(newReply)
                
                let newComment = Comment(
                    id: updatedComment.id,
                    userId: updatedComment.userId,
                    nickname: updatedComment.nickname,
                    content: updatedComment.content,
                    replies: updatedReplies,
                    createdAt: updatedComment.createdAt,
                    updatedAt: updatedComment.updatedAt
                )
                
                comments[index] = newComment
            }
            
            replyingTo = nil
            
        } else {
            // Add Top-level Comment
            let newComment = Comment(
                id: newId,
                userId: 999,
                nickname: "나",
                content: content,
                replies: [],
                createdAt: now,
                updatedAt: now
            )
            comments.append(newComment)
        }
    }
    
    private func reportComment(id: Int) {
        print("Report Comment ID: \(id)")
    }
    
    private func toggleLike(for id: Int) {
        guard let current = likes[id] else {
            // Initialize if not exists
            likes[id] = (isLiked: true, count: 1)
            return
        }
        
        let newIsLiked = !current.isLiked
        let newCount = current.count + (newIsLiked ? 1 : -1)
        likes[id] = (isLiked: newIsLiked, count: newCount)
    }
}

