import UIKit
import SnapKit
import Then
import Combine
import PhotosUI

final class TreatmentRecordViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: TreatmentRecordViewModel
    private var cancellables = Set<AnyCancellable>()
    weak var coordinator: AppCoordinator?
    
    // MARK: - Initializer
    
    init(post: Post? = nil) {
        self.viewModel = TreatmentRecordViewModel(post: post)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    
    private let navigationBar = UIView().then {
        $0.backgroundColor = Colors.Slate.s100
    }
    
    private let closeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = Colors.Gray.g950
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "치료 기록"
        $0.font = .ieum(UIFont.IeumFont.Heading.h4)
        $0.textColor = Colors.Slate.s800
    }
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = Colors.Slate.s100
    }
    
    private let contentView = UIView()
    
    // 기분 상태 영역
    private let moodContainerView = UIView()
    
    private let moodImageView = UIImageView().then {
        $0.image = UIImage(named: "feeling-unselected")
        $0.contentMode = .scaleAspectFit
    }
    
    private let changeMoodButton = UIButton().then {
        $0.backgroundColor = Colors.Slate.s800
        $0.layer.cornerRadius = 12
        $0.setImage(UIImage(named: "change-icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.white
        $0.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    }
    
    private let bottomGradientView = UIView().then {
        $0.isUserInteractionEnabled = false
    }
    
    // 기록 항목 스택뷰
    private let recordStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.distribution = .fill
    }
    
    private let symptomItem = RecordItemView(
        iconName: "symptom-icon",
        title: "특이증상",
        subtitle: "평소와 다른 증상이 있다면 적어주세요"
    )
    
    private let medicationItem = RecordItemView(
        iconName: "medication-icon",
        title: "복약",
        subtitle: "복약 상태를 체크해주세요"
    )
    
    private let mealItem = RecordItemView(
        iconName: "meal-icon",
        title: "식이상태",
        subtitle: "어떻게 드셨는지 기록해 보세요"
    )
    
    private let memoItem = RecordItemView(
        iconName: "memo-icon",
        title: "메모",
        subtitle: "더 적고 싶은 게 있다면 남겨주세요"
    )
    
    private let photoItem = RecordItemView(
        iconName: "photo-icon",
        title: "사진추가",
        subtitle: "최대 5장까지 가능합니다."
    )
    
    // 커뮤니티 공유 영역
    private let shareView = RecordShareView()
    
    // 게시하기 버튼
    private let postButton = IeumButton(title: "게시하기").then {
        $0.isEnabled = false
        $0.setStyle(backgroundColor: Colors.Treatment.buttonBackground, borderColor: Colors.Treatment.buttonBorder, titleColor: Colors.white, for: .normal)
        $0.setStyle(backgroundColor: Colors.Gray.g200, borderColor: Colors.Gray.g200, titleColor: Colors.Gray.g400, for: .disabled)
        
        $0.titleLabel?.font = .ieum(UIFont.IeumFont.Btn.large)
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.Slate.s100
        
        setupUI()
        setupLayout()
        setupActions()
        bindViewModel()
        
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let sublayers = bottomGradientView.layer.sublayers, !sublayers.isEmpty {
            sublayers.first?.frame = bottomGradientView.bounds
        } else {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = bottomGradientView.bounds
            gradientLayer.colors = [
                Colors.Slate.s100.withAlphaComponent(0).cgColor,
                Colors.Slate.s100.cgColor
            ]
            gradientLayer.locations = [0.0, 1.0]
            bottomGradientView.layer.addSublayer(gradientLayer)
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(navigationBar)
        navigationBar.addSubview(closeButton)
        navigationBar.addSubview(titleLabel)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(moodContainerView)
        moodContainerView.addSubview(moodImageView)
        moodContainerView.addSubview(changeMoodButton)
        
        contentView.addSubview(recordStackView)
        recordStackView.addArrangedSubview(symptomItem)
        recordStackView.addArrangedSubview(medicationItem)
        recordStackView.addArrangedSubview(mealItem)
        recordStackView.addArrangedSubview(memoItem)
        recordStackView.addArrangedSubview(photoItem)
        
        contentView.addSubview(shareView)
        
        view.addSubview(postButton)
        view.addSubview(bottomGradientView)
    }
    
    private func setupLayout() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        closeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(postButton.snp.top).offset(-16)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        // 기분 상태 영역
        moodContainerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(120)
        }
        
        moodImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(108)
        }
        
        changeMoodButton.snp.makeConstraints {
            $0.top.equalTo(moodImageView).offset(0)
            $0.trailing.equalTo(moodImageView).offset(0)
            $0.width.height.equalTo(32)
        }
        
        // 기록 항목 리스트
        recordStackView.snp.makeConstraints {
            $0.top.equalTo(moodContainerView.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        // 커뮤니티 공유 영역
        shareView.snp.makeConstraints {
            $0.top.equalTo(recordStackView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-80)
        }
        
        // 게시하기 버튼
        postButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(72)
        }
        
        bottomGradientView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(postButton.snp.top)
            $0.height.equalTo(40)
        }
    }
    
    private func setupActions() {
        // 기분 선택
        changeMoodButton.addTarget(self, action: #selector(didTapChangeMood), for: .touchUpInside)
        let moodTap = UITapGestureRecognizer(target: self, action: #selector(didTapChangeMood))
        moodImageView.isUserInteractionEnabled = true
        moodImageView.addGestureRecognizer(moodTap)
        
        // 특이증상
        symptomItem.onTap = { [weak self] in
            guard let self = self else { return }
            let vc = TextInputViewController(title: "어떤 특이증상이 있었나요?", placeholder: "특이증상을 적어주세요")
            vc.onComplete = { text in
                self.viewModel.updateSymptom(text)
            }
            self.present(vc, animated: true)
        }
        
        // 복약
        medicationItem.onTap = { [weak self] in
            guard let self = self else { return }
            let vc = MedicationPopupViewController()
            vc.onSelect = { status in
                self.viewModel.updateMedication(status)
            }
            self.present(vc, animated: true)
        }
        
        // 식이상태
        mealItem.onTap = { [weak self] in
            guard let self = self else { return }
            let vc = MealInputViewController(
                initialStatus: self.viewModel.recordModel.meal,
                initialDescription: self.viewModel.recordModel.mealDescription
            )
            vc.onComplete = { status, text in
                self.viewModel.updateMeal(status: status, description: text)
            }
            self.present(vc, animated: true)
        }
        
        // 메모
        memoItem.onTap = { [weak self] in
            guard let self = self else { return }
            let vc = TextInputViewController(title: "더 남기고싶은 이야기가 있나요?", placeholder: "추가로 남기고싶은 글을 자유롭게 적어주세요.")
            vc.onComplete = { text in
                self.viewModel.updateMemo(text)
            }
            self.present(vc, animated: true)
        }
        
        // 사진 추가
        photoItem.onTap = { [weak self] in
            self?.presentPhotoPicker()
        }
        
        photoItem.onDeletePhoto = { [weak self] index in
            self?.viewModel.removePhoto(at: index)
        }
        
        // 커뮤니티 공유
        shareView.onCheckChanged = { [weak self] isChecked in
            self?.viewModel.updatePublicStatus(isChecked)
        }
        
        // 게시하기
        postButton.addTarget(self, action: #selector(didTapPost), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        viewModel.$recordModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] model in
                self?.updateUI(with: model)
            }
            .store(in: &cancellables)
        
        viewModel.$isPostButtonEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: postButton)
            .store(in: &cancellables)
            
        viewModel.postSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.dismiss(animated: true) {
                    Toast.show(message: "치료기록 작성을 완료 하였습니다.")
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(with model: TreatmentRecordModel) {
        // Mood
        if let mood = model.mood, mood >= 1 && mood <= 5 {
            let moodImages = [
                "feeling-very-good",
                "feeling-good",
                "feeling-normal",
                "feeling-bad",
                "feeling-very-bad"
            ]
            moodImageView.image = UIImage(named: moodImages[mood - 1])
        } else {
            moodImageView.image = UIImage(named: "feeling-unselected")
        }
        
        // Symptom
        if let symptom = model.symptom, !symptom.isEmpty {
            symptomItem.updateContent(text: symptom)
        } else {
            symptomItem.reset()
        }
        
        // Medication
        if let medication = model.medication {
            let color = medication == .taken ? Colors.Lime.l400 : Colors.Red.r500
            let iconName = medication == .taken ? "checkmark.circle.fill" : "xmark.circle.fill"
            let icon = UIImage(systemName: iconName)?.withRenderingMode(.alwaysTemplate)
            medicationItem.updateStatus(icon: icon, text: medication.rawValue, iconColor: color, textColor: Colors.Slate.s900)
        } else {
            medicationItem.reset()
        }
        
        // Meal
        if let meal = model.meal {
            let iconName: String
            switch meal {
            case .good: iconName = "meal-good"
            case .little: iconName = "meal-small"
            case .bad: iconName = "meal-poor"
            }
            let icon = UIImage(named: iconName)
            mealItem.updateStatus(icon: icon, text: meal.rawValue, textColor: Colors.Slate.s900)
            mealItem.updateContent(text: model.mealDescription)
        } else {
            mealItem.reset()
        }
        
        // Memo
        if let memo = model.memo, !memo.isEmpty {
            memoItem.updateContent(text: memo)
        } else {
            memoItem.reset()
        }
        
        // Photos
        if !model.photos.isEmpty {
            photoItem.updatePhotos(images: model.photos)
        } else {
            photoItem.reset()
        }
    }
    
    // MARK: - Photo Picker
    
    private func presentPhotoPicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 5
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
    
    @objc private func didTapChangeMood() {
        let vc = MoodSelectionViewController()
        vc.onSelect = { [weak self] moodIndex in
            self?.viewModel.updateMood(moodIndex)
        }
        present(vc, animated: true)
    }
    
    @objc private func didTapPost() {
        viewModel.didTapPost.send()
    }
}

// MARK: - PHPickerViewControllerDelegate

extension TreatmentRecordViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        var selectedImages: [UIImage] = []
        let dispatchGroup = DispatchGroup()
        
        for result in results {
            dispatchGroup.enter()
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        selectedImages.append(image)
                    }
                    dispatchGroup.leave()
                }
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.viewModel.updatePhotos(selectedImages)
        }
    }
}
