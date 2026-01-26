import Foundation
import Combine
import Alamofire

protocol FeedRepository {
    // 조회
    func fetchPosts(type: PostType, page: Int, pageSize: Int, diagnosis: String?, mood: Int?) -> AnyPublisher<AllPostsResponse, Error>
    
    // 작성
    func createWellnessPost(data: CreateWellnessPostData, images: [Data]?) -> AnyPublisher<WellnessPostResponse, Error>
    func createDailyPost(data: CreateDailyPostData, images: [Data]?) -> AnyPublisher<DailyPostResponse, Error>
    
    // 좋아요
    func likePost(type: PostType, id: Int) -> AnyPublisher<LikeResponse, Error>
    func unlikePost(type: PostType, id: Int) -> AnyPublisher<LikeResponse, Error>
    
    // 댓글
    func fetchComments(postType: PostType, postId: Int, page: Int, pageSize: Int) -> AnyPublisher<CommentResponse, Error>
    func createComment(postType: PostType, postId: Int, content: String, parentId: Int?) -> AnyPublisher<CreateCommentResponse, Error>
    func likeComment(postType: PostType, postId: Int, commentId: Int) -> AnyPublisher<CommentLikeResponse, Error>
    func unlikeComment(postType: PostType, postId: Int, commentId: Int) -> AnyPublisher<CommentLikeResponse, Error>
    
    // 수정/삭제
    func updateWellnessPost(id: Int, data: UpdateWellnessPostData, images: [Data]?) -> AnyPublisher<WellnessPostResponse, Error>
    func deleteWellnessPost(id: Int) -> AnyPublisher<Void, Error>
}

final class FeedRepositoryImpl: FeedRepository {
    private let apiService = APIService.shared
    
    // MARK: - 조회
    
    func fetchPosts(type: PostType, page: Int, pageSize: Int, diagnosis: String?, mood: Int?) -> AnyPublisher<AllPostsResponse, Error> {
        var queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize)),
            URLQueryItem(name: "type", value: type.rawValue)
        ]
        
        if let diagnosis = diagnosis {
            queryItems.append(URLQueryItem(name: "diagnosis", value: diagnosis))
        }
        if let mood = mood {
            queryItems.append(URLQueryItem(name: "mood", value: String(mood)))
        }
        
        var components = URLComponents(string: "/api/v1/posts")
        components?.queryItems = queryItems
        let endpoint = components?.url?.absoluteString ?? "/api/v1/posts"
        
        return Future { [weak self] promise in
            guard let self = self else { return }
            Task {
                do {
                    let response: AllPostsResponse = try await self.apiService.request(endpoint, method: .get)
                    promise(.success(response))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: - 작성 (Multipart)
    
    func createWellnessPost(data: CreateWellnessPostData, images: [Data]?) -> AnyPublisher<WellnessPostResponse, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            Task {
                do {
                    let response: WellnessPostResponse = try await self.apiService.upload("/api/v1/posts/wellness") { multipartFormData in
                        // 1. JSON Data Part - JSON 문자열로 변환
                        if let jsonData = try? JSONEncoder().encode(data),
                           let jsonString = String(data: jsonData, encoding: .utf8) {
                            // JSON 문자열을 Data로 변환하여 append (mimeType 없이)
                            multipartFormData.append(
                                jsonString.data(using: .utf8)!,
                                withName: "data"
                            )
                        }
                        
                        // 2. Images Part
                        images?.enumerated().forEach { index, imageData in
                            multipartFormData.append(imageData,
                                                     withName: "images",
                                                     fileName: "image_\(index).jpg",
                                                     mimeType: "image/jpeg")
                        }
                    }
                    promise(.success(response))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func createDailyPost(data: CreateDailyPostData, images: [Data]?) -> AnyPublisher<DailyPostResponse, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            Task {
                do {
                    let response: DailyPostResponse = try await self.apiService.upload("/api/v1/posts/daily") { multipartFormData in
                        // 1. JSON Data Part - JSON 문자열로 변환
                        if let jsonData = try? JSONEncoder().encode(data),
                           let jsonString = String(data: jsonData, encoding: .utf8) {
                            // JSON 문자열을 Data로 변환하여 append (mimeType 없이)
                            multipartFormData.append(
                                jsonString.data(using: .utf8)!,
                                withName: "data"
                            )
                        }
                        
                        // 2. Images Part
                        images?.enumerated().forEach { index, imageData in
                            multipartFormData.append(imageData,
                                                     withName: "images",
                                                     fileName: "image_\(index).jpg",
                                                     mimeType: "image/*")
                        }
                    }
                    promise(.success(response))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: - 좋아요
    
    func likePost(type: PostType, id: Int) -> AnyPublisher<LikeResponse, Error> {
        let endpoint = "/api/v1/posts/\(type.rawValue)/\(id)/like"
        
        return Future { [weak self] promise in
            guard let self = self else { return }
            Task {
                do {
                    let response: LikeResponse = try await self.apiService.request(endpoint, method: .post)
                    promise(.success(response))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func unlikePost(type: PostType, id: Int) -> AnyPublisher<LikeResponse, Error> {
        let endpoint = "/api/v1/posts/\(type.rawValue)/\(id)/like"
        
        return Future { [weak self] promise in
            guard let self = self else { return }
            Task {
                do {
                    let response: LikeResponse = try await self.apiService.request(endpoint, method: .delete)
                    promise(.success(response))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: - 댓글
    
    func fetchComments(postType: PostType, postId: Int, page: Int, pageSize: Int) -> AnyPublisher<CommentResponse, Error> {
        var components = URLComponents(string: "/api/v1/posts/\(postType.rawValue)/\(postId)/comments")
        components?.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        let endpoint = components?.url?.absoluteString ?? "/api/v1/posts/\(postType.rawValue)/\(postId)/comments"
        
        return Future { [weak self] promise in
            guard let self = self else { return }
            Task {
                do {
                    let response: CommentResponse = try await self.apiService.request(endpoint, method: .get)
                    promise(.success(response))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func createComment(postType: PostType, postId: Int, content: String, parentId: Int?) -> AnyPublisher<CreateCommentResponse, Error> {
        let endpoint = "/api/v1/posts/\(postType.rawValue)/\(postId)/comments"
        let request = CreateCommentRequest(content: content, parentId: parentId)
        
        return Future { [weak self] promise in
            guard let self = self else { return }
            Task {
                do {
                    let response: CreateCommentResponse = try await self.apiService.request(endpoint, method: .post, parameters: request)
                    promise(.success(response))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func likeComment(postType: PostType, postId: Int, commentId: Int) -> AnyPublisher<CommentLikeResponse, Error> {
        let endpoint = "/api/v1/posts/\(postType.rawValue)/\(postId)/comments/\(commentId)/like"
        
        return Future { [weak self] promise in
            guard let self = self else { return }
            Task {
                do {
                    let response: CommentLikeResponse = try await self.apiService.request(endpoint, method: .post)
                    promise(.success(response))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func unlikeComment(postType: PostType, postId: Int, commentId: Int) -> AnyPublisher<CommentLikeResponse, Error> {
        let endpoint = "/api/v1/posts/\(postType.rawValue)/\(postId)/comments/\(commentId)/like"
        
        return Future { [weak self] promise in
            guard let self = self else { return }
            Task {
                do {
                    let response: CommentLikeResponse = try await self.apiService.request(endpoint, method: .delete)
                    promise(.success(response))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: - 수정/삭제
    
    func updateWellnessPost(id: Int, data: UpdateWellnessPostData, images: [Data]?) -> AnyPublisher<WellnessPostResponse, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            Task {
                do {
                    let response: WellnessPostResponse = try await self.apiService.upload("/api/v1/posts/wellness/\(id)", method: .patch) { multipartFormData in
                        // 1. JSON Data Part - JSON 문자열로 변환 (data가 비어있지 않은 경우만)
                        if let jsonData = try? JSONEncoder().encode(data),
                           let jsonString = String(data: jsonData, encoding: .utf8) {
                            multipartFormData.append(
                                jsonString.data(using: .utf8)!,
                                withName: "data"
                            )
                        }
                        
                        // 2. Images Part (있는 경우만)
                        images?.enumerated().forEach { index, imageData in
                            multipartFormData.append(imageData,
                                                     withName: "images",
                                                     fileName: "image_\(index).jpg",
                                                     mimeType: "image/jpeg")
                        }
                    }
                    promise(.success(response))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteWellnessPost(id: Int) -> AnyPublisher<Void, Error> {
        let endpoint = "/api/v1/posts/wellness/\(id)"
        
        return Future { [weak self] promise in
            guard let self = self else { return }
            Task {
                do {
                    try await self.apiService.requestNoContent(endpoint, method: .delete)
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}
