import Foundation

struct Comment: Codable {
    let id: Int
    let userId: Int
    let nickname: String
    let content: String
    let replies: [Reply]
    let createdAt: Int
    let updatedAt: Int
}

struct Reply: Codable {
    let id: Int
    let userId: Int
    let nickname: String
    let content: String
    let parentId: Int
    let createdAt: Int
    let updatedAt: Int
}

