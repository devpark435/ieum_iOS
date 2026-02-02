import UIKit
import SnapKit
import Then
import Combine

final class MyProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: MyPageViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = Colors.white
    }
    
    private let contentView = UIView()
    
    private let profileHeaderView = ProfileHeaderView()
    
    private let infoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
        $0.distribution = .fill
    }
    
    // MARK: - Initializer
    
    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.white
        setupUI()
        setupLayout()
        bindViewModel()
        
        viewModel.viewDidLoad.send()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(profileHeaderView)
        contentView.addSubview(infoStackView)
    }
    
    private func setupLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        profileHeaderView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(100) // Adjust as needed
        }
        
        infoStackView.snp.makeConstraints {
            $0.top.equalTo(profileHeaderView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
    
    private func bindViewModel() {
        viewModel.$userProfile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                guard let self = self, let profile = profile else { return }
                self.updateUI(with: profile)
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(with profile: UserProfile) {
        profileHeaderView.configure(nickname: profile.nickname, friendCount: 100) // Mock friend count
        
        infoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Diagnoses
        let diagnosesText = profile.diagnoses.map {
            "\($0.diagnosisDisplayName) : \($0.cancerStage ?? 0)기"
        }.joined(separator: "  ")
        addInfoSection(title: "진단명", content: diagnosesText, isVisible: profile.diagnosesVisible, sectionType: .diagnosis)
        
        // Surgery
        let surgeryContent = formatSurgeryHistory(profile.surgery)
        let surgeryIsPlaceholder = profile.surgery?.isEmpty ?? true
        addInfoSection(title: "수술 이력", content: surgeryContent, isVisible: profile.surgeryVisible, isPlaceholder: surgeryIsPlaceholder, sectionType: .surgery)
        
        // Chemotherapy
        let chemotherapyContent = formatChemotherapyHistory(profile.chemotherapy)
        let chemotherapyIsPlaceholder = profile.chemotherapy?.isEmpty ?? true
        addInfoSection(title: "항암 이력", content: chemotherapyContent, isVisible: profile.chemotherapyVisible, isPlaceholder: chemotherapyIsPlaceholder, sectionType: .chemotherapy)
        
        // Radiation
        let radiationContent = formatRadiationHistory(profile.radiationTherapy)
        let radiationIsPlaceholder = profile.radiationTherapy?.isEmpty ?? true
        addInfoSection(title: "방사선 이력", content: radiationContent, isVisible: profile.radiationTherapyVisible, isPlaceholder: radiationIsPlaceholder, sectionType: .radiation)
        
        // Age Group
        let ageGroupText = AgeGroup(rawValue: profile.ageGroup ?? "")?.title ?? ""
        addInfoSection(title: "연령대", content: ageGroupText, isVisible: profile.ageGroupVisible, sectionType: .ageGroup)
        
        // Region
        var regionText = ""
        if let residence = profile.residenceArea {
            regionText += "거주지 : \(residence)\n"
        }
        if let hospital = profile.hospitalArea {
            regionText += "이용중 병원 : \(hospital)"
        }
        addInfoSection(title: "지역", content: regionText, isVisible: profile.residenceAreaVisible || profile.hospitalAreaVisible, sectionType: .residence)
    }
    
    // MARK: - History Formatting
    
    private func formatSurgeryHistory(_ surgeries: [Surgery]?) -> String {
        guard let surgeries = surgeries, !surgeries.isEmpty else {
            return "수술 이력이 있다면 기록해 주세요"
        }
        
        return surgeries.map { surgery in
            "\(surgery.date): \(surgery.description)"
        }.joined(separator: "\n")
    }
    
    private func formatChemotherapyHistory(_ chemotherapies: [Chemotherapy]?) -> String {
        guard let chemotherapies = chemotherapies, !chemotherapies.isEmpty else {
            return "항암 이력이 있다면 기록해 주세요"
        }
        
        return chemotherapies.map { chemo in
            let endDateText = chemo.endDate ?? "진행중"
            return "\(chemo.cycle)차 (\(chemo.startDate) ~ \(endDateText))"
        }.joined(separator: "\n")
    }
    
    private func formatRadiationHistory(_ radiations: [RadiationTherapy]?) -> String {
        guard let radiations = radiations, !radiations.isEmpty else {
            return "방사선 이력이 있다면 기록해 주세요"
        }
        
        return radiations.map { radiation in
            let endDateText = radiation.endDate ?? "진행중"
            return "\(radiation.startDate) ~ \(endDateText)"
        }.joined(separator: "\n")
    }
    
    private func addInfoSection(title: String, content: String, isVisible: Bool, isPlaceholder: Bool = false, sectionType: InfoSectionType) {
        let sectionView = ProfileInfoSectionView(title: title)
        sectionView.configure(content: content, isVisible: isVisible, isPlaceholder: isPlaceholder)
        sectionView.onInfoSectionTapped = { [weak self] in
            self?.viewModel.didTapInfoSection.send(sectionType)
        }
        infoStackView.addArrangedSubview(sectionView)
    }
}

// MARK: - Components

final class ProfileHeaderView: UIView {
    
    private let profileImageView = UIImageView().then {
        $0.backgroundColor = Colors.Gray.g200
        $0.layer.cornerRadius = 32
        $0.clipsToBounds = true
    }
    
    private let nicknameLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Heading.h3)
        $0.textColor = Colors.Gray.g950
    }
    
    private let friendCountLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodySmall)
        $0.textColor = Colors.Gray.g600
    }
    
    private let editButton = UIButton().then {
        $0.setImage(UIImage(systemName: "pencil"), for: .normal)
        $0.tintColor = Colors.Gray.g950
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(profileImageView)
        addSubview(nicknameLabel)
        addSubview(friendCountLabel)
        addSubview(editButton)
    }
    
    private func setupLayout() {
        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(64)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(16)
            $0.top.equalTo(profileImageView).offset(8)
        }
        
        editButton.snp.makeConstraints {
            $0.leading.equalTo(nicknameLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(nicknameLabel)
            $0.width.height.equalTo(20)
        }
        
        friendCountLabel.snp.makeConstraints {
            $0.leading.equalTo(nicknameLabel)
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(4)
        }
    }
    
    func configure(nickname: String, friendCount: Int) {
        nicknameLabel.text = nickname
        friendCountLabel.text = "친구 \(friendCount) >"
    }
}

final class ProfileInfoSectionView: UIView {
    
    var onInfoSectionTapped: (() -> Void)?
    
    private let titleLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g950
    }
    
    private let visibilityBadge = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = Colors.Gray.g400
    }
    
    private let arrowImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = Colors.Gray.g400
        $0.contentMode = .scaleAspectFit
    }
    
    private let contentContainer = UIView().then {
        $0.backgroundColor = Colors.Slate.s100
        $0.layer.cornerRadius = 12
    }
    
    private let contentLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodySmall)
        $0.textColor = Colors.Gray.g800
        $0.numberOfLines = 0
    }
    
    private let dividerView = UIView().then {
        $0.backgroundColor = Colors.Gray.g200
    }
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupUI()
        setupLayout()
        setupTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(visibilityBadge)
        addSubview(arrowImageView)
        addSubview(contentContainer)
        contentContainer.addSubview(contentLabel)
        addSubview(dividerView)
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    @objc private func handleTap() {
        onInfoSectionTapped?()
    }
    
    private func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview()
        }
        
        visibilityBadge.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(8)
            $0.width.height.equalTo(16)
        }
        
        arrowImageView.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview()
            $0.width.height.equalTo(16)
        }
        
        contentContainer.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(dividerView.snp.top).offset(-16)
        }
        
        contentLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }
        
        dividerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    func configure(content: String, isVisible: Bool, isPlaceholder: Bool) {
        contentLabel.text = content
        contentLabel.textColor = isPlaceholder ? Colors.Gray.g400 : Colors.Gray.g800
        
        // 비공개면 닫힌 자물쇠, 공개면 숨김
        if isVisible {
            visibilityBadge.isHidden = true
        } else {
            visibilityBadge.isHidden = false
            visibilityBadge.image = UIImage(systemName: "lock.fill")
        }
    }
}
