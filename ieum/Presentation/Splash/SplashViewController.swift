import UIKit
import SnapKit
import Then

class SplashViewController: UIViewController {
    
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
        
        // 2초 뒤 로그인 화면으로 이동
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.transitionToLogin()
        }
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
    
    // MARK: - Navigation
    
    private func transitionToLogin() {
        // UIWindow의 rootViewController를 교체하여 전환 (뒤로가기 불가하게)
        guard let windowScene = view.window?.windowScene,
              let delegate = windowScene.delegate as? SceneDelegate,
              let window = delegate.window else { return }
        
        let loginVC = LoginViewController()
        
        // 부드러운 전환 애니메이션
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = loginVC
        }, completion: nil)
    }
}

