import UIKit
import SnapKit
import Then

class SignUpStep2ViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let logoImageView = UIImageView().then {
        $0.image = Images.Icon.appbarLogo
        $0.contentMode = .scaleAspectFit
    }
    
    private let stepBadgeChip = IeumChip(title: "2 / 7", type: .static).then {
        let text = "2 / 7"
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.foregroundColor, value: Colors.white, range: NSRange(location: 0, length: 1))
        attributedString.addAttribute(.foregroundColor, value: Colors.white.withAlphaComponent(0.5), range: NSRange(location: 1, length: 2))
        
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "당신의 생물학적 성별을\n알려주세요"
        $0.font = .ieum(UIFont.IeumFont.Heading.h1)
        $0.textColor = Colors.Gray.g950
        $0.numberOfLines = 0
        $0.setIeumText($0.text, style: UIFont.IeumFont.Heading.h1)
    }
    
    private let maleButton = IeumButton(title: "남성").then {
        $0.setStyle(backgroundColor: Colors.white, borderColor: Colors.transparent, titleColor: Colors.Slate.s900, for: .normal)
        $0.setStyle(backgroundColor: Colors.Slate.s900, borderColor: Colors.transparent, titleColor: Colors.white, for: .selected)
    }
    
    private let femaleButton = IeumButton(title: "여성").then {
        $0.setStyle(backgroundColor: Colors.white, borderColor: Colors.transparent, titleColor: Colors.Slate.s900, for: .normal)
        $0.setStyle(backgroundColor: Colors.Slate.s900, borderColor: Colors.transparent, titleColor: Colors.white, for: .selected)
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.ieumBackground
        
        setupUI()
        setupLayout()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 이 화면에서는 네비게이션 바 숨김
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(logoImageView)
        view.addSubview(stepBadgeChip)
        view.addSubview(titleLabel)
        view.addSubview(maleButton)
        view.addSubview(femaleButton)
    }
    
    private func setupLayout() {
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(32)
        }
        
        stepBadgeChip.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(stepBadgeChip.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        maleButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(60)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(72)
        }
        
        femaleButton.snp.makeConstraints {
            $0.top.equalTo(maleButton.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(72)
        }
    }
    
    private func setupActions() {
        maleButton.addTarget(self, action: #selector(didTapMale), for: .touchUpInside)
        femaleButton.addTarget(self, action: #selector(didTapFemale), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func didTapMale() {
        updateSelection(isMale: true)
        navigateToNextStep()
    }
    
    @objc private func didTapFemale() {
        updateSelection(isMale: false)
        navigateToNextStep()
    }
    
    private func updateSelection(isMale: Bool) {
        maleButton.isSelected = isMale
        femaleButton.isSelected = !isMale
    }
    
    private func navigateToNextStep() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            let step3VC = SignUpStep3ViewController()
            self?.navigationController?.pushViewController(step3VC, animated: true)
        }
    }
}

