import UIKit
import SnapKit
import Then

final class RecordItemView: UIView {
    
    // MARK: - Properties
    
    var onTap: (() -> Void)?
    var onDeletePhoto: ((Int) -> Void)?
    
    private var photos: [UIImage] = []
    private let maxPhotos = 5
    
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
    private lazy var photoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 88, height: 88)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.isHidden = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        collectionView.register(AddPhotoCollectionViewCell.self, forCellWithReuseIdentifier: AddPhotoCollectionViewCell.identifier)
        return collectionView
    }()
    
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
        mainStackView.addArrangedSubview(photoCollectionView)
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
        
        // Photo Collection View
        photoCollectionView.snp.makeConstraints {
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
        photoCollectionView.isHidden = true
        photos = []
        photoCollectionView.reloadData()
        
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
            // 내용만 숨기고 상태는 유지
            dividerView.isHidden = true
            contentLabel.isHidden = true
            contentLabel.text = nil
            // statusChipView와 plusButton은 그대로 유지 (updateStatus에서 이미 설정됨)
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
        photos = images
        
        if images.isEmpty {
            photoCollectionView.isHidden = true
            plusButton.isHidden = false
            photoCollectionView.reloadData()
            return
        }
        
        plusButton.isHidden = true
        subtitleContainerView.isHidden = true
        dividerView.isHidden = false
        photoCollectionView.isHidden = false
        photoCollectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension RecordItemView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let photoCount = photos.count
        // 사진 개수 + (5장 미만일 때 + 버튼 1개)
        return photoCount + (photoCount < maxPhotos ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photoCount = photos.count
        let isAddButtonCell = indexPath.item == photoCount && photoCount < maxPhotos
        
        if isAddButtonCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddPhotoCollectionViewCell.identifier, for: indexPath) as! AddPhotoCollectionViewCell
            return cell
        } else {
            guard indexPath.item < photos.count else {
                // 안전장치: 인덱스 범위를 벗어나면 빈 셀 반환
                return UICollectionViewCell()
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as! PhotoCollectionViewCell
            let image = photos[indexPath.item]
            cell.configure(image: image)
            
            cell.onDelete = { [weak self] in
                self?.onDeletePhoto?(indexPath.item)
            }
            
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate

extension RecordItemView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoCount = photos.count
        let isAddButtonCell = indexPath.item == photoCount && photoCount < maxPhotos
        
        if isAddButtonCell {
            onTap?()
        }
    }
}
