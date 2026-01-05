import UIKit
import SnapKit
import Then

final class RecordItemView: UIView {
    
    // MARK: - Properties
    
    var onTap: (() -> Void)?
    var onDeletePhoto: ((Int) -> Void)?
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.Slate.s200.cgColor
    }
    
    // 전체 컨텐츠를 담는 메인 스택 (헤더 그룹 / 디바이더 / 내용)
    private let mainStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
        $0.alignment = .fill
        $0.distribution = .fill
    }
    
    // MARK: Header Group (Icon+Title 줄과 Subtitle 줄을 묶음, 간격 2)
    private let headerGroupStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 2
        $0.alignment = .fill
        $0.distribution = .fill
    }
    
    // 1. 첫 번째 줄: 아이콘, 타이틀, 액션 버튼
    private let topRowView = UIView()
    
    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Slate.s900
    }
    
    private let rightActionContainer = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
    }
    
    let plusButton = UIButton().then {
        $0.setImage(UIImage(named: "circleplus-icon"), for: .normal)
    }
    
    private let statusChipView = UIView().then {
        $0.isHidden = true
        $0.backgroundColor = Colors.Slate.s50
        $0.layer.cornerRadius = 16
    }
    
    private let statusContentStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
    }
    
    private let statusIconView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let statusLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodySmall)
    }
    
    // 2. 두 번째 줄: 서브타이틀 (들여쓰기 적용을 위한 컨테이너 사용)
    private let subtitleContainerView = UIView()
    
    private let subtitleLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyXSmall)
        $0.textColor = Colors.Slate.s500
        $0.numberOfLines = 0
    }
    
    // MARK: Divider
    private let dividerView = UIView().then {
        $0.backgroundColor = Colors.Slate.s200
        $0.isHidden = true
    }
    
    // MARK: Content Area (Text)
    private let contentLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyXSmall)
        $0.textColor = Colors.Slate.s500
        $0.numberOfLines = 0
        $0.isHidden = true
    }
    
    // MARK: Content Area (Photos)
    private let photoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.isHidden = true
        $0.alignment = .leading
    }
    
    // MARK: - Initializer
    
    init(iconName: String, title: String, subtitle: String) {
        super.init(frame: .zero)
        iconImageView.image = UIImage(named: iconName)
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        setupUI()
        setupLayout()
        setupStatusBadge()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupActions() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        containerView.addGestureRecognizer(tap)
        plusButton.addTarget(self, action: #selector(didTapView), for: .touchUpInside)
    }
    
    @objc private func didTapView() {
        onTap?()
    }
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(mainStackView)
        
        // Header Group에 TopRow와 Subtitle 추가
        mainStackView.addArrangedSubview(headerGroupStackView)
        headerGroupStackView.addArrangedSubview(topRowView)
        headerGroupStackView.addArrangedSubview(subtitleContainerView)
        
        // Top Row 구성
        topRowView.addSubview(iconImageView)
        topRowView.addSubview(titleLabel)
        topRowView.addSubview(rightActionContainer)
        
        rightActionContainer.addArrangedSubview(statusChipView)
        rightActionContainer.addArrangedSubview(plusButton)
        
        // Subtitle 구성
        subtitleContainerView.addSubview(subtitleLabel)
        
        // Divider
        mainStackView.addArrangedSubview(dividerView)
        
        // Content (Text)
        mainStackView.addArrangedSubview(contentLabel)
        
        // Content (Photos)
        mainStackView.addArrangedSubview(photoStackView)
    }
    
    private func setupStatusBadge() {
        statusChipView.addSubview(statusContentStack)
        statusContentStack.addArrangedSubview(statusIconView)
        statusContentStack.addArrangedSubview(statusLabel)
        
        statusContentStack.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(10)
            $0.leading.trailing.equalToSuperview().inset(14)
        }
        
        statusIconView.snp.makeConstraints {
            $0.width.height.equalTo(16)
        }
    }
    
    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        mainStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 18, bottom: 16, right: 18))
        }
        
        // Top Row Layout
        iconImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.bottom.equalToSuperview() // 높이 결정
            $0.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(iconImageView)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(4)
        }
        
        rightActionContainer.snp.makeConstraints {
            $0.centerY.equalTo(iconImageView)
            $0.trailing.equalToSuperview()
        }
        
        plusButton.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
        
        // Subtitle Layout (들여쓰기: 아이콘 24 + 간격 4 = 28)
        subtitleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(28)
            $0.trailing.equalToSuperview()
        }
        
        dividerView.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        
        // Photo Stack View Height
        photoStackView.snp.makeConstraints {
            $0.height.equalTo(88)
        }
    }
    
    // MARK: - Public Config Methods
    
    func reset() {
        plusButton.isHidden = false
        statusChipView.isHidden = true
        dividerView.isHidden = true
        contentLabel.isHidden = true
        contentLabel.text = nil
        photoStackView.isHidden = true
        photoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 서브타이틀 표시
        subtitleContainerView.isHidden = false
    }
    
    func updateContent(text: String?) {
        if let text = text, !text.isEmpty {
            dividerView.isHidden = false
            contentLabel.isHidden = false
            contentLabel.text = text
            
            // 입력 시 Subtitle 영역 숨김 (StackView가 공간 제거)
            subtitleContainerView.isHidden = true
            plusButton.isHidden = true
        } else {
            reset()
        }
    }
    
    func updateStatus(icon: UIImage?, text: String, iconColor: UIColor? = nil, textColor: UIColor = Colors.Slate.s900) {
        plusButton.isHidden = true
        statusChipView.isHidden = false
        subtitleContainerView.isHidden = true 
        
        statusIconView.image = icon
        if let iconColor = iconColor {
            statusIconView.tintColor = iconColor
        }
        
        statusLabel.text = text
        statusLabel.textColor = textColor
        
        statusChipView.backgroundColor = Colors.white
    }
    
    func updatePhotos(images: [UIImage]) {
        photoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if images.isEmpty {
            photoStackView.isHidden = true
            return
        }
        
        plusButton.isHidden = true
        subtitleContainerView.isHidden = true
        dividerView.isHidden = false
        
        photoStackView.isHidden = false
        images.enumerated().forEach { index, image in
            // 썸네일 컨테이너
            let container = UIView()
            container.snp.makeConstraints {
                $0.width.height.equalTo(88)
            }
            
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 8
            
            container.addSubview(imageView)
            imageView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            
            // 삭제 버튼 (X)
            let deleteBtn = UIButton()
            deleteBtn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            deleteBtn.tintColor = Colors.Gray.g600
            deleteBtn.backgroundColor = Colors.white
            deleteBtn.layer.cornerRadius = 10
            deleteBtn.tag = index // 인덱스 저장
            deleteBtn.addTarget(self, action: #selector(didTapDeletePhoto(_:)), for: .touchUpInside)
            
            container.addSubview(deleteBtn)
            deleteBtn.snp.makeConstraints {
                $0.top.trailing.equalToSuperview().inset(4)
                $0.width.height.equalTo(20)
            }
            
            photoStackView.addArrangedSubview(container)
        }
        
        // Spacer
        let spacer = UIView()
        photoStackView.addArrangedSubview(spacer)
    }
    
    @objc private func didTapDeletePhoto(_ sender: UIButton) {
        onDeletePhoto?(sender.tag)
    }
}
