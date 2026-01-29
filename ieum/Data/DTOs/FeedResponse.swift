import Foundation

// MARK: - FeedResponse (AllPostsResponse)

struct FeedResponse: Codable, Sendable {
    let posts: [Post]
    let pagination: Pagination
}

// API 명세의 AllPostsResponse와 동일하므로 typealias 추가
typealias AllPostsResponse = FeedResponse

// MARK: - Pagination

struct Pagination: Codable, Sendable {
    let currentPage: Int
    let perPage: Int
    let totalItems: Int
    let totalPages: Int
}
