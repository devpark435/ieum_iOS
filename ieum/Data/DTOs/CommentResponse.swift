import Foundation

struct CommentResponse: Codable, Sendable {
    let comments: [Comment]
    let pagination: Pagination
}

// API 명세의 CommentsResponse와 동일하므로 typealias 추가
typealias CommentsResponse = CommentResponse
