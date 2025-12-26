import UIKit
import SnapKit
import Then
import Combine

class SignUpStep1ViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: SignUpCoordinator?
    private let viewModel = SignUpStep1ViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let logoImageView = UIImageView().then {
        $0.image = Images.Icon.appbarLogo
        $0.contentMode = .scaleAspectFit
    }
    
    private let stepBadgeChip = IeumChip(title: "1 / 7", type: .static).then {
        let text = "1 / 7"
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.foregroundColor, value: Colors.white, range: NSRange(location: 0, length: 1))
        attributedString.addAttribute(.foregroundColor, value: Colors.white.withAlphaComponent(0.5), range: NSRange(location: 1, length: 2))
        
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "당신의\n현재 상황을 알려주세요"
        $0.font = .ieum(UIFont.IeumFont.Heading.h1)
        $0.textColor = Colors.Gray.g950
        $0.numberOfLines = 0
        $0.setIeumText($0.text, style: UIFont.IeumFont.Heading.h1)
    }
    
    // 선택 버튼 1
    private let patientButton = IeumButton(title: "환자 본인입니다").then {
        $0.setStyle(backgroundColor: Colors.white, borderColor: Colors.transparent, titleColor: Colors.Slate.s900, for: .normal)
        $0.setStyle(backgroundColor: Colors.Slate.s900, borderColor: Colors.transparent, titleColor: Colors.white, for: .selected)
    }
    
    // 선택 버튼 2
    private let caregiverButton = IeumButton(title: "가족 또는 보호자입니다").then {
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
        bindViewModel()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(logoImageView)
        view.addSubview(stepBadgeChip)
        view.addSubview(titleLabel)
        view.addSubview(patientButton)
        view.addSubview(caregiverButton)
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
            // width는 content에 따라 자동 조절되거나 고정 가능
            // $0.width.equalTo(45) 
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(stepBadgeChip.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        patientButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(60)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(72)
        }
        
        caregiverButton.snp.makeConstraints {
            $0.top.equalTo(patientButton.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(72)
        }
    }
    
    private func setupActions() {
        patientButton.addTarget(self, action: #selector(didTapPatient), for: .touchUpInside)
        caregiverButton.addTarget(self, action: #selector(didTapCaregiver), for: .touchUpInside)
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        viewModel.$isPatientSelected
            .receive(on: DispatchQueue.main)
            .assign(to: \.isSelected, on: patientButton)
            .store(in: &cancellables)
        
        viewModel.$isCaregiverSelected
            .receive(on: DispatchQueue.main)
            .assign(to: \.isSelected, on: caregiverButton)
            .store(in: &cancellables)
        
        viewModel.navigateToNext
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.coordinator?.showStep2()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    @objc private func didTapPatient() {
        viewModel.didSelectPatient.send()
    }
    
    @objc private func didTapCaregiver() {
        viewModel.didSelectCaregiver.send()
    }
}

