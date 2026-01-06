import Foundation

struct CommentResponse: Codable {
    let comments: [Comment]
    let pagination: Pagination
}

