import UIKit
import SnapKit
import Then
import Combine
import AuthenticationServices

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: AuthCoordinator?
    private let viewModel = LoginViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let logoImageView = UIImageView().then {
        $0.image = Images.Icon.appbarLogo
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "암을 함께 겪는 이들의 하루,\n서로의 이야기가\n서로의 힘이 됩니다."
        $0.font = .ieum(UIFont.IeumFont.Heading.h1)
        $0.textColor = Colors.Slate.s950
        $0.numberOfLines = 0
        $0.setIeumText($0.text, style: UIFont.IeumFont.Heading.h2)
    }
    
    private let backgroundImageView = UIImageView().then {
        $0.image = Images.Background.login
        $0.contentMode = .scaleAspectFill
    }
    
    private let kakaoLoginButton = IeumButton(title: "카카오톡으로 계속하기").then {
        $0.setStyle(backgroundColor: Colors.Slate.s900, titleColor: Colors.white, for: .normal)
        $0.titleLabel?.font = .ieum(UIFont.IeumFont.Btn.large)
    }
    
    private let appleLoginButton = ASAuthorizationAppleIDButton(type: .continue, style: .black).then {
        $0.layer.cornerRadius = 16
        $0.layer.masksToBounds = true
    }
    
    // 버튼들을 담을 스택뷰
    private let buttonStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
        $0.distribution = .fillEqually
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.white
        
        setupUI()
        setupLayout()
        setupActions()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // 배경 이미지를 가장 뒤로
        view.addSubview(backgroundImageView)
        
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        
        buttonStackView.addArrangedSubview(appleLoginButton)
        buttonStackView.addArrangedSubview(kakaoLoginButton)
        view.addSubview(buttonStackView)
    }
    
    private func setupLayout() {
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.leading.equalToSuperview().offset(24)
            $0.width.height.equalTo(49)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
        }
        
        // 배경 도형 위치 (우측 중앙~하단)
        backgroundImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(49)
            $0.top.equalTo(titleLabel.snp.bottom).offset(130)
            $0.width.height.equalTo(400)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
        
        // 버튼 높이 설정 (IeumButton 높이 통일)
        [appleLoginButton, kakaoLoginButton].forEach { button in
            button.snp.makeConstraints {
                $0.height.equalTo(56)
            }
        }
    }
    
    private func setupActions() {
        kakaoLoginButton.addTarget(self, action: #selector(didTapKakaoLogin), for: .touchUpInside)
        appleLoginButton.addTarget(self, action: #selector(didTapAppleLogin), for: .touchUpInside)
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        viewModel.navigateToSignUp
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.coordinator?.showSignUp()
            }
            .store(in: &cancellables)
            
        viewModel.navigateToMain
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.coordinator?.finish()
            }
            .store(in: &cancellables)
            
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.kakaoLoginButton.isEnabled = !isLoading
                self?.appleLoginButton.isEnabled = !isLoading
                // 필요하다면 로딩 인디케이터 표시
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    @objc private func didTapKakaoLogin() {
        viewModel.didTapKakaoLogin.send()
    }
    
    @objc private func didTapAppleLogin() {
        viewModel.didTapAppleLogin.send(view.window)
    }
}
