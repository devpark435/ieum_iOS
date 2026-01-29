import Foundation
import Combine
import UIKit
import Kingfisher

final class DailyRecordViewModel: ObservableObject {
    
    // MARK: - Inputs
    let updateTitle = PassthroughSubject<String, Never>()
    let updateContent = PassthroughSubject<String, Never>()
    let updateIsPublic = PassthroughSubject<Bool, Never>()
    let didTapPost = PassthroughSubject<Void, Never>()
    
    // MARK: - Outputs
    @Published private(set) var isPostEnabled = false
    @Published private(set) var isLoading = false
    @Published private(set) var photos: [UIImage] = []
    @Published private(set) var error: Error?
    
    // MARK: - State
    private var title = ""
    private var content = ""
    private var isPublic = false
    
    // MARK: - Navigation
    let dismiss = PassthroughSubject<Void, Never>()
    let postSuccess = PassthroughSubject<Void, Never>()
    
    private let feedRepository: FeedRepository
    private var cancellables = Set<AnyCancellable>()
    
    // 수정 모드
    private let isEditMode: Bool
    private let postId: Int?
    
    init(post: Post? = nil, feedRepository: FeedRepository = FeedRepositoryImpl()) {
        self.feedRepository = feedRepository
        self.isEditMode = post != nil
        self.postId = post?.id
        
        if let post = post {
            loadPostData(post)
        }
        
        bindInputs()
    }
    
    private func bindInputs() {
        updateTitle
            .sink { [weak self] title in
                self?.title = title
                self?.validateInput()
            }
            .store(in: &cancellables)
            
        updateContent
            .sink { [weak self] content in
                self?.content = content
                self?.validateInput()
            }
            .store(in: &cancellables)
            
        updateIsPublic
            .sink { [weak self] isPublic in
                self?.isPublic = isPublic
            }
            .store(in: &cancellables)
            
        didTapPost
            .sink { [weak self] in
                self?.postRecord()
            }
            .store(in: &cancellables)
    }
    
    private func validateInput() {
        // 제목은 선택 사항, content는 필수
        let isContentValid = !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        isPostEnabled = isContentValid
    }
    
    func addPhotos(_ newPhotos: [UIImage]) {
        let availableSlots = 5 - photos.count
        guard availableSlots > 0 else { return }
        
        let prefix = newPhotos.prefix(availableSlots)
        photos.append(contentsOf: prefix)
    }
    
    func removePhoto(at index: Int) {
        guard index >= 0 && index < photos.count else { return }
        photos.remove(at: index)
    }
    
    private func postRecord() {
        guard isPostEnabled, !isLoading else { return }
        
        if isEditMode {
            updateRecord()
        } else {
            createRecord()
        }
    }
    
    private func createRecord() {
        isLoading = true
        
        // 1. Data 변환
        let requestData = CreateDailyPostData(
            title: title.isEmpty ? nil : title,
            content: content,
            shared: isPublic
        )
        
        // 2. Image 변환
        let imageDatas = photos.compactMap { $0.jpegData(compressionQuality: 0.8) }
        
        // 3. API 호출
        feedRepository.createDailyPost(data: requestData, images: imageDatas.isEmpty ? nil : imageDatas)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                    print("Upload Error: \(error)")
                }
            } receiveValue: { [weak self] response in
                self?.postSuccess.send()
                Toast.show(message: "일상 기록 작성을 완료했습니다")
                NotificationCenter.default.post(name: NSNotification.Name("PostCreated"), object: nil)
            }
            .store(in: &cancellables)
    }
    
    private func updateRecord() {
        guard let postId = postId else { return }
        
        isLoading = true
        
        // UpdateDailyPostData 생성 (변경된 필드만 포함)
        let updateData = UpdateDailyPostData(
            title: title.isEmpty ? nil : title,
            content: content.isEmpty ? nil : content,
            shared: isPublic
        )
        
        // 이미지 변환 (있는 경우만)
        let imageDatas = photos.isEmpty ? nil : photos.compactMap { $0.jpegData(compressionQuality: 0.8) }
        
        // API 호출
        feedRepository.updateDailyPost(id: postId, data: updateData, images: imageDatas)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                    print("Update Error: \(error)")
                }
            } receiveValue: { [weak self] response in
                self?.postSuccess.send()
                Toast.show(message: "일상 기록 수정을 완료했습니다")
                NotificationCenter.default.post(name: NSNotification.Name("PostCreated"), object: nil)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Load Post Data
    
    private func loadPostData(_ post: Post) {
        guard post.type == .daily else { return }
        
        // Title
        title = post.title ?? ""
        
        // Content
        content = post.content ?? ""
        
        // Public Status
        isPublic = post.shared ?? false
        
        // 초기값 설정 후 validation
        validateInput()
        
        // Load images from URLs
        if let images = post.images, !images.isEmpty {
            loadImages(from: images)
        }
    }
    
    private func loadImages(from imageInfos: [ImageInfo]) {
        let group = DispatchGroup()
        var loadedImages: [UIImage] = []
        
        for imageInfo in imageInfos {
            guard let url = URL(string: imageInfo.url) else { continue }
            
            group.enter()
            KingfisherManager.shared.retrieveImage(with: url) { result in
                defer { group.leave() }
                
                switch result {
                case .success(let value):
                    loadedImages.append(value.image)
                case .failure(let error):
                    print("Failed to load image: \(error)")
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.photos = loadedImages
        }
    }
    
    // MARK: - Public Methods for Initial Values
    
    var initialTitle: String {
        return title
    }
    
    var initialContent: String {
        return content
    }
    
    var initialIsPublic: Bool {
        return isPublic
    }
}
