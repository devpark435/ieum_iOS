import UIKit
import SnapKit
import Then
import Combine

final class TreatmentRecordViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = TreatmentRecordViewModel()
    private var cancellables = Set<AnyCancellable>()
    weak var coordinator: AppCoordinator?
    
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
        subtitle: "최대 3장까지 가능합니다."
    )
    
    // 커뮤니티 공유 영역
    private let shareView = RecordShareView()
    
    // 게시하기 버튼
    private let postButton = IeumButton(title: "게시하기").then {
        $0.isEnabled = false // 초기 비활성
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.Slate.s100
        
        setupUI()
        setupLayout()
        bindViewModel()
        
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
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
            $0.width.height.equalTo(100)
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
            $0.bottom.equalToSuperview().offset(-80) // 스크롤 뷰 bottom 마진 (버튼 높이 고려)
        }
        
        // 게시하기 버튼 (하단 고정)
        postButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(56)
        }
        
        bottomGradientView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(postButton.snp.top)
            $0.height.equalTo(40)
        }
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
    
    private func bindViewModel() {
        // TODO: ViewModel Binding
    }
    
    // MARK: - Actions
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
}

