import UIKit
import SnapKit
import Then

class SignUpStep4ViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let stepBadgeChip = IeumChip(title: "3 / 7", type: .static).then {
        let text = "3 / 7"
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.foregroundColor, value: Colors.white, range: NSRange(location: 0, length: 1))
        attributedString.addAttribute(.foregroundColor, value: Colors.white.withAlphaComponent(0.5), range: NSRange(location: 1, length: 2))
        
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "진단명을 1개 이상\n선택해 주세요"
        $0.font = .ieum(UIFont.IeumFont.Heading.h1)
        $0.textColor = Colors.Gray.g950
        $0.numberOfLines = 0
        $0.setIeumText($0.text, style: UIFont.IeumFont.Heading.h1)
    }
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.distribution = .fillEqually
    }
    
    // 하단 선택완료 표시 및 다음 버튼
    private let bottomContainerView = UIView()
    
    private let countLabel = UILabel().then {
        $0.text = "0 개 선택완료"
        $0.font = .ieum(UIFont.IeumFont.Helper.characterCount)
        $0.textColor = Colors.Gray.g500 // 기본 회색, 선택 시 라임으로 변경 필요
        $0.textAlignment = .center
    }
    
    private let nextButton = IeumButton(title: "다음").then {
        $0.setStyle(backgroundColor: Colors.Gray.g200, titleColor: Colors.Gray.g400, for: .disabled)
        $0.setStyle(backgroundColor: Colors.Gray.g200, titleColor: Colors.Gray.g400, for: .normal) // 활성화 전 색상 (이미지 참고: 연한 회색)
        // 활성화 시 색상은 로직에서 변경
        $0.isEnabled = false
        $0.addTarget(self, action: #selector(didTapNext), for: .touchUpInside) // 타겟 추가
    }
    
    // MARK: - Data
    
    private let diagnosisList = ["직장암", "대장암", "간이식", "기타"]
    private var selectedDiagnosis: [String: String] = [:] // [진단명: 병기(없으면 "")]
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.ieumBackground
        
        setupUI()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(stepBadgeChip)
        view.addSubview(titleLabel)
        view.addSubview(buttonStackView)
        
        diagnosisList.forEach { name in
            let button = createDiagnosisButton(title: name)
            buttonStackView.addArrangedSubview(button)
        }
        
        view.addSubview(bottomContainerView)
        bottomContainerView.addSubview(countLabel)
        bottomContainerView.addSubview(nextButton)
    }
    
    private func createDiagnosisButton(title: String) -> IeumButton {
        let button = IeumButton(title: title).then {
            $0.setStyle(backgroundColor: Colors.white, borderColor: Colors.transparent, titleColor: Colors.Slate.s900, for: .normal)
            $0.setStyle(backgroundColor: Colors.Slate.s900, borderColor: Colors.transparent, titleColor: Colors.white, for: .selected)
        }
        button.addTarget(self, action: #selector(didTapDiagnosis(_:)), for: .touchUpInside)
        return button
    }
    
    private func setupLayout() {
        stepBadgeChip.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(stepBadgeChip.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        // 버튼 높이는 스택뷰 distribution으로 자동 조정되거나 개별 높이 지정
        buttonStackView.arrangedSubviews.forEach {
            $0.snp.makeConstraints { make in
                make.height.equalTo(72)
            }
        }
        
        bottomContainerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(120) // 임의 높이
        }
        
        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(56)
        }
        
        countLabel.snp.makeConstraints {
            $0.bottom.equalTo(nextButton.snp.top).offset(-16)
            $0.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapDiagnosis(_ sender: IeumButton) {
        guard let title = sender.titleLabel?.text else { return }
        
        if sender.isSelected {
            // 이미 선택된 상태 -> 해제
            sender.isSelected = false
            sender.setBadge(text: nil)
            selectedDiagnosis.removeValue(forKey: title)
        } else {
            // 선택되지 않은 상태 -> 선택
            if title == "기타" || title == "간이식" {
                // 병기 선택 불필요한 경우 바로 선택 처리
                sender.isSelected = true
                selectedDiagnosis[title] = "" // 병기 없음 (빈 문자열 저장)
            } else {
                // 병기 선택 바텀시트 노출
                showStageSelection(for: title, button: sender)
            }
        }
        
        updateBottomState()
    }
    
    private func showStageSelection(for title: String, button: IeumButton) {
        let stageVC = StageSelectionViewController(cancerName: title)
        stageVC.onSelect = { [weak self] stage in
            guard let self = self else { return }
            button.isSelected = true
            button.setBadge(text: stage)
            self.selectedDiagnosis[title] = stage
            self.updateBottomState()
        }
        present(stageVC, animated: true)
    }
    
    private func updateBottomState() {
        let count = selectedDiagnosis.count
        
        // 카운트 라벨 업데이트 (0개 -> 0 부분 라임색)
        let countText = "\(count) 개 선택완료"
        let attributedString = NSMutableAttributedString(string: countText)
        let countRange = (countText as NSString).range(of: "\(count)")
        
        if count > 0 {
            attributedString.addAttribute(.foregroundColor, value: Colors.Lime.l500, range: countRange)
            // 다음 버튼 활성화 스타일 (Lime.l400)
            nextButton.setStyle(backgroundColor: Colors.Lime.l400, titleColor: Colors.Gray.g950, for: .normal)
            nextButton.isEnabled = true
        } else {
            attributedString.addAttribute(.foregroundColor, value: Colors.Gray.g500, range: countRange) // 0일때 회색인지 라임인지 확인 필요 (아까는 라임이었음)
            // 라임으로 통일한다면:
            attributedString.addAttribute(.foregroundColor, value: Colors.Lime.l500, range: countRange)
            
            // 다음 버튼 비활성화
            nextButton.setStyle(backgroundColor: Colors.Gray.g200, titleColor: Colors.Gray.g400, for: .normal)
            nextButton.isEnabled = false
        }
        
        countLabel.attributedText = attributedString
    }
    
    @objc private func didTapNext() {
        let step5VC = SignUpStep5ViewController()
        navigationController?.pushViewController(step5VC, animated: true)
    }
}

