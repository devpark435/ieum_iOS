import UIKit
import SnapKit
import Then
import Combine

class SplashViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: SplashCoordinator?
    private let viewModel = SplashViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let logoImageView = UIImageView().then {
        $0.image = UIImage(named: "launch-icon") // Asset 이름
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "ieum"
        $0.font = .systemFont(ofSize: 48, weight: .regular) // Pretendard 적용 시 .ieum(...) 사용
        // 아직 Font Extension에 48 사이즈가 없다면 임시로 systemFont 사용하거나 추가 필요
        // $0.font = .ieum(UIFont.IeumFont.Heading.h1) // 예시
        $0.textColor = Colors.Gray.g950
        $0.textAlignment = .center
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.white
        
        setupUI()
        setupLayout()
        bindViewModel()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
    }
    
    private func setupLayout() {
        logoImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(100) // 로고 크기 조절 필요 시 수정
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        viewModel.navigateToLogin
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.coordinator?.finish()
            }
            .store(in: &cancellables)
    }
}

