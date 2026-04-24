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
    
    private let infoContainerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.Gray.g200.cgColor
    }
    
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
        contentView.addSubview(infoContainerView)
        infoContainerView.addSubview(infoStackView)
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
        
        infoContainerView.snp.makeConstraints {
            $0.top.equalTo(profileHeaderView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        infoStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
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
        
        profileHeaderView.onEditNicknameTapped = { [weak self] in
            self?.viewModel.didTapEditNickname.send()
        }
    }
    
    private func updateUI(with profile: UserProfile) {
        profileHeaderView.configure(nickname: profile.nickname)
        
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
    
    var onEditNicknameTapped: (() -> Void)?
    
    private let profileImageView = UIImageView().then {
        $0.backgroundColor = Colors.Gray.g200
        $0.layer.cornerRadius = 32
        $0.clipsToBounds = true
    }
    
    private let nicknameLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Heading.h3)
        $0.textColor = Colors.Gray.g950
    }
    
    private let editNicknameChip = UIButton().then {
        $0.backgroundColor = Colors.Gray.g100
        $0.layer.cornerRadius = 12
        
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "pencil")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        )
        config.title = "닉네임 변경"
        config.imagePadding = 3
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        config.baseForegroundColor = Colors.Gray.g500
        $0.configuration = config
        $0.titleLabel?.font = .ieum(UIFont.IeumFont.Text.bodySmall)
    }
    
    // TODO: 친구 기능 추후 추가 예정
//    private let friendCountLabel = UILabel().then {
//        $0.font = .ieum(UIFont.IeumFont.Text.bodySmall)
//        $0.textColor = Colors.Gray.g600
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(profileImageView)
        addSubview(nicknameLabel)
        addSubview(editNicknameChip)
    }
    
    private func setupLayout() {
        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(64)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(16)
            $0.top.equalTo(profileImageView).offset(10)
        }
        
        editNicknameChip.snp.makeConstraints {
            $0.leading.equalTo(nicknameLabel)
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(6)
        }
    }
    
    private func setupActions() {
        editNicknameChip.addTarget(self, action: #selector(didTapEditNickname), for: .touchUpInside)
    }
    
    @objc private func didTapEditNickname() {
        onEditNicknameTapped?()
    }
    
    func configure(nickname: String) {
        nicknameLabel.text = nickname
    }
}

final class ProfileInfoSectionView: UIView {
    
    var onInfoSectionTapped: (() -> Void)?
    
    private let titleLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g950
    }
    
    private let visibilityChip = UIView().then {
        $0.backgroundColor = Colors.Gray.g100
        $0.layer.cornerRadius = 12
        $0.isHidden = true
    }
    
    private let visibilityChipStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 3
        $0.alignment = .center
    }
    
    private let visibilityIcon = UIImageView().then {
        $0.image = UIImage(systemName: "lock.fill")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = Colors.Gray.g400
    }
    
    private let visibilityLabel = UILabel().then {
        $0.text = "비공개"
        $0.font = .ieum(UIFont.IeumFont.Text.bodySmall)
        $0.textColor = Colors.Gray.g400
    }
    
    private let arrowImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = Colors.Gray.g400
        $0.contentMode = .scaleAspectFit
    }
    
    private let chipFlowView = ChipFlowView()
    
    private let placeholderLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodySmall)
        $0.textColor = Colors.Gray.g400
        $0.numberOfLines = 0
        $0.isHidden = true
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
        addSubview(visibilityChip)
        visibilityChip.addSubview(visibilityChipStack)
        visibilityChipStack.addArrangedSubview(visibilityIcon)
        visibilityChipStack.addArrangedSubview(visibilityLabel)
        addSubview(arrowImageView)
        addSubview(chipFlowView)
        addSubview(placeholderLabel)
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
        
        visibilityChip.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(8)
        }
        
        visibilityChipStack.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.leading.trailing.equalToSuperview().inset(8)
        }
        
        visibilityIcon.snp.makeConstraints {
            $0.width.height.equalTo(12)
        }
        
        arrowImageView.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview()
            $0.width.height.equalTo(16)
        }
        
        chipFlowView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
        }
        
        placeholderLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
        }
        
        dividerView.snp.makeConstraints {
            $0.top.equalTo(chipFlowView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    func configure(content: String, isVisible: Bool, isPlaceholder: Bool) {
        if isPlaceholder || content.isEmpty {
            chipFlowView.isHidden = true
            placeholderLabel.isHidden = false
            placeholderLabel.text = content
            
            dividerView.snp.remakeConstraints {
                $0.top.equalTo(placeholderLabel.snp.bottom).offset(16)
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.height.equalTo(1)
            }
        } else {
            chipFlowView.isHidden = false
            placeholderLabel.isHidden = true
            let chips = content.components(separatedBy: "\n").flatMap {
                $0.components(separatedBy: "  ")
            }.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            chipFlowView.setChips(chips)
            
            dividerView.snp.remakeConstraints {
                $0.top.equalTo(chipFlowView.snp.bottom).offset(16)
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.height.equalTo(1)
            }
        }
        
        visibilityChip.isHidden = isVisible
    }
}

// MARK: - ChipFlowView

final class ChipFlowView: UIView {
    
    private let spacing: CGFloat = 8
    private let lineSpacing: CGFloat = 8
    
    private var chipLabels: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setChips(_ texts: [String]) {
        chipLabels.forEach { $0.removeFromSuperview() }
        chipLabels.removeAll()
        
        for text in texts {
            let chip = createChipView(text)
            addSubview(chip)
            chipLabels.append(chip)
        }
        
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }
    
    private func createChipView(_ text: String) -> UIView {
        let container = UIView().then {
            $0.backgroundColor = Colors.Slate.s100
            $0.layer.cornerRadius = 14
        }
        
        let label = UILabel().then {
            $0.text = text
            $0.font = .ieum(UIFont.IeumFont.Text.bodySmall)
            $0.textColor = Colors.Gray.g800
            $0.textAlignment = .center
        }
        
        container.addSubview(label)
        label.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(6)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        
        return container
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        let maxWidth = bounds.width
        
        for chip in chipLabels {
            chip.sizeToFit()
            let chipSize = chip.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            
            if currentX + chipSize.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += chipSize.height + lineSpacing
            }
            
            chip.frame = CGRect(x: currentX, y: currentY, width: chipSize.width, height: chipSize.height)
            currentX += chipSize.width + spacing
        }
        
        invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize {
        guard !chipLabels.isEmpty else { return CGSize(width: UIView.noIntrinsicMetric, height: 0) }
        
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        let maxWidth = bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width - 40
        var maxHeight: CGFloat = 0
        
        for chip in chipLabels {
            let chipSize = chip.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            
            if currentX + chipSize.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += chipSize.height + lineSpacing
            }
            
            maxHeight = max(maxHeight, currentY + chipSize.height)
            currentX += chipSize.width + spacing
        }
        
        return CGSize(width: UIView.noIntrinsicMetric, height: maxHeight)
    }
}
