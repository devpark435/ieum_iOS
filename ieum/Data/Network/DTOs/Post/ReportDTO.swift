import Foundation

// MARK: - 신고 사유

enum ReportReason: String, Codable, CaseIterable, Sendable {
    case profanity
    case violence
    case sexualContent = "sexual_content"
    case fraud
    case spam
    case misinformation
    
    var displayName: String {
        switch self {
        case .profanity: return "욕설/비하"
        case .violence: return "폭력적인 내용"
        case .sexualContent: return "성적인 내용"
        case .fraud: return "사기/허위"
        case .spam: return "스팸"
        case .misinformation: return "잘못된 정보"
        }
    }
}

// MARK: - 게시글 신고 요청

struct ReportPostRequest: Codable, Sendable {
    let reason: String
}

// MARK: - 게시글 신고 응답

struct ReportPostResponse: Codable, Sendable {
    let postId: Int
    let postType: String
    let reason: String
    let reportsCount: Int
    let createdAt: Int
}

// MARK: - 댓글 신고 응답

struct ReportCommentResponse: Codable, Sendable {
    let commentId: Int
    let postType: String
    let postId: Int
    let reason: String
    let reportsCount: Int
    let createdAt: Int
}
