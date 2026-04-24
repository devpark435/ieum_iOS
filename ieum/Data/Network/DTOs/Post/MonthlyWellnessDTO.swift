import Foundation

// MARK: - Monthly Wellness Response

struct MonthlyWellnessResponse: Codable, Sendable {
    let year: Int
    let month: Int
    let posts: [MonthlyWellnessPost]
    let totalCount: Int
}

// MARK: - Monthly Wellness Post

struct MonthlyWellnessPost: Codable, Sendable {
    let id: Int
    let userId: Int
    let userNickname: String
    let type: String
    let title: String?
    let content: String?
    let diagnosis: [String]?
    let mood: Int?
    let unusualSymptoms: String?
    let medicationTaken: Bool?
    let diet: Diet?
    let memo: String?
    let images: [ImageInfo]?
    let shared: Bool?
    let likesCount: Int?
    let commentsCount: Int?
    let createdAt: Int
    let updatedAt: Int
    let isLiked: Bool?
}
