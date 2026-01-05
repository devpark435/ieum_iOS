import UIKit
import SnapKit
import Then

final class MoodSelectionViewController: UIViewController {
    
    // MARK: - Properties
    
    var onSelect: ((Int) -> Void)?
    private var currentIndex: Int = 2 // 기본값: 3 (Index 2) - 평범해요
    
    private let moodImages = [
        "feeling-very-bad",
        "feeling-bad",
        "feeling-normal",
        "feeling-good",
        "feeling-very-good"
    ]
    
    private let moodTexts = [
        "매우 나쁨",
        "나쁨",
        "평범해요",
        "좋음",
        "매우 좋음"
    ]
    
    private let moodColors = [
        Colors.Blue.b100,
        Colors.Blue.b200,
        Colors.Emerald.e600,
        Colors.Lime.l400,
        Colors.Orange.o400
    ]
    
    // MARK: - UI Components
    
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark)).then {
        $0.alpha = 0.4
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "지금 기분은 어떤가요?"
        $0.font = .ieum(UIFont.IeumFont.Heading.h4)
        $0.textColor = Colors.Gray.g950
        $0.textAlignment = .center
    }
    
    // Carousel Area
    private let carouselContainer = UIView()
    
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
    
    private let mainMoodImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.shadowColor = Colors.black.cgColor
        $0.layer.shadowOpacity = 0.1
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowRadius = 8
    }
    
    private let prevMoodImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.alpha = 0.3
    }
    
    private let nextMoodImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.alpha = 0.3
    }
    
    private let moodLabelContainer = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.Emerald.e600.cgColor
    }
    
    private let moodLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g950
        $0.textAlignment = .center
    }
    
    private let selectButton = IeumButton(title: "선택완료").then {
        $0.titleLabel?.font = .ieum(UIFont.IeumFont.Btn.large)
    }
    
    // MARK: - Initializer
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
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
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(blurEffectView)
        view.addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(carouselContainer)
        containerView.addSubview(moodLabelContainer)
        moodLabelContainer.addSubview(moodLabel)
        containerView.addSubview(selectButton)
        
        carouselContainer.addSubview(prevMoodImageView)
        carouselContainer.addSubview(nextMoodImageView)
        carouselContainer.addSubview(mainMoodImageView)
        carouselContainer.addSubview(leftArrowButton)
        carouselContainer.addSubview(rightArrowButton)
    }
    
    private func setupLayout() {
        blurEffectView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(36) // 좌우 여백
            // height automatic
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.centerX.equalToSuperview()
        }
        
        carouselContainer.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(120) // 이미지 크기에 맞춰 조정
        }
        
        // Main Image
        mainMoodImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(100)
        }
        
        // Arrows
        leftArrowButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        rightArrowButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        // Side Images
        prevMoodImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(mainMoodImageView.snp.leading).offset(-20)
            $0.width.height.equalTo(60)
        }
        
        nextMoodImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(mainMoodImageView.snp.trailing).offset(20)
            $0.width.height.equalTo(60)
        }
        
        // Label
        moodLabelContainer.snp.makeConstraints {
            $0.top.equalTo(carouselContainer.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(32)
            $0.width.greaterThanOrEqualTo(80)
        }
        
        moodLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        // Button
        selectButton.snp.makeConstraints {
            $0.top.equalTo(moodLabelContainer.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(24)
            $0.height.equalTo(72)
        }
    }
    
    private func setupActions() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        blurEffectView.addGestureRecognizer(tap)
        
        leftArrowButton.addTarget(self, action: #selector(didTapLeft), for: .touchUpInside)
        rightArrowButton.addTarget(self, action: #selector(didTapRight), for: .touchUpInside)
        selectButton.addTarget(self, action: #selector(didTapSelect), for: .touchUpInside)
    }
    
    private func updateMoodDisplay() {
        mainMoodImageView.image = UIImage(named: moodImages[currentIndex])
        moodLabel.text = moodTexts[currentIndex]
        
        // Update Label Border Color (임시로 에메랄드 사용, 기분별 색상 있다면 적용)
        // moodLabelContainer.layer.borderColor = moodColors[currentIndex].cgColor 
        
        // Side Images
        if currentIndex > 0 {
            prevMoodImageView.image = UIImage(named: moodImages[currentIndex - 1])
            prevMoodImageView.isHidden = false
            leftArrowButton.isEnabled = true
            leftArrowButton.alpha = 1.0
        } else {
            prevMoodImageView.isHidden = true
            leftArrowButton.isEnabled = false
            leftArrowButton.alpha = 0.3
        }
        
        if currentIndex < moodImages.count - 1 {
            nextMoodImageView.image = UIImage(named: moodImages[currentIndex + 1])
            nextMoodImageView.isHidden = false
            rightArrowButton.isEnabled = true
            rightArrowButton.alpha = 1.0
        } else {
            nextMoodImageView.isHidden = true
            rightArrowButton.isEnabled = false
            rightArrowButton.alpha = 0.3
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapLeft() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        updateMoodDisplay()
    }
    
    @objc private func didTapRight() {
        guard currentIndex < moodImages.count - 1 else { return }
        currentIndex += 1
        updateMoodDisplay()
    }
    
    @objc private func didTapSelect() {
        // API 값은 1~5이므로 index + 1
        onSelect?(currentIndex + 1)
        dismiss(animated: true)
    }
    
    @objc private func didTapBackground() {
        dismiss(animated: true)
    }
}

