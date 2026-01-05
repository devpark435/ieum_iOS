import UIKit
import SnapKit
import Then

final class RecordItemView: UIView {
    
    // MARK: - Properties
    
    var onTap: (() -> Void)?
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.Slate.s200.cgColor
    }
    
    private let mainStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
        $0.alignment = .fill
        $0.distribution = .fill
    }
    
    // MARK: Header Area
    private let headerView = UIView()
    
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
    
    private let statusBadgeView = UIView().then {
        $0.isHidden = true
    }
    
    private let statusIconView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let statusLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyXSmall)
    }
    
    private let subtitleLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyXSmall)
        $0.textColor = Colors.Slate.s500
        $0.numberOfLines = 0
    }
    
    // MARK: Content Area (Text)
    private let contentTextContainer = UIView().then {
        $0.backgroundColor = Colors.Gray.g50
        $0.layer.cornerRadius = 8
        $0.isHidden = true
    }
    
    private let contentLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodySmall)
        $0.textColor = Colors.Gray.g800
        $0.numberOfLines = 0
    }
    
    // MARK: Content Area (Photos)
    private let photoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.isHidden = true
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
        
        // Header
        mainStackView.addArrangedSubview(headerView)
        headerView.addSubview(iconImageView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(rightActionContainer)
        headerView.addSubview(subtitleLabel)
        
        rightActionContainer.addArrangedSubview(statusBadgeView)
        rightActionContainer.addArrangedSubview(plusButton)
        
        // Content (Text)
        mainStackView.addArrangedSubview(contentTextContainer)
        contentTextContainer.addSubview(contentLabel)
        
        // Content (Photos)
        mainStackView.addArrangedSubview(photoStackView)
    }
    
    private func setupStatusBadge() {
        statusBadgeView.addSubview(statusIconView)
        statusBadgeView.addSubview(statusLabel)
        
        statusIconView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(16)
        }
        
        statusLabel.snp.makeConstraints {
            $0.leading.equalTo(statusIconView.snp.trailing).offset(4)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        mainStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 18, bottom: 16, right: 18))
        }
        
        // Header Layout
        iconImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(iconImageView)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(4)
        }
        
        rightActionContainer.snp.makeConstraints {
            $0.centerY.equalTo(iconImageView)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        plusButton.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(8)
            $0.leading.equalTo(titleLabel)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview() // HeaderView bottom
        }
        
        // Content Text Layout
        contentLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }
        
        // Photo Stack View Height (Images will determine width)
        photoStackView.snp.makeConstraints {
            $0.height.equalTo(64)
        }
    }
    
    // MARK: - Public Config Methods
    
    func reset() {
        plusButton.isHidden = false
        statusBadgeView.isHidden = true
        contentTextContainer.isHidden = true
        photoStackView.isHidden = true
        photoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        subtitleLabel.isHidden = false
    }
    
    func updateContent(text: String?) {
        if let text = text, !text.isEmpty {
            contentTextContainer.isHidden = false
            contentLabel.text = text
            // 텍스트가 있으면 서브타이틀을 숨길지 여부는 디자인에 따라 결정 (여기서는 유지)
        } else {
            contentTextContainer.isHidden = true
        }
    }
    
    func updateStatus(icon: UIImage?, text: String, color: UIColor) {
        plusButton.isHidden = true
        statusBadgeView.isHidden = false
        
        statusIconView.image = icon
        statusIconView.tintColor = color
        
        statusLabel.text = text
        statusLabel.textColor = color
    }
    
    func updatePhotos(images: [UIImage]) {
        photoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if images.isEmpty {
            photoStackView.isHidden = true
            return
        }
        
        photoStackView.isHidden = false
        images.forEach { image in
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 8
            imageView.snp.makeConstraints {
                $0.width.height.equalTo(64)
            }
            photoStackView.addArrangedSubview(imageView)
        }
        // Spacer to align left
        let spacer = UIView()
        photoStackView.addArrangedSubview(spacer)
    }
}
