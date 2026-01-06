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
    
    // MARK: - State
    private var title = ""
    private var content = ""
    private var isPublic = false
    
    // MARK: - Navigation
    let dismiss = PassthroughSubject<Void, Never>()
    let postSuccess = PassthroughSubject<Void, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
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
        let isValid = !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                      !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        isPostEnabled = isValid
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
        guard isPostEnabled else { return }
        
        isLoading = true
        // TODO: 실제 API 연동
        print("Daily Record Posting: \(title), \(content), Public: \(isPublic), Photos: \(photos.count)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isLoading = false
            self?.postSuccess.send()
        }
    }
}

