import Foundation

// MARK: - FeedResponse

struct FeedResponse: Codable {
    let posts: [Post]
    let pagination: Pagination
}

// MARK: - Pagination

struct Pagination: Codable {
    let currentPage: Int
    let perPage: Int
    let totalItems: Int
    let totalPages: Int
}

