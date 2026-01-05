import Foundation

// MARK: - Request
struct CreateWellnessPostRequest: Encodable {
    let data: CreateWellnessPostData
    // images는 Multipart Form Data로 별도 처리되므로 JSON 인코딩에는 포함하지 않음
    // API 명세상 data 필드는 JSON String으로 보내야 하므로, 
    // 실제 전송 시에는 data 객체를 JSON String으로 변환해서 Multipart body에 담아야 함.
}

struct CreateWellnessPostData: Encodable {
    let diagnosis: [String]? // 비어있으면 서버에서 사용자 정보 사용
    let mood: Int // 1~5
    let unusualSymptoms: String?
    let medicationTaken: Bool
    let diet: DietData?
    let memo: String?
    let shared: Bool
}

struct DietData: Encodable {
    let amountEaten: String // well_eaten, small_amount, barely_eaten
    let mealContent: String?
}

// MARK: - Enums for Mapping
enum DietAmount: String, Encodable {
    case wellEaten = "well_eaten"
    case smallAmount = "small_amount"
    case barelyEaten = "barely_eaten"
}

// MARK: - Response
struct WellnessPostResponse: Decodable {
    let id: Int
    let type: String
    let diagnosis: [String]
    let mood: Int
    let unusualSymptoms: String?
    let medicationTaken: Bool
    let diet: DietResponse?
    let memo: String?
    let images: [ImageResponse]?
    let shared: Bool
    let createdAt: Int
    let updatedAt: Int
}

struct DietResponse: Decodable {
    let amountEaten: String
    let mealContent: String?
}

struct ImageResponse: Decodable {
    let url: String
    let filename: String?
    let uploadedAt: Int
}

