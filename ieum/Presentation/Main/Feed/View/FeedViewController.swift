import UIKit
import SnapKit
import Then
import Combine

final class FeedViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = FeedViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.text = "피드"
        $0.font = .ieum(UIFont.IeumFont.Heading.h1)
        $0.textColor = Colors.Gray.g950
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.ieumBackground
        
        setupNavigationBar()
        setupUI()
        setupLayout()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        // 네비게이션 바 표시
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        // 왼쪽: 앱 로고 (표시용, 클릭 불가)
        let logoImageView = UIImageView(image: Images.Icon.appbarLogo).then {
            $0.contentMode = .scaleAspectFit
        }
        // iOS 네비게이션 바 구조상 leftBarButtonItem을 사용하지만, customView는 버튼처럼 동작하지 않음
        let logoItem = UIBarButtonItem(customView: logoImageView)
        navigationItem.leftBarButtonItem = logoItem
        
        // 오른쪽: 알림 아이콘
        let notificationButton = UIBarButtonItem(
            image: Images.Icon.notification,
            style: .plain,
            target: self,
            action: #selector(didTapNotification)
        ).then {
            $0.tintColor = Colors.Gray.g950
        }
        navigationItem.rightBarButtonItem = notificationButton
        
        // 네비게이션 바 스타일 설정
        navigationController?.navigationBar.backgroundColor = Colors.white
        navigationController?.navigationBar.isTranslucent = false
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
    }
    
    private func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.leading.equalToSuperview().offset(24)
        }
    }
    
    private func bindViewModel() {
        // TODO: ViewModel 바인딩
    }
    
    // MARK: - Actions
    
    @objc private func didTapNotification() {
        // TODO: 알림 리스트 화면으로 이동
        print("알림 아이콘 탭")
    }
}

