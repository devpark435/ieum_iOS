import UIKit
import SnapKit
import Then
import Combine
import PhotosUI

final class DailyRecordViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: DailyRecordViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let navigationBarView = UIView().then {
        $0.backgroundColor = Colors.Slate.s100
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "일상 기록"
        $0.font = .ieum(UIFont.IeumFont.Heading.h4)
        $0.textColor = Colors.Slate.s800
        $0.textAlignment = .center
    }
    
    private let closeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = Colors.Gray.g950
    }
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.keyboardDismissMode = .onDrag
        $0.backgroundColor = Colors.Slate.s100
    }
    
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
        $0.alignment = .fill
        $0.distribution = .fill
    }
    
    private let inputViewComponent = DailyInputView()
    
    private let photoRecordView = RecordItemView(
        iconName: "photo-icon",
        title: "사진추가",
        subtitle: "최대 3장까지 가능합니다."
    )
    
    private let shareView = RecordShareView().then {
        $0.onCheckChanged = { _ in } // Initial closure, rewritten in setupActions
    }
    
    private let postButton = IeumButton(title: "게시하기").then {
        $0.isEnabled = false
        $0.setStyle(backgroundColor: Colors.Treatment.buttonBackground, borderColor: Colors.Treatment.buttonBorder, titleColor: Colors.white, for: .normal)
        $0.setStyle(backgroundColor: Colors.Gray.g200, borderColor: Colors.Gray.g200, titleColor: Colors.Gray.g400, for: .disabled)
    }
    
    // MARK: - Initializer
    
    init(viewModel: DailyRecordViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.Slate.s100
        setupUI()
        setupLayout()
        setupActions()
        bindViewModel()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(navigationBarView)
        navigationBarView.addSubview(titleLabel)
        navigationBarView.addSubview(closeButton)
        
        view.addSubview(postButton)
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(inputViewComponent)
        contentStackView.addArrangedSubview(photoRecordView)
        contentStackView.addArrangedSubview(shareView)
    }
    
    private func setupLayout() {
        navigationBarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        postButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(56)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationBarView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(postButton.snp.top).offset(-16)
        }
        
        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
            $0.width.equalToSuperview().inset(20)
        }
        
        inputViewComponent.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(300) // Flexible height for input
        }
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        postButton.addTarget(self, action: #selector(didTapPost), for: .touchUpInside)
        
        inputViewComponent.onTitleChanged = { [weak self] text in
            self?.viewModel.updateTitle.send(text)
        }
        
        inputViewComponent.onContentChanged = { [weak self] text in
            self?.viewModel.updateContent.send(text)
        }
        
        // RecordShareView does not have a closure property 'onCheckChanged', but 'isChecked' property.
        // We need to add a target/action or KVO, but RecordShareView logic is internal.
        // Let's modify RecordShareView to expose a closure or use the existing checkBoxButton target if accessible.
        // Since I cannot modify RecordShareView easily without checking it, I will check if I can access checkBoxButton.
        // RecordShareView.checkBoxButton is 'lazy var', internal access.
        // But better practice is to add the closure to RecordShareView.
        // Wait, looking at RecordShareView.swift read above:
        // It has `var isChecked: Bool` with `didSet`. And `didTapCheckBox` toggles it.
        // It does NOT have a callback closure exposed.
        // I should add `var onCheckChanged: ((Bool) -> Void)?` to RecordShareView.swift first.
        
        // For now, I will add the closure to RecordShareView.swift in a separate step.
        // Assuming it's added:
        shareView.onCheckChanged = { [weak self] isChecked in
            self?.viewModel.updateIsPublic.send(isChecked)
        }
        
        photoRecordView.onTap = { [weak self] in
            self?.showPhotoPicker()
        }
        
        photoRecordView.onDeletePhoto = { [weak self] index in
            self?.viewModel.removePhoto(at: index)
        }
    }
    
    private func bindViewModel() {
        viewModel.$isPostEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.postButton.isEnabled = isEnabled
            }
            .store(in: &cancellables)
            
        viewModel.$photos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photos in
                self?.photoRecordView.updatePhotos(images: photos)
            }
            .store(in: &cancellables)
            
        viewModel.dismiss
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)
            
        viewModel.postSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.dismiss(animated: true) {
                    Toast.show(message: "일상기록 작성을 완료 하였습니다.")
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
    
    @objc private func didTapPost() {
        viewModel.didTapPost.send()
    }
    
    private func showPhotoPicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 3 - viewModel.photos.count // Dynamic limit
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension DailyRecordViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard !results.isEmpty else { return }
        
        let dispatchGroup = DispatchGroup()
        var newPhotos: [UIImage] = []
        
        for result in results {
            dispatchGroup.enter()
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let image = image as? UIImage {
                        newPhotos.append(image)
                    }
                    dispatchGroup.leave()
                }
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.viewModel.addPhotos(newPhotos)
        }
    }
}

