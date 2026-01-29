import Foundation

struct Comment: Codable, Sendable {
    let id: Int
    let userId: Int
    let nickname: String
    let content: String
    let replies: [Reply]
    let createdAt: Int
    let updatedAt: Int
}

// API 명세의 CommentWithReplies와 동일하므로 typealias 추가
typealias CommentWithReplies = Comment

struct Reply: Codable, Sendable {
    let id: Int
    let userId: Int
    let nickname: String
    let content: String
    let parentId: Int
    let createdAt: Int
    let updatedAt: Int
}
