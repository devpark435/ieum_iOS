import UIKit
import SnapKit
import Then

final class MoodSelectionViewController: DimmedViewController {
    
    // MARK: - Properties
    
    var onSelect: ((Int) -> Void)?
    private var currentIndex: Int = 2 // 기본값: 2 (평범해요)
    
    private let moodImages = [
        "feeling-very-good",
        "feeling-good",
        "feeling-normal",
        "feeling-bad",
        "feeling-very-bad"
    ]
    
    private let moodTexts = [
        "행복해요",
        "좋아요",
        "평범해요",
        "별로에요",
        "최악이에요"
    ]
    
    private let moodColors = [
        UIColor(hex: "#FDC700"),
        UIColor(hex: "#9AE600"),
        UIColor(hex: "#00D5BE"),
        UIColor(hex: "#00D3F3"),
        UIColor(hex: "#51A2FF")
    ]
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "지금 기분은 어떤가요?"
        $0.font = .ieum(UIFont.IeumFont.Heading.h2)
        $0.textColor = Colors.Gray.g950
        $0.textAlignment = .left
    }
    
    // Carousel Area
    private let carouselContainer = UIView()
    
    private lazy var collectionView: UICollectionView = {
        let layout = CarouselFlowLayout()
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.decelerationRate = .fast // 스냅 효과를 위해 빠르게 감속
        cv.register(MoodImageCell.self, forCellWithReuseIdentifier: MoodImageCell.identifier)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    private let leftArrowButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        let image = UIImage(systemName: "chevron.left.circle.fill", withConfiguration: config)
        $0.setImage(image, for: .normal)
        $0.tintColor = Colors.Gray.g400
    }
    
    private let rightArrowButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        let image = UIImage(systemName: "chevron.right.circle.fill", withConfiguration: config)
        $0.setImage(image, for: .normal)
        $0.tintColor = Colors.Gray.g400
    }
    
    private let moodLabelContainer = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.Gray.g200.cgColor
    }
    
    private let moodLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g950
        $0.textAlignment = .center
    }
    
    private let selectButton = IeumButton(title: "선택완료").then {
        $0.titleLabel?.font = .ieum(UIFont.IeumFont.Btn.large)
        $0.backgroundColor = Colors.Treatment.buttonBackground
        $0.layer.borderColor = Colors.Treatment.buttonBorder.cgColor
        $0.layer.borderWidth = 1
    }
    
    // MARK: - Initializer
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupActions()
        updateMoodDisplay()
        
        // 초기 위치로 스크롤 (레이아웃 완료 후 실행되어야 정확함)
        DispatchQueue.main.async {
            self.scrollToIndex(self.currentIndex, animated: false)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 중앙 정렬을 위한 Inset 설정 (CarouselFlowLayout에서 처리하므로 여기서는 제거 가능하지만, 안전을 위해 유지)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            // CarouselFlowLayout.prepare()에서 처리됨
        }
        
        applyGradientMask()
    }
    
    private func applyGradientMask() {
        // 기존 마스크 제거 (업데이트를 위해)
        carouselContainer.layer.mask = nil
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = carouselContainer.bounds
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.cgColor,
            UIColor.black.cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 0.2, 0.8, 1.0] // 양쪽 20% 페이드아웃
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        carouselContainer.layer.mask = gradientLayer
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(carouselContainer)
        carouselContainer.addSubview(collectionView)
        carouselContainer.addSubview(leftArrowButton)
        carouselContainer.addSubview(rightArrowButton)
        
        containerView.addSubview(moodLabelContainer)
        moodLabelContainer.addSubview(moodLabel)
        containerView.addSubview(selectButton)
    }
    
    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(431)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
        }
        
        carouselContainer.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(140)
        }
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        leftArrowButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(32)
        }
        
        rightArrowButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(32)
        }
        
        moodLabelContainer.snp.makeConstraints {
            $0.top.equalTo(carouselContainer.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(36)
        }
        
        moodLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.trailing.equalToSuperview().inset(14)
        }
        
        selectButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(32)
            $0.height.equalTo(72)
        }
    }
    
    private func setupActions() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        // DimmedViewController의 view에 제스처 추가 (블러/딤 영역 탭 시 닫기)
        view.addGestureRecognizer(tap)
        
        leftArrowButton.addTarget(self, action: #selector(didTapLeft), for: .touchUpInside)
        rightArrowButton.addTarget(self, action: #selector(didTapRight), for: .touchUpInside)
        selectButton.addTarget(self, action: #selector(didTapSelect), for: .touchUpInside)
    }
    
    private func updateMoodDisplay() {
        moodLabel.text = moodTexts[currentIndex]
        
        let color = moodColors[currentIndex]
        moodLabelContainer.backgroundColor = color.withAlphaComponent(0.2)
        moodLabelContainer.layer.borderColor = color.withAlphaComponent(0.5).cgColor
        
        leftArrowButton.isEnabled = currentIndex > 0
        leftArrowButton.alpha = currentIndex > 0 ? 1.0 : 0.3
        
        rightArrowButton.isEnabled = currentIndex < moodImages.count - 1
        rightArrowButton.alpha = currentIndex < moodImages.count - 1 ? 1.0 : 0.3
        
        // CollectionView 갱신하여 셀 스타일(투명도 등) 업데이트
        collectionView.reloadData()
    }
    
    private func scrollToIndex(_ index: Int, animated: Bool) {
        guard index >= 0 && index < moodImages.count else { return }
        let indexPath = IndexPath(item: index, section: 0)
        // 화면 중앙에 오도록 스크롤
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }
    
    // MARK: - Actions
    
    @objc private func didTapLeft() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        updateMoodDisplay()
        scrollToIndex(currentIndex, animated: true)
    }
    
    @objc private func didTapRight() {
        guard currentIndex < moodImages.count - 1 else { return }
        currentIndex += 1
        updateMoodDisplay()
        scrollToIndex(currentIndex, animated: true)
    }
    
    @objc private func didTapSelect() {
        onSelect?(currentIndex + 1)
        dismiss(animated: true)
    }
    
    @objc private func didTapBackground() {
        dismiss(animated: true)
    }
}

// MARK: - UICollectionView Delegate & DataSource

extension MoodSelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moodImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoodImageCell.identifier, for: indexPath) as? MoodImageCell else {
            return UICollectionViewCell()
        }
        
        let isSelected = indexPath.item == currentIndex
        cell.configure(imageName: moodImages[indexPath.item], isSelected: isSelected)
        return cell
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // CarouselFlowLayout에서 targetContentOffset 로직을 처리하므로, 여기서는 인덱스 업데이트만 수행
        // 하지만 스크롤이 끝날 때 정확한 인덱스를 알기 위해 계산 로직은 필요
        
        let layout = collectionView.collectionViewLayout as! CarouselFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        // 인덱스 업데이트
        let newIndex = Int(roundedIndex)
        if newIndex != currentIndex && newIndex >= 0 && newIndex < moodImages.count {
            currentIndex = newIndex
            updateMoodDisplay()
        }
    }
    
    // 스크롤이 완전히 멈췄을 때도 인덱스 확인 (화살표 이동 등의 경우)
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // scrollToIndex 호출 후 실행됨
        // 필요한 경우 추가 로직
    }
}
