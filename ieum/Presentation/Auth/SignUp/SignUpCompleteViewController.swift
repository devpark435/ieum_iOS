import UIKit
import SnapKit
import Then

class SignUpCompleteViewController: UIViewController {
    
    // MARK: - UI Components
    
    // 상단 영역 컨테이너 (하단 버튼 제외한 영역)
    private let topContainerView = UIView()
    
    // 중앙 컨텐츠를 담을 스택뷰
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 24
        $0.alignment = .center
        $0.distribution = .fill
    }
    
    private let checkIconImageView = UIImageView().then {
        $0.image = Images.Icon.checkCircle
        $0.tintColor = Colors.Lime.l500 // 라임색 체크
        $0.contentMode = .scaleAspectFit
        // 폰트 설정으로 아이콘 크기 조절 (Symbol Configuration)
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .regular)
        $0.preferredSymbolConfiguration = config
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "회원가입이 완료되었어요!"
        $0.font = .ieum(UIFont.IeumFont.Heading.h2)
        $0.textColor = Colors.Gray.g950
        $0.textAlignment = .center
    }
    
    private let descriptionLabel = UILabel().then {
        $0.text = "당신의 기록은 누군가의 공감이 되고,\n다른 이의 하루는 당신에게 힘이 될 거예요.\n이제, 서로의 이야기를 나눠볼까요?"
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g600
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.setIeumText($0.text, style: UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g600
    }
    
    // 하단 버튼들
    private let startButton = IeumButton(title: "시작하기").then {
        $0.setStyle(backgroundColor: Colors.Slate.s900, titleColor: Colors.white, for: .normal)
    }
    
    private let detailInfoButton = IeumButton(title: "상세 정보 입력하기").then {
        $0.setStyle(backgroundColor: Colors.Slate.s900, titleColor: Colors.white, for: .normal)
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.ieumBackground // 배경색 변경
        
        setupUI()
        setupLayout()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 완료 화면에서는 네비게이션 바/뒤로가기 숨김 (새로운 시작)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(topContainerView)
        topContainerView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(checkIconImageView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
        
        // 간격 조정: 타이틀과 설명 사이 간격 줄이기 (Custom Spacing)
        contentStackView.setCustomSpacing(16, after: titleLabel)
        
        view.addSubview(startButton)
        view.addSubview(detailInfoButton)
    }
    
    private func setupLayout() {
        // 하단 버튼들 (먼저 배치하여 기준점 잡기)
        detailInfoButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(72)
        }
        
        startButton.snp.makeConstraints {
            $0.bottom.equalTo(detailInfoButton.snp.top).offset(-12)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(72)
        }
        
        // 상단 컨테이너 (화면 상단 ~ 버튼 위)
        topContainerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(startButton.snp.top)
        }
        
        // 중앙 스택뷰 (상단 컨테이너의 정중앙)
        contentStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
        }
    }
    
    private func setupActions() {
        startButton.addTarget(self, action: #selector(didTapStart), for: .touchUpInside)
        detailInfoButton.addTarget(self, action: #selector(didTapDetailInfo), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func didTapStart() {
        // 메인 화면으로 이동 (루트 교체)
        transitionToMain()
    }
    
    @objc private func didTapDetailInfo() {
        // 상세 정보 입력 화면으로 이동 (아직 미구현, 일단 메인으로)
        print("상세 정보 입력하기 탭")
        transitionToMain()
    }
    
    private func transitionToMain() {
        // 임시로 뷰 컨트롤러 생성 (추후 MainTabBarController 등으로 교체)
        let mainVC = ViewController()
        
        if let windowScene = view.window?.windowScene,
           let delegate = windowScene.delegate as? SceneDelegate,
           let window = delegate.window {
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = mainVC
            }, completion: nil)
        }
    }
}
