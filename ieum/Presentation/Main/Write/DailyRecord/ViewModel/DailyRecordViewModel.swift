import Foundation
import Combine
import UIKit

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
    
    init(feedRepository: FeedRepository = FeedRepositoryImpl()) {
        self.feedRepository = feedRepository
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
        let availableSlots = 3 - photos.count
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
        feedRepository.createDailyPost(data: requestData, images: imageDatas)
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
            }
            .store(in: &cancellables)
    }
}
