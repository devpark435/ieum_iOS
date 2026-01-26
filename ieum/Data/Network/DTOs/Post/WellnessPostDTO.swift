import Foundation

// MARK: - Create Wellness Post Request

struct CreateWellnessPostData: Codable, Sendable {
    let diagnosis: [String]?
    let mood: Int
    let unusualSymptoms: String?
    let medicationTaken: Bool
    let diet: Diet?
    let memo: String?
    let shared: Bool
}

// MARK: - Update Wellness Post Request

struct UpdateWellnessPostData: Codable, Sendable {
    let diagnosis: [String]?
    let mood: Int?
    let unusualSymptoms: String?
    let medicationTaken: Bool?
    let diet: Diet?
    let memo: String?
    let shared: Bool?
}

// MARK: - Create Daily Post Request

struct CreateDailyPostData: Codable, Sendable {
    let title: String?
    let content: String
    let shared: Bool
}

// MARK: - Wellness Post Response

struct WellnessPostResponse: Codable, Sendable {
    let id: Int
    let type: PostType
    let title: String?
    let content: String?
    let diagnosis: [String]
    let mood: Int
    let unusualSymptoms: String?
    let medicationTaken: Bool
    let diet: Diet?
    let memo: String?
    let images: [ImageInfo]?
    let shared: Bool
    let likesCount: Int
    let commentsCount: Int
    let isLiked: Bool
    let createdAt: Int
    let updatedAt: Int
}

// MARK: - Daily Post Response

struct DailyPostResponse: Codable, Sendable {
    let id: Int
    let type: PostType
    let title: String?
    let content: String
    let images: [ImageInfo]?
    let shared: Bool
    let likesCount: Int
    let commentsCount: Int
    let isLiked: Bool
    let createdAt: Int
    let updatedAt: Int
}

// MARK: - Like Response

struct LikeResponse: Codable, Sendable {
    let postId: Int
    let postType: PostType
    let likesCount: Int
    let isLiked: Bool
    let createdAt: Int
}

// MARK: - Create Comment Request

struct CreateCommentRequest: Codable, Sendable {
    let content: String
    let parentId: Int?
}

// MARK: - Create Comment Response

struct CreateCommentResponse: Codable, Sendable {
    let id: Int
    let postType: PostType
    let postId: Int
    let userId: Int
    let nickname: String
    let content: String
    let parentId: Int?
    let createdAt: Int
    let updatedAt: Int
}

// MARK: - Comment Like Response

struct CommentLikeResponse: Codable, Sendable {
    let commentId: Int
    let postType: PostType
    let postId: Int
    let likesCount: Int
    let isLiked: Bool
    let createdAt: Int
}
